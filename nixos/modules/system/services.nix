{ pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };



#DMS
  programs.dms-shell = {
  enable = true;
  systemd = {
  enable = true;
  restartIfChanged = true;
  };

  enableSystemMonitoring = true;
  enableVPN = true;
  enableDynamicTheming = false; # theming now driven by qs-wallpaper-picker + matugen instead
  enableAudioWavelength = true;
  enableCalendarEvents = true;
  enableClipboardPaste = true;
  };
 
  services.resolved.enable = true;
  services.dbus.enable = true;
  services.upower.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Trims SSDs weekly instead of continuous discard.
  services.fstrim.enable = true;
}
