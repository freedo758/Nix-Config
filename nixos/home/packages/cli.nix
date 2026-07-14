{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Better CLI
    bat
    eza
    fastfetch
    fd
    file
    ripgrep
    yq

    # Disk usage
    dua
    dust
    gdu

    # System monitoring
    btop

    # System diagnostics
    killall
    pciutils
    usbutils

    # General utilities
    curl
    fzf
    jq
    p7zip
    stow
    unzip
    wget
    zip

    #Terminal Pokemon
    pokemon-colorscripts
  ];
}
