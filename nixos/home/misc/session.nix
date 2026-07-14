# /etc/nixos/home/variables.nix

{ config, pkgs, ... }:

{
  home.sessionVariables = {
    # Editors
    EDITOR = "nvim";
    VISUAL = "nvim";

    # Terminal
    TERMINAL = "kitty";

    # Browser
    BROWSER = "zen-beta";

    # File Manager
    FILE_MANAGER = "yazi";

    # Misc
    PAGER = "less";
    MANPAGER = "nvim";

    # Wayland
    NIXOS_OZONE_WL = "1";

    # Better defaults
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";
  };
}
