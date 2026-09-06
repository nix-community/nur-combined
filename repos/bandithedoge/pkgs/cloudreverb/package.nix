{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  pname = "cloudreverb";
  version = "0.5-unstable-2026-09-05";
  src = fetchFromGitHub {
    owner = "xunil-cloud";
    repo = "CloudReverb";
    rev = "9b913eab82255f4e52da56109d92c2910a291e8a";
    hash = "sha256-qiK9TiKk4+rq2e2JfwPYUqM24fwVqGScvtzzYt7mKoA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ juceCmakeHook ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "algorithmic reverb plugin based on CloudSeed";
    homepage = "https://github.com/xunil-cloud/CloudReverb";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "CloudReverb";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
