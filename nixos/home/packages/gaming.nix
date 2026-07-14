{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Gaming
    faugus-launcher
    gamescope
    heroic
    mangohud
    protonup-qt
    vulkan-tools
    # wineWow64Packages.stable supersedes plain `wine` (WoW64 = both 32-
    # and 64-bit Windows app support). Having both installed conflicts:
    # they ship overlapping lib/wine/i386-windows/*.a files and buildEnv
    # can't merge them.
    wineWow64Packages.stable
    winetricks
    #grapejuice #Roblox
  ];
}
