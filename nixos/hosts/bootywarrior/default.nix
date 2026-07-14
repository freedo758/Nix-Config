{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./variables.nix
  ];

  # nano ships via its own module (enabled by default on modern NixOS),
  # not environment.defaultPackages. neovim is already EDITOR/VISUAL/defaultEditor.
  programs.nano.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Upstream workaround: click-threading's own test suite fails to build
  # on this pinned nixpkgs commit because docs/conf.py imports
  # pkg_resources, which Python 3.14 no longer ships by default. This is
  # a bug in click-threading's packaging (pulled in transitively via
  # khal -> vdirsyncer, from programs.dms-shell.enableCalendarEvents),
  # not anything in this config. Disabling its check phase only skips
  # its own internal tests/docs build, not the library's actual runtime
  # behavior. Safe to remove once nixpkgs fixes this upstream.
  nixpkgs.overlays = [
    (import ../../overlays/default.nix)
  ];
}
