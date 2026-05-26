{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "preview-epub.yazi";
  version = "0-unstable-2026-05-25";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "70a03f39f9f8da08c71f539dd926de6956c6f738";
    hash = "sha256-S5uAGimtuSvPFqF4oIkuV0q56c0DYDTyJgQZCvkhj5g=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "cover of `.epub` files";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/preview-epub.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
