{ config, pkgs, inputs, ... }:

let
  # nixpkgs' quickshell only links against qtbase/qtdeclarative/qtwayland/qtsvg,
  # so QtMultimedia (needed for qs-wallpaper-picker's video wallpaper preview)
  # isn't on its QML import path. wrapQtAppsHook (already in quickshell's
  # nativeBuildInputs) derives that path from buildInputs, so adding
  # qt6.qtmultimedia here is enough for it to get picked up automatically.
  quickshell' = pkgs.quickshell.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ pkgs.qt6.qtmultimedia ];
  });
in
{
  # Packages that don't warrant their own module.
  home.packages = with pkgs; [
    awww

    # Browser
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Editors & terminal
    kitty

    # Desktop utilities
    feh
    qbittorrent

    # Wayland / desktop utilities
    wofi
    rofi
    cliphist
    wl-clipboard
    wlogout
    waypaper
    hyprshot
    cava
    nwg-look
    matugen
    udiskie
    quickshell'
    mpvpaper

    # File management
    gnome-disk-utility
    kdePackages.ark
    localsend

    # Audio / network
    pavucontrol
    networkmanagerapplet
    iwgtk

    # Theming
    libsForQt5.qt5ct
    kdePackages.qt6ct
    apple-cursor
    adwsteamgtk
    adw-gtk3
    gsettings-desktop-schemas
  ];
}
