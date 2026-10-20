{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "preview-cbz.yazi";
  version = "0-unstable-2026-10-20";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "7d8ead5068dc8c4886870f6693095b5a6b802eb1";
    hash = "sha256-iuLVs+9zILr1VMCFwHEyWh/xx5u0KVWNPpE+EpL6uKo=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "comic books and manga";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/preview-cbz.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
