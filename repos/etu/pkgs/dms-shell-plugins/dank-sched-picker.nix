{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dank-sched-picker";
  version = "1.5.0-unstable-2026-06-30";

  src = fetchFromGitHub {
    owner = "SK-DEV-AI";
    repo = "dankSchedPicker";
    rev = "5d9d6063d58cf5f33e8fb36fd19acb7bd05c678d";
    hash = "sha256-fXuTV6YnKNaUBeskPJh9KHUNx4exrO1u9V93MmNFayg=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell DankBar widget to switch CPU schedulers (sched-ext) and power profiles, supporting all 12 scx schedulers and 5 power modes; requires scx_loader";
    homepage = "https://github.com/SK-DEV-AI/dankSchedPicker";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
