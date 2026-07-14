{ config, pkgs, lib, ... }:

{
  imports = [
    ./hyprland.nix
    ./gaming.nix
  ];

  # dconf + gsettings-desktop-schemas (in home/packages/desktop.nix) are needed for
  # `gsettings` calls to work at all outside a GNOME session - matugen's
  # gtk3 post_hook uses gsettings to flip the adw-gtk3 theme variant, and
  # it was failing with "No schemas installed" without this.
  #
  # Confirmed via `find` on the actual store path: the real (compiled)
  # schemas live at share/gsettings-schemas/<name>/glib-2.0/schemas/,
  # including a prebuilt gschemas.compiled - nothing merges that into
  # /run/current-system/sw automatically outside GNOME's own module, so
  # point at it directly.
  programs.dconf.enable = true;
  environment.variables.GSETTINGS_SCHEMA_DIR =
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

  # Cursor theme
  environment.variables = {
    XCURSOR_THEME = "Apple Cursor";
    XCURSOR_SIZE = "24";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    font-awesome
    inter
  ];
}
