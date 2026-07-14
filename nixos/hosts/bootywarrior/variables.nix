{ ... }:

{
  networking.hostName = "bootywarrior";

  # Adjust to your actual location.
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.variables.RUSTICL_ENABLE = "radeonsi";

  system.stateVersion = "26.05";
}
