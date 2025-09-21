{ stdenv, lib, ... }:

stdenv.mkDerivation rec {
  name = "rkflashtool-udev-rules";
  version = "1.0";
  src = ./51-android.rules;
  
  dontUnpack = true;

  installPhase = ''
    install -D -m444 $src $out/lib/udev/rules.d/51-android.rules
  '';

  meta = {
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ "dmfrpro" ];
    description = "Rockchip rkflashtool Udev Rules";
    platforms = [ "x86_64-linux" ];
  };
}
