{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot.yazi";
  version = "0-unstable-2026-04-30";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "75f0c85e89942b42bffe0ac14e8d9e9112e3ba18";
    hash = "sha256-Bxkawt3V/4pRIm+9rF1BSaSi8WRywNU33QUsxO75WYE=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "framework to build your own spotter";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
