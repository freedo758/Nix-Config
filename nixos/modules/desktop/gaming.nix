{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  programs.corectrl.enable = true;
  # System-wide MangoHud so it can be layered onto any Steam game via
  # launch options (`mangohud %command%`), on top of Home Manager's
  # per-user config.
  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
