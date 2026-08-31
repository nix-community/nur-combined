{
  fetchFromGitHub,
  lib,
  unstableGitUpdater,
  stdenv,
  libftdi,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xvcd";
  version = "0-unstable-2019-11-20";
  src = fetchFromGitHub {
    owner = "RHSResearchLLC";
    repo = "xvcd";
    rev = "d42b07f70cffd9e53f41c33b3960e1474cfbfc04";
    hash = "sha256-ke2Ct+ganBHh+Res0NHGfQiLhyacbXnczN6R8DIT3RA=";
  };
  sourceRoot = "source/linux";

  buildInputs = [ libftdi ];

  installPhase = ''
    runHook preInstall

    install -Dm755 bin/xvcd $out/bin/xvcd

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/RHSResearchLLC/xvcd";
    hardcodeZeroVersion = true;
  };
  meta = {
    mainProgram = "xvcd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Xilinx Virtual Cable Daemon";
    homepage = "https://github.com/RHSResearchLLC/xvcd";
    license = lib.licenses.cc0;
  };
})
