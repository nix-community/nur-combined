{ ... }:

{
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us,colemak-bs_cl";
      options = "compose:ralt,grp:ctrl_space_toggle";
    };
  };
}
