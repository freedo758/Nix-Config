{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.leo = {
    isNormalUser = true;
    description = "leo";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "input" ];
    shell = pkgs.fish;
  };
}
