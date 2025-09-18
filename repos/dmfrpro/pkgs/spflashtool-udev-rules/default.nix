{ stdenv, lib, ... }:

stdenv.mkDerivation rec {
  name = "spflashtool-udev-rules";
  version = "1.0";
  src = ./60-spflashtool.rules;
  
  dontUnpack = true;

  installPhase = ''
    install -D -m444 $src $out/lib/udev/rules.d/60-spflashtool.rules
  '';

  meta = {
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ "dmfrpro" ];
    description = "SP Flash Tool Udev Rules";
    platforms = [ "x86_64-linux" ];
  };
}
