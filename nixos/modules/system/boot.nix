{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Recommended for modern AMD CPUs.
  boot.kernelParams = [ "amd_pstate=active" ];

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.tmp.cleanOnBoot = true;
}
