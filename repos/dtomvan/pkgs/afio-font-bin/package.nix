{
  lib,
  stdenv,
  fetchzip,
}:
let
  version = "0.0.13";
  isRc = true;
  versionTag = "v${version}${if isRc then "-rc" else ""}";
in
stdenv.mkDerivation rec {
  pname = "afio-font";
  inherit version;

  src = fetchzip {
    url = "${meta.homepage}/releases/download/${versionTag}/afio-v${version}.zip";
    hash = "sha256-9CU9zwxure1XvKdqqX/WSx3IHWtntlyAq7Zrlwxla2o=";
    stripRoot = false;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    dst_truetype=$out/share/fonts/truetype/afio/
    find -name \*.ttf -exec mkdir -p $dst_truetype \; -exec cp -vp {} $dst_truetype \;

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Custom slimmed down Iosevka font with nerd-font icons";
    homepage = "https://github.com/awnion/custom-iosevka-nerd-font";
    # License unspecified
    # https://github.com/awnion/custom-iosevka-nerd-font/issues/3
    license = "unfree";
    platform = lib.platforms.all;
    maintainers = with lib.maintainers; [ dtomvan ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
  };
}
