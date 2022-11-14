{ lib, ... }:

{
  imports = [ ./common.nix ];
  users.users.bjorn = {
    initialHashedPassword = lib.mkForce "$6$v2llK2x3L.ellZIQ$DJAf6QGS285fyJ2qKatnoaahuIprpE00GvWekPW2vdnCYuuRg8kyenOIbTEONt8qngKE5AHd3mEQbYhomr0Gq0";
    extraGroups = [ "video" ];
  };
}
