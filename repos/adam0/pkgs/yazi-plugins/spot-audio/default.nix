{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-audio.yazi";
  version = "0-unstable-2026-05-03";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "6ced611361e7d4df504b2efbff1ff6fd59c9e90e";
    hash = "sha256-HwwlJK7qsAKhqKMCH6zW2DPOUaSu2Yrq5Y+whljjGGE=";
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
