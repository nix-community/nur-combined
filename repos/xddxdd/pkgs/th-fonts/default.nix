{ callPackage, sources, ... }:
let
  font = callPackage ./font.nix { };
in
{
  tshyn = font sources.th-tshyn;
  hak = font sources.th-hak;
  joeng = font sources.th-joeng;
  khaai-t = font sources.th-khaai-t;
  khaai-p = font sources.th-khaai-p;
  ming = font sources.th-ming;
  sung-t = font sources.th-sung-t;
  sung-p = font sources.th-sung-p;
  sy = font sources.th-sy;
}
