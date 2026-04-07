{
  lib,
  fetchFromGitHub,
  mkYaziPlugin,
}:
mkYaziPlugin rec {
  pname = "preview-epub.yazi";
  version = "0-unstable-2026-04-07";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "9e81637d107db080b9ade9e4af53515460e592d8";
    hash = "sha256-dKVk72MNkqvoUT4fVIWvik1wKOpXVMj99oCe444XHi4=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    description = "cover of `.epub` files";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/preview-epub.yazi";
    license = lib.licenses.gpl3Only;
  };
}
