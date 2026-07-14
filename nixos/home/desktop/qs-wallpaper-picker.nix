{ config, pkgs, lib, ... }:

let
  # Vendored in-tree instead of fetched from GitHub, so the local fixes below
  # (originalFile thumb-name stripping, unconditional mpvpaper pkill before
  # switching wallpaper, thumbnail auto-sync via scripts/generate_thumbs.sh,
  # and the matugen --source-color-index fix) live in git and survive every
  # rebuild instead of being re-derived via sed patches against upstream.
  qsWallpaperPickerSrc = ./qs-wallpaper-picker;
  installDir = "${config.xdg.configHome}/quickshell/qs-wallpaper-picker";
in
{
  home.packages = [ pkgs.mpvpaper ]; # also declared in home/packages/desktop.nix; harmless if duplicated

  # Settings.qml is explicitly user-specific and gitignored upstream, so we can't just
  # symlink the whole repo out of the Nix store (which is read-only) - the app needs to
  # be able to have a real, writable config/Settings.qml sitting alongside the rest of
  # the source. So: rsync the store copy in on every activation, but never touch
  # config/Settings.qml if it already exists.
  home.activation.qsWallpaperPicker = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${installDir}"
    run ${pkgs.rsync}/bin/rsync -a --delete \
      --exclude 'config/Settings.qml' \
      "${qsWallpaperPickerSrc}/" "${installDir}/"
    run chmod -R u+w "${installDir}"

    if [ ! -f "${installDir}/config/Settings.qml" ]; then
      run cp "${installDir}/config/Settings.qml.example" "${installDir}/config/Settings.qml"

      # Fill in your wallpaper dir and turn dynamic theming on, since matugen
      # now owns theming instead of dms-shell.
      run ${pkgs.gnused}/bin/sed -i \
        -e 's|property string wallpaperDir:.*|property string wallpaperDir: homeDir + "/Wallpapers"|' \
        -e 's|property bool enableDynamicColors:.*|property bool enableDynamicColors: true|' \
        -e 's|property bool enableMatugen:.*|property bool enableMatugen: true|' \
        -e 's|property bool enableHyprReload:.*|property bool enableHyprReload: true|' \
        -e 's|property bool enableWaybarReload:.*|property bool enableWaybarReload: false|' \
        "${installDir}/config/Settings.qml"
    fi
  '';
}
