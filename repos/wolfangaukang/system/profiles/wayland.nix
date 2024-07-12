{ config
, ...
}:

let
  isWaylandWMEnabled = config.programs.sway.enable || config.programs.hyprland.enable;

in {
   imports = [
     ./xserver.nix
   ];
 
   environment.sessionVariables.WLR_RENDERER_ALLOW_SOFTWARE = if isWaylandWMEnabled then "1" else "";
   security.pam.services.swaylock.text = if isWaylandWMEnabled then ''
     auth include login
   '' else "";
   services = {
     blueman.enable = true;
     # SDDM is the recommended DM for Wayland
     displayManager.sddm = {
       enable = true;
       wayland.enable = isWaylandWMEnabled;
     };
   };
}
