{
  lib,
  stdenv,
  fetchurl,
  undmg,
  ...
}:
stdenv.mkDerivation
rec {
  pname = "raycast";
  version = "1.44.0";

  src = fetchurl {
    curlOpts = "-L";
    url = "https://api.raycast.app/v2/download";
    sha256 = "sha256-30Mtx5uclmLW9/nRragPKKBlQ8lrMEx3jMqvJTHerYs=";
    name = "Raycast-${version}.dmg";
  };

  outputs = ["out"];

  nativeBuildInputs = [undmg];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r *.app $out/Applications
  '';

  meta = with lib; {
    description = "";
    homepage = "https://www.raycast.com/";
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    license = licenses.unfreeRedistributable;
    platforms = ["aarch64-darwin" "x86_64-darwin"];
    maintainers = with maintainers; [berryp];
  };
}