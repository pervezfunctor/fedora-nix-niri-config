#!/usr/bin/env nu

def fail [msg: string] {
  error make { msg: $msg }
}

def assert [cond: bool, msg: string] {
  if not $cond { fail $msg }
}

def assert-eq [actual expected msg: string] {
  if ($actual != $expected) {
    fail $"($msg): expected=($expected), actual=($actual)"
  }
}

def readlink-target [path: string]: nothing -> string {
  let result = (^readlink $path | complete)
  if $result.exit_code == 0 { $result.stdout | str trim } else { "" }
}

def is-symlink [path: string]: nothing -> bool {
  (readlink-target $path | is-not-empty)
}

def assert-link [path: string, expected: string] {
  let target = (readlink-target $path)
  assert ($target | is-not-empty) $"Expected symlink at ($path)"
  assert-eq $target ($expected | path expand) $"Unexpected link target for ($path)"
}

def assert-not-link [path: string] {
  assert (not (is-symlink $path)) $"Expected no symlink at ($path)"
}

def write-file [path: string, content: string] {
  mkdir ($path | path dirname)
  $content | save -f $path
}

def setup-fake-trash [root: string]: nothing -> record<bin: string, log: string> {
  let bin = ($root | path join "bin")
  let log = ($root | path join "trash.log")
  mkdir $bin
  "" | save -f $log

  let trash = ($bin | path join "trash")
  "#!/usr/bin/env bash
set -euo pipefail
: \"${STOW_TEST_TRASH_LOG:?}\"
for path in \"$@\"; do
  printf '%s\n' \"$path\" >> \"$STOW_TEST_TRASH_LOG\"
  rm -rf -- \"$path\"
done
" | save -f $trash
  ^chmod +x $trash

  { bin: $bin, log: $log }
}

def new-case []: nothing -> record<root: string, home: string, dot_dir: string, trash_bin: string, trash_log: string> {
  let root = (^mktemp -d | str trim)
  let home = ($root | path join "home")
  let dot_dir = ($root | path join "repo")
  mkdir $home
  mkdir $dot_dir

  let fake_trash = (setup-fake-trash $root)
  {
    root: $root,
    home: $home,
    dot_dir: $dot_dir,
    trash_bin: $fake_trash.bin,
    trash_log: $fake_trash.log,
  }
}

def run-stow [ctx: record, ...args: string] {
  let script_dir = ($env.FILE_PWD? | default ($env.PWD | path join "scripts"))
  with-env {
    HOME: $ctx.home,
    DOT_DIR: $ctx.dot_dir,
    PATH: ([$ctx.trash_bin] ++ $env.PATH),
    STOW_TEST_TRASH_LOG: $ctx.trash_log,
  } {
    nu ($script_dir | path join "stow.nu") ...$args
  }
}

def trash-entries [ctx: record]: nothing -> list<string> {
  open $ctx.trash_log | lines | where { |line| $line | is-not-empty }
}

def assert-trash-count [ctx: record, expected: int, msg: string] {
  assert-eq ((trash-entries $ctx) | length) $expected $msg
}

def test-basic-config-home-and-spaces [] {
  let ctx = (new-case)

  write-file ($ctx.dot_dir | path join "git/dot-gitconfig") "[user]"
  write-file ($ctx.dot_dir | path join "nvim/lua/init.lua") "return {}"
  write-file ($ctx.dot_dir | path join "homepkg/dot-demo") "set -gx DEMO 1"
  write-file ($ctx.dot_dir | path join "space pkg/dot-dir/file name") "spaces"

  run-stow $ctx config git
  run-stow $ctx config nvim
  run-stow $ctx home homepkg
  run-stow $ctx config "space pkg"

  assert-link ($ctx.home | path join ".config/git/.gitconfig") ($ctx.dot_dir | path join "git/dot-gitconfig")
  assert-link ($ctx.home | path join ".config/nvim/lua/init.lua") ($ctx.dot_dir | path join "nvim/lua/init.lua")
  assert-link ($ctx.home | path join ".demo") ($ctx.dot_dir | path join "homepkg/dot-demo")
  assert-link ($ctx.home | path join ".config/space pkg/.dir/file name") ($ctx.dot_dir | path join "space pkg/dot-dir/file name")
  assert-trash-count $ctx 0 "fresh stow should not trash anything"
}

def test-default_command_uses_config_target [] {
  let ctx = (new-case)
  write-file ($ctx.dot_dir | path join "pkg/file") "default"

  run-stow $ctx pkg

  assert-link ($ctx.home | path join ".config/pkg/file") ($ctx.dot_dir | path join "pkg/file")
  assert-trash-count $ctx 0 "default command should not trash anything"
}

