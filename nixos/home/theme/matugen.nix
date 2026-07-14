{ config, ... }:

let
  templates = "${config.xdg.configHome}/matugen/templates";
in
{
  # matugen itself is already installed via home/packages/desktop.nix.
  # This module is now the single source of truth for config.toml: it was
  # previously being silently overwritten down to just the rofi-wallpaper
  # marker on every `home-manager switch`, wiping out the rest of the
  # templates below (they were recovered from config.toml.hm-backup).
  xdg.configFile."matugen/config.toml".text = ''
    [config]
    reload_apps = true

    [config.wallpaper]
    # qs-wallpaper-picker uses awww (a swww fork) as its transition backend,
    # so matugen sets the wallpaper the same way. Newer matugen dropped the
    # separate command/arguments split in favor of a single command string.
    command = "awww img --transition-type center {{ image }}"
    set = true

    # Keeps rofi's imagebox (style-6.rasi) pointed at whatever wallpaper
    # was just applied. input_path just needs to exist; the real work
    # happens in post_hook.
    [templates.rofi-wallpaper]
    input_path = "${templates}/rofi-wallpaper-marker"
    output_path = "${config.xdg.cacheHome}/rofi/wallpaper-marker"
    post_hook = 'mkdir -p ${config.xdg.cacheHome}/rofi && ln -sf "{{image}}" ${config.xdg.cacheHome}/rofi/current_wallpaper'

    # Hyprland is on the new Lua config (0.55+), so this writes a Lua module
    # (native 0xffRRGGBB ARGB hex) instead of a hyprlang colors.conf.
    # decoration.lua already `require("modules.colors")`s this exact path.
    [templates.hyprland]
    input_path = "${templates}/hyprland-colors.lua"
    output_path = "${config.home.homeDirectory}/.config/hypr/modules/colors.lua"
    post_hook = "hyprctl reload"

    [templates.qt5ct]
    input_path = "${templates}/qtct-colors.conf"
    output_path = "${config.xdg.configHome}/qt5ct/colors/matugen.conf"

    [templates.qt6ct]
    input_path = "${templates}/qtct-colors.conf"
    output_path = "${config.xdg.configHome}/qt6ct/colors/matugen.conf"

    [templates.kitty]
    input_path = "${templates}/kitty-colors.conf"
    output_path = "${config.xdg.configHome}/kitty/themes/Matugen.conf"
    post_hook = "kitty +kitten themes --reload-in=all Matugen"

    [templates.wlogout]
    input_path = "${templates}/wlogout-colors.css"
    output_path = "${config.xdg.configHome}/wlogout/wlogout-colors.css"

    [templates.gtk3]
    input_path = "${templates}/gtk-colors.css"
    output_path = "${config.xdg.configHome}/gtk-3.0/colors.css"
    post_hook = 'gsettings set org.gnome.desktop.interface gtk-theme ""; gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark-{{mode}}'

    [templates.gtk4]
    input_path = "${templates}/gtk-colors.css"
    output_path = "${config.xdg.configHome}/gtk-4.0/colors.css"
    post_hook = "${config.xdg.configHome}/matugen/post-hook-scripts/gtk-themes-reload.sh"

    [templates.starship]
    input_path = "${templates}/starship-colors.toml"
    output_path = "${config.xdg.configHome}/starship/starship.toml"

    [templates.rofi]
    input_path = "${templates}/rofi-colors.rasi"
    output_path = "${config.xdg.configHome}/rofi/colors.rasi"

    [templates.nvim]
    input_path = "${templates}/nvim-colors.vim"
    output_path = "${config.xdg.configHome}/nvim/colors/matugen.vim"
    post_hook = "pkill -SIGUSR1 nvim || true"

    [templates.yazi]
    input_path = "${templates}/yazi-theme.toml"
    output_path = "${config.xdg.configHome}/yazi/theme.toml"

    [templates.steam]
    input_path = "${templates}/steam.css"
    output_path = "${config.xdg.configHome}/AdwSteamGtk/custom.css"
    post_hook = "adwaita-steam-gtk -i"

    [templates.cava]
    input_path = "${templates}/cava-colors.ini"
    output_path = "${config.xdg.configHome}/cava/themes/Matugen"
    post_hook = "pkill -USR1 cava || true"

    [templates.btop]
    input_path = "${templates}/btop.theme"
    output_path = "${config.xdg.configHome}/btop/themes/matugen.theme"
    post_hook = "pkill -USR2 btop || true"

    [templates.obs]
    input_path = "${templates}/matugen.obt"
    output_path = "${config.xdg.configHome}/obs-studio/themes/matugen.obt"

    [templates.heroic]
    input_path = "${templates}/heroic.css"
    output_path = "${config.xdg.configHome}/heroic/themes/matugen.css"

    [templates.zen]
    input_path =  "${templates}/zen-userchrome.css"
    output_path = "${config.xdg.configHome}/zen/9xxxm691.Default (release)/chrome/Matugen/Chrome.css"

 [templates.quickshell]
    input_path =  "${templates}/quickshell-colors.json"
    output_path = "${config.xdg.configHome}/quickshell/Colors/quickshell-colors.json"

  '';

  # Dummy marker file so matugen's rofi-wallpaper template has a valid input_path.
  xdg.configFile."matugen/templates/rofi-wallpaper-marker".text = "";

  # NOTE: all other input_path files above (hyprland-colors.lua, kitty-colors.conf,
  # gtk-colors.css, qtct-colors.conf, rofi-colors.rasi, starship-colors.toml,
  # nvim-colors.vim, yazi-theme.toml, steam.css, cava-colors.ini, btop.theme,
  # matugen.obt, heroic.css, wlogout-colors.css) already exist as real files in
  # ~/.config/matugen/templates/ and were NOT touched by home-manager, since
  # xdg.configFile only manages the paths it explicitly declares. They do not
  # need to be re-created here. If you ever want them Nix-managed too (so they
  # survive a fresh install), copy their contents into this file the same way
  # rofi-wallpaper-marker is done above.
  #
  # Also unresolved from the transcript: [templates.gtk4]'s post_hook points at
  # ~/.config/matugen/post-hook-scripts/gtk-themes-reload.sh — worth confirming
  # that script still exists and is executable:
  #   ls -la ~/.config/matugen/post-hook-scripts/
}
