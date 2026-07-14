{ ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;

    flags = [ "--disable-ctrl-r" ];

    settings = {
      auto_sync = true;
      update_check = false;
      sync_frequency = "5m";
      style = "compact";
    };
  };
}
