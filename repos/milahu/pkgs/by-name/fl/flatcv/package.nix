{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flatcv";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "ad-si";
    repo = "FlatCV";
    tag = "v${finalAttrs.version}";
    hash = "sha256-07Kl0w4/OeuHI82Mz+IJm/fAgZeS9uBsDQR0q9vyEZI=";
  };

  preBuild = ''
    # the default install location is $HOME/.local/bin/flatcv
    export HOME=$TMP
    mkdir -p $HOME/.local/bin
  '';

  # NOTE the actual build runs in installPhase

  postInstall = ''
    mkdir -p $out/bin
    cp -v $HOME/.local/bin/flatcv $out/bin
  '';

  meta = {
    description = "Image processing and computer vision library in pure C";
    homepage = "https://github.com/ad-si/FlatCV";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "flatcv";
    platforms = lib.platforms.all;
  };
})
