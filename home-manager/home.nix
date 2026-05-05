{ pkgs, vars, ... }:
{
  news.display = "silent";

  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;

  home = {
    username = vars.username;
    homeDirectory = vars.homeDirectory;
    stateVersion = "25.11";

    packages = with pkgs; [
      carapace
      devbox
      devenv
      nerd-fonts.jetbrains-mono
      nil
      nixd
      nixfmt
      nushell
      starship

      # dysk
      # bottom
      # television
      # xh
      # bibata-cursors
      #nerd-fonts.monaspace
    ];
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableNushellIntegration = true;
    };
  };

  nix = {
    package = pkgs.nix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      max-jobs = "auto";
      cores = 2;

      substituters = [
        "https://cache.nixos.org/"
      ];

      warn-dirty = false;
    };
  };
}
