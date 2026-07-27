
{ stdenv
, fetchurl
, p7zip

# wether to build the version to be used with Xorg or not Xorg (eg wayland)
, forXorg ? false
, ...
}: let

  nameExtension = (
    if stdenv.isx86_64 or stdenv.isx86_32 
    then "x" 
    else if stdenv.isAarch64 or stdenv.isAarch32 or stdenv.isMips 
    then "ma" 
    else builtins.throw "unsupported system" ""
  );
  fileName = "eGTouch_v2.5.13219.L-${nameExtension}";
  pathArch = 
    if stdenv.isAarch64 then  "eGTouchAARCH64"
    else builtins.throw "unsupported arch..." "";
  pathBackend = 
    if forXorg then "${pathArch}withX"
    else "${pathArch}nonX";

in stdenv.mkDerivation rec {
  version = "2.5";
  pname = "eGTouch";

  nativeBuildInputs = [
    p7zip # to unpack the src
  ];

  # there are seperate tarballs... one for x86 and one for arm andmips
  src = fetchurl {
    url = "https://www.eeti.com/touch_driver/Linux/20240510/${fileName}.7z";
    hash = 
      if nameExtension == "x" 
      then "sha256-zZlM4finrnvtxBmqKm4Sl0zQeFz/7yCTuTjXEwmolVI=" 
      else "";
  };

  unpackPhase = ''
    7z x $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./${fileName}/${pathArch}/${pathBackend}/eGTouch $out/bin
  '';

}
