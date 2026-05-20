{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "preview-epub.yazi";
  version = "0-unstable-2026-05-19";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "bbeb314ed7fda5359c560f546b3a86c3d6579623";
    hash = "sha256-JU/QB9yBEWIoE45Q9lrLSKjZZ2eFdVrlCRWz2Gq4cvQ=";
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
