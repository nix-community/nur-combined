{ stdenv, fetchurl, patchelf }:

let

  version = "7.4.38";

in stdenv.mkDerivation rec{
  pname = "xlinkkai";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Team-XLink/releases/releases/download/v7.4.38/kaiEngine-7.4.38-539579851.headless.ubuntu.x86_64.tar.gz";
    sha256 = "0k2b7g3vm81dpr08kjsv7g85l4brljywv1gy7dm41v0z87vzi52r";
  };

  nativeBuildInputs = [ patchelf ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''

    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" kaiengine
    patchelf --set-rpath "$p:${stdenv.lib.makeLibraryPath [ stdenv.cc.cc ]}" kaiengine
    install -Dm755 kaiengine $out/bin/kaiengine
  '';

  #dontStrip = true;

  meta = with stdenv.lib; {
    broken = true;
    description = "tunneling program that allows the play LAN games online";
    homepage = https://www.teamxlink.co.uk;
    license = licenses.unfree;
    maintainers = with maintainers; [ genesis ];
    platforms = [ "x86_64-linux" ];
  };
}
