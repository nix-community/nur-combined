{
  lib,
  stdenvNoCC,
  fetchurl,
  variant ? "8-0-4-1",
}:

assert builtins.elem variant [
  "8-0-4-1"
  "16-0-4-1"
];

stdenvNoCC.mkDerivation rec {
  pname = "fsrcnnx-x2-${variant}";
  version = "1.1";

  src = fetchurl {
    url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/${version}/FSRCNNX_x2_${variant}.glsl";
    sha256 =
      {
        "8-0-4-1" = "sha256-6ADbxcHJUYXMgiFsWXckUz/18ogBefJW7vYA8D6Nwq4=";
        "16-0-4-1" = "sha256-1aJKJx5dmj9/egU7FQxGCkTCWzz393CFfVfMOi4cmWU=";
      }
      .${variant};
  };

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/fsrcnnx/FSRCNNX_x2_${variant}.glsl

    runHook postInstall
  '';

  meta = with lib; {
    description = "An implementation of the Fast Super-Resolution Convolutional Neural Network in TensorFlow";
    homepage = "https://github.com/igv/FSRCNN-TensorFlow";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [ lunik1 ];
    platforms = platforms.all;
  };
}
