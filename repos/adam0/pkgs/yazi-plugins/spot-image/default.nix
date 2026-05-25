{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-image.yazi";
  version = "0-unstable-2026-05-24";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "0d4d58ac42595e7cee18f48f4914ac716f2d5d90";
    hash = "sha256-ngdciAAolVbi7naGDzFUbJzCRljcYOlu93G5Z8Q3g0Q=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "image metadata and exif";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-image.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
