{ stdenvNoCC, lib }:

stdenvNoCC.mkDerivation {
  pname = "canokey-udev-rules";
  version = "0.1";

  src = ./69-canokey.rules;
  dontUnpack = true;

  installPhase = ''
    install -D -m444 $src $out/lib/udev/rules.d/69-canokey.rules
  '';

  meta = with lib; {
    description = "udev rules for CanoKey";
    homepage = "https://docs.canokeys.org/userguide/setup";
  };
}
