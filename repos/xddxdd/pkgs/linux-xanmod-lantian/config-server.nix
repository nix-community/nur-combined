{ lib, ... }:

with lib.kernel;
{
  COREDUMP = no;
  FONT_TER16x32 = lib.mkForce no;
  FONT_CJK_16x16 = lib.mkForce no;
  FONT_CJK_32x32 = lib.mkForce no;
}
