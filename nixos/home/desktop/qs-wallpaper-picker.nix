{ config, pkgs, lib, ... }:

let
  qsWallpaperPickerSrc = pkgs.fetchFromGitHub {
    owner = "magetsu002";
    repo = "qs-wallpaper-picker";
    rev = "main"; # pin to a commit sha once you're happy with it, for reproducibility
    hash = "sha256-k0veLYjRUcHznyY6v7Wj/IRAPa35MAadcg02pJBVR4k=";
  };
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

    # Upstream bug workaround: WallpaperPicker.qml has `import "../"`, which
    # resolves to the *parent* of this shell's own directory (i.e. plain
    # ~/.config/quickshell/) once installed here. Quickshell refuses to
    # synthesize a module for anything outside the shell's own folder, and
    # that refusal also blocks the `import "config"` right after it in the
    # same file - hence "module config is not installed". The line is dead
    # weight anyway: Scaler and MatugenColors, the only sibling types it
    # uses, are already auto-visible since they live in the same directory.
    run ${pkgs.gnused}/bin/sed -i '/^import "\.\.\/" *$/d' "${installDir}/WallpaperPicker.qml"

    # Upstream bug: scripts/matugen_reload.sh calls `matugen image "$WALL"`
    # with no color-selection flag. matugen prompts interactively when an
    # image has multiple plausible source colors - fine from a terminal,
    # but this script runs detached with no TTY, so matugen just errors out
    # ("Multiple source colors found... a terminal was not detected") and
    # silently skips every template, meaning nothing re-themes even though
    # the wallpaper itself still changes. --source-color-index 0 picks the
    # first candidate deterministically, matching manual `matugen image ...`
    # testing. This has to be re-applied every activation (not just on
    # first install) since the whole tree gets rsynced fresh each time.
    run ${pkgs.gnused}/bin/sed -i \
      's|matugen image "\$WALL"|matugen image "$WALL" --source-color-index 0|' \
      "${installDir}/scripts/matugen_reload.sh"

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
