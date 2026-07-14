{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Editors
    neovim

    # Git
    delta
    lazydocker
    lazygit
  ];
}
