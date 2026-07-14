{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Media & creative
    blender
    davinci-resolve
    ffmpeg
    gimp
    obs-studio
    #    handbrake
    vlc

    # Better Yazi previews
    ffmpegthumbnailer
    imagemagick
    poppler-utils

    # File management
    yazi
  ];
}
