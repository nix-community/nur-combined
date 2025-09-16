{
  source,
  cpio,
  xar,
  lib,
  undmg,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "Karabiner-DriverKit-VirtualHIDDevice";
  inherit (source) src version;
  nativeBuildInputs = [
    cpio
    xar
  ];
  unpackPhase = ''
    	  xar -xf $src
          zcat Payload | cpio -i
  '';

  installPhase = ''
    mkdir -p $out
      cp -R ./Applications ./Library $out
  '';

  meta = {

    license = lib.licenses.unlicense;
    platforms = lib.platforms.darwin;
  };

}
