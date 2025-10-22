{
  coreutils,
  python3,
  fortune,
  stdenv,
  fetchFromGitLab,
  lib,
  ...
}: let
  version = "2.98.1";
  pname = "fortune-mod-zh";
in
  stdenv.mkDerivation {
    inherit pname version;
    src = fetchFromGitLab {
      domain = "salsa.debian.org";
      owner = "chinese-team";
      repo = "fortunes-zh";
      rev = "debian/${version}";
      hash = "sha256-+i0Leyna+F/9vpPNSlVnShug2wLDPi8OpYSwkhW6z14=";
    };

    buildInputs = [fortune];
    nativeBuildInputs = [
      coreutils
      python3
      fortune
    ];
    buildPhase = ''
      runHook preBuild

      make chinese.dat
      make song100.dat
      make tang300.dat || exit 1

      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/fortune"
      install -m0644 tang300 "$out/share/fortune"
      install -m0644 tang300.dat "$out/share/fortune"
      install -m0644 song100 "$out/share/fortune"
      install -m0644 song100.dat "$out/share/fortune"
      install -m0644 chinese "$out/share/fortune"
      install -m0644 chinese.dat "$out/share/fortune"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Chinese ancient poetry fortune.";
      homepage = "https://github.com/shenyunhang/fortune-zh";
      platforms = fortune.meta.platforms;
      license = with licenses; [lgpl3];
      sourceProvenance = with sourceTypes; [fromSource];
    };
  }
