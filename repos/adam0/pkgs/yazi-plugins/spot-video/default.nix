{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-video.yazi";
  version = "0-unstable-2026-06-02";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "6206bae4c7887915db1cdf3b353a044578763195";
    hash = "sha256-xTYYLbrqb1cZeQzaWPzldBfpx3r5s2XyeRTYBA8jbq4=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "video metadata";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-video.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
