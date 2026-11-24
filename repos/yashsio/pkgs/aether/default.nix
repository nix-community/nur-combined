{
  lib,
  stdenvNoCC,
  fetchurl,
}:

let
  version = "0.5.1";
in
stdenvNoCC.mkDerivation {
  pname = "aether";
  inherit version;

  src = fetchurl {
    url = "https://github.com/yashsio/aether/releases/download/v${version}/aether-v${version}-linux-x86_64.tar.gz";
    hash = "sha256-UmKdBDQJiMbJ/NUdLQyisqQH3T8eB9zl16b0quyw3Fo=";
  };

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 "$src" "$out/bin/aether"
  '';

  meta = {
    description = "A minimal Wayland native image viewer";
    homepage = "https://github.com/yashsio/aether";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "aether";
  };
}
