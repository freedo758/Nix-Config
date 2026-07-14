{ config, pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "macOS";
      package = pkgs.apple-cursor;
      size = 24;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    # Matugen writes ~/.config/generated/gtk-colors.css; GTK3 can @import it
    # without Home Manager ever owning that file's contents.
    gtk3.extraCss = ''
      @import url("${config.home.homeDirectory}/.config/gtk-3.0/colors.css");
    '';
gtk4.extraCss = ''
      @import url("${config.home.homeDirectory}/.config/gtk-4.0/colors.css");
    '';
  };
}
