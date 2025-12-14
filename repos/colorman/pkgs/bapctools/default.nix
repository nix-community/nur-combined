{
  python3,
  fetchFromGitHub,
  texliveMedium,
  lib,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "bapctools";
  version = "2025-03-03";

  src = fetchFromGitHub {
    owner = "RagnarGrootKoerkamp";
    repo = "BAPCtools";
    rev = "e6db717c46fc38d7baf0360f2e19c135868e0d71";
    hash = "sha256-yo0JkEJkPN1ayWodKYqXpqHmo+TnyEvw2IPxts1p5vw=";
  };

  propagatedBuildInputs = [
    (python3.withPackages (p:
      with p; [
        colorama
        pyyaml
        python-dateutil
        argcomplete
        ruamel-yaml
        matplotlib
        requests
        questionary
      ]))
    texliveMedium
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/bin/* $out/bin/
    cp -r $src/config $out/config
    cp -r $src/latex $out/latex

    install -Dm755 $src/bin/tools.py $out/bin/bt
  '';

  meta = {
    description = "Tools for developing ICPC-style programming contest problems.";
    homepage = "https://github.com/RagnarGrootKoerkamp/BAPCtools";
    mainProgram = "bt";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [TheColorman];
    inherit (python3.meta) platforms;
  };
}
