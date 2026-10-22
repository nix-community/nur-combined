{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-image.yazi";
  version = "0-unstable-2026-10-22";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "72bdb41827b389b346db91a3bfe5cb114399c932";
    hash = "sha256-tNI1SpI146BufWeC+hZXEgSPl5elzNgdJNs/P3F9PX8=";
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
