{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  SDL2,
}:
stdenv.mkDerivation {
  pname = "celeste-classic";
  version = "unstable";

  src = fetchzip {
    url = "https://www.speedrun.com/static/resource/174ye.zip";
    hash = "sha256-GANHqKB0N905QJOLaePKWkUuPl9UlL1iqvkMMvw/CC8=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ SDL2 ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib}
    cp -r CELESTE $out/lib
    ln -s $out/lib/CELESTE/celeste $out/bin/celeste
    chmod +x $out/bin/celeste

    runHook postInstall
  '';

  meta = {
    mainProgram = "celeste";
  };
}
