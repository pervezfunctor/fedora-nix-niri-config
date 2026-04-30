{ pkgs, vars, ... }: {
  home = {
    username = vars.username;
    homeDirectory = vars.homeDirectory;
    stateVersion = "25.11";
    packages = with pkgs; [
      devbox
      devenv
      nil
      nixd
      nixfmt
    ];
  };
  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;
}
