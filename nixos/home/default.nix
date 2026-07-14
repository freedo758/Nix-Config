{ pkgs, ... }:

{
  home.username = "leo";
  home.homeDirectory = "/home/leo";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [
    ./packages
    ./shell
    ./development
    ./desktop
    ./theme
    ./misc
  ];
}
