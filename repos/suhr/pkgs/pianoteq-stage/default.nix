{ requireFile, lib, stdenv, p7zip, libX11, libXext, alsaLib, freetype, lv2, libjack2 }:

let
  version = "7.5.3";
  archdir = if stdenv.isAarch64 then
    "arm-64bit"
  else if stdenv.isx86_64 then
    "x86-64bit"
  else
    throw "Unsupported architecture";

in stdenv.mkDerivation rec {
  name = "pianoteq-stage-${version}";
  src = requireFile rec {
    name = "pianoteq_stage_linux_v753.7z";
    message = "Please add pianoteq_stage_linux_v753.7z to the nix store manually";
    sha256 = "sha256-Z+XSexj/XxM2lYUZdfjvOHzb/ve62MxYIJNldMEz8qA=";
  };

  nativeBuildInputs = [ p7zip ];

  libPath = lib.makeLibraryPath [
    libX11 libXext alsaLib freetype lv2 libjack2 stdenv.cc.cc
  ];

  buildPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    cp "${archdir}/Pianoteq 7 STAGE" "$out/bin/pianoteq-stage"
    patchelf --set-interpreter "$(< $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $libPath \
      "$out/bin/pianoteq-stage"

    mkdir -p "$out/lib/lv2/Pianoteq 7.lv2"
    cp -a "${archdir}/Pianoteq 7 STAGE.lv2/"* "$out/lib/lv2/Pianoteq 7.lv2/"
  '';

  fixupPhase = ":";

  meta = with lib; {
    description = "Virtual piano instrument using physical modelling synthesis";
    homepage = https://www.pianoteq.com/;
    license = licenses.unfree;
    maintainers = with maintainers; [ suhr ];
    platforms = platforms.linux;
  };
}