def test_existing_correct_symlinks_are_idempotent [] {
  let ctx = (new-case)
  let src = ($ctx.dot_dir | path join "pkg/file")
  let target = ($ctx.home | path join ".config/pkg/file")
  write-file $src "same"

  run-stow $ctx config pkg
  run-stow $ctx config pkg
  assert-link $target $src

  ^rm $target
  ^ln -s "../../../repo/pkg/file" $target
  run-stow $ctx config pkg
  assert-eq (readlink-target $target) "../../../repo/pkg/file" "relative symlink to same source should be preserved"
  assert-trash-count $ctx 0 "idempotent stow should not trash existing correct links"
}

def test_existing_regular_file_is_replaced [] {
  let ctx = (new-case)
  let src = ($ctx.dot_dir | path join "pkg/file")
  let target = ($ctx.home | path join ".config/pkg/file")
  write-file $src "new"
  write-file $target "old"

  run-stow $ctx config pkg

  assert-link $target $src
  assert-trash-count $ctx 1 "regular file should be trashed before linking"
  assert-eq ((trash-entries $ctx) | first) $target "trashed path should be the regular file target"
}

def test_existing_wrong_and_broken_symlinks_are_replaced [] {
  let ctx = (new-case)
  let src = ($ctx.dot_dir | path join "pkg/file")
  let other = ($ctx.root | path join "other")
  let wrong = ($ctx.home | path join ".config/pkg/wrong")
  let broken = ($ctx.home | path join ".config/pkg/broken")
  write-file $src "new"
  write-file $other "other"
  mkdir ($wrong | path dirname)
  ^ln -s $other $wrong
  ^ln -s ($ctx.root | path join "missing") $broken

  write-file ($ctx.dot_dir | path join "pkg/wrong") "new wrong"
  write-file ($ctx.dot_dir | path join "pkg/broken") "new broken"
  run-stow $ctx config pkg

  assert-link $wrong ($ctx.dot_dir | path join "pkg/wrong")
  assert-link $broken ($ctx.dot_dir | path join "pkg/broken")
  assert-trash-count $ctx 2 "wrong and broken symlinks should be trashed"
}

def test_symlink_loop_is_replaced [] {
  let ctx = (new-case)
  let src = ($ctx.dot_dir | path join "pkg/loop")
  let target = ($ctx.home | path join ".config/pkg/loop")
  write-file $src "fixed"
  mkdir ($target | path dirname)
  ^ln -s $target $target

  run-stow $ctx config pkg

  assert-link $target $src
  assert-trash-count $ctx 1 "unresolvable symlink loop should be trashed"
}

def test_existing_directory_is_skipped [] {
  let ctx = (new-case)
  let src = ($ctx.dot_dir | path join "pkg/dir")
  let target = ($ctx.home | path join ".config/pkg/dir")
  write-file $src "file"
  mkdir $target

  run-stow $ctx config pkg

  assert (($target | path type) == "dir") "existing target directory should remain a directory"
  assert-not-link $target
  assert-trash-count $ctx 0 "directories should not be trashed"
}

def test_empty_package_and_outside_symlink_boundary [] {
  let ctx = (new-case)
  mkdir ($ctx.dot_dir | path join "empty")
  mkdir ($ctx.dot_dir | path join "pkg")
  write-file ($ctx.root | path join "outside") "outside"
  ^ln -s ($ctx.root | path join "outside") ($ctx.dot_dir | path join "pkg/outside")

  run-stow $ctx config empty
  run-stow $ctx config pkg

  assert (not (($ctx.home | path join ".config/empty") | path exists)) "empty package should not create a target directory"
  assert (not (($ctx.home | path join ".config/pkg/outside") | path exists)) "symlink source resolving outside DOT_DIR should be skipped"
  assert-not-link ($ctx.home | path join ".config/pkg/outside")
  assert-trash-count $ctx 0 "empty and skipped packages should not trash anything"
}

def main [] {
  test-basic-config-home-and-spaces
  test-default_command_uses_config_target
  test_existing_correct_symlinks_are_idempotent
  test_existing_regular_file_is_replaced
  test_existing_wrong_and_broken_symlinks_are_replaced
  test_symlink_loop_is_replaced
  test_existing_directory_is_skipped
  test_empty_package_and_outside_symlink_boundary

  print "stow regression tests passed"
}
