{ pkgs, ... }:

{
  # Modern Mesa/RADV Vulkan + OpenGL stack for AMD.
  # `hardware.graphics` is the current option name (replaces the old
  # `hardware.opengl` namespace).


  hardware.amdgpu = {
  opencl.enable = true;
  initrd.enable = true;
};
  hardware.bluetooth.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
};
   

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  services.xserver.videoDrivers = [ "amdgpu" ];
}
