{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  git,
  juceCmakeHook,
  libjack2,
}:
stdenv.mkDerivation {
  pname = "monique";
  version = "Nightly-unstable-2024-07-30";
  src = fetchFromGitHub {
    owner = "surge-synthesizer";
    repo = "monique-monosynth";
    rev = "df7d3395bce862847d40237350d0161a463dcc0d";
    hash = "sha256-NhqcMXGKiMKEQt730aCmL+a5kiOjFH8gUUrS1cDX0ss=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    juceCmakeHook
    git
  ];

  buildInputs = [
    libjack2
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Monique monosynth";
    homepage = "https://github.com/surge-synthesizer/monique-monosynth";
    license = with lib.licenses; [
      gpl3Plus
      mit
    ];
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
    broken = true;
  };
}
