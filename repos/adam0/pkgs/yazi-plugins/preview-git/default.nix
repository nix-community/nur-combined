{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "preview-git.yazi";
  version = "0-unstable-2026-10-04";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "28eea47c4c9fefb73fc8d80b5c63f1b301afbf0c";
    hash = "sha256-KqoM4hi/VUq3BLs2MFBLhbvHgvntooYsjnYA+3DatVM=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "showing git info by hovering over `.git/` directory";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/preview-git.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
