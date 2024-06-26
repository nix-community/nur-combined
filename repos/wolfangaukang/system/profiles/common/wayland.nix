{ ... }:

{
   imports = [
     ../xserver.nix
   ];
 
   environment.sessionVariables.WLR_RENDERER_ALLOW_SOFTWARE = "1";
   security.pam.services.swaylock.text = ''
     auth include login
   '';
   services = {
     blueman.enable = true;
     # SDDM is the recommended DM for Wayland
     displayManager.sddm = {
       enable = true;
       wayland.enable = true;
     };
   };
   hardware.bluetooth = {
     enable = true;
     powerOnBoot = false;
   };
}
