{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-audio.yazi";
  version = "0-unstable-2026-08-29";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "5c1711e4ba6133a80be6d70501fb60bbef3b2af1";
    hash = "sha256-XxfPZeEWTr5Y6fqXtDOvg0cgUgL+XOmLK+N0k1E+JAA=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "audio metadata";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-audio.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
