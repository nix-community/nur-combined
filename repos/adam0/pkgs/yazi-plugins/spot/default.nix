{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot.yazi";
  version = "0-unstable-2026-06-21";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "4949660fad5bf2e34688677dda89a04242869861";
    hash = "sha256-elCSaxL76a1XrgwEgesKqsVqQy7u15vdLtGVr1j6cMA=";
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
