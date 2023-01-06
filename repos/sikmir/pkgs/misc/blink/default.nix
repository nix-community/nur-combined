{ lib, stdenv, fetchFromGitHub, fetchurl }:

let
  testdata = import ./testdata.nix { inherit fetchurl; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "blink";
  version = "2023-01-06";

  src = fetchFromGitHub {
    owner = "jart";
    repo = "blink";
    rev = "312fbb3a1bd868de5763a2ebe6a6a199ad7c164a";
    hash = "sha256-Yjpd8+R8QlH3L8IoVOX7xbANvc8vUwVhDmC7Vzyh+oM=";
  };

  postPatch = ''
    substituteInPlace third_party/cosmo/cosmo.mk --replace "curl" "#curl"
  '';

  postInstall = ''
    mkdir -p $out/bin
    install -Dm755 o//blink/{blink,blinkenlights} $out/bin
  '';

  doCheck = true;

  preCheck = lib.concatMapStringsSep "\n" (data: ''
    ln -s ${data} third_party/cosmo/2/${data.name}
  '') testdata;

  meta = with lib; {
    description = "tiniest x86-64-linux emulator";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.isc;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = true;
  };
})
