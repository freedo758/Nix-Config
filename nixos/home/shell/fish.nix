{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting

      set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml
      ${pkgs.starship}/bin/starship init fish | source

      ${pkgs.fastfetch}/bin/fastfetch

      function y
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          ${pkgs.yazi}/bin/yazi $argv --cwd-file="$tmp"
          if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
              cd -- "$cwd"
          end
          rm -f -- "$tmp"
      end
    '';

    shellAbbrs = {
      nrs = "sudo nixos-rebuild switch";
      nrsf = "sudo nixos-rebuild switch --flake /etc/nixos#bootywarrior";
      ncon = "cd /etc/nixos";
      se = "sudoedit";

      nupdate = "nix-channel --update";
      flakeup = "sudo nix flake update";
      ngarbage = "sudo nix-collect-garbage --delete-older-than 7d";
      noptimise = "sudo nix-store --optimise";
      journalclean = "sudo journalctl --vacuum-size=1G";

      ls = "eza --icons";
      ll = "eza -lah --icons --git";
      la = "eza -a --icons";
      tree = "eza --tree --icons";

      cat = "bat --paging=never";

      ff = "fd";
      grep = "rg";

      du = "dust";
      top = "btop";

      lg = "lazygit";
    };
  };
}
