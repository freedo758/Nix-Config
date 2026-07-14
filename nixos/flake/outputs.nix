{ self, nixpkgs, home-manager, zen-browser,   ... }@inputs:

let
  system = "x86_64-linux";
in
{
  nixosConfigurations.bootywarrior = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };

    modules = [
      ../hosts/bootywarrior

      ../modules/system
      ../modules/desktop
      ../modules/home-manager.nix
    ];
  };
}
