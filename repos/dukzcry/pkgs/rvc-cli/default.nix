{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages, gnused, ffmpeg, callPackage
}:

let
  noisereduce = callPackage ./noisereduce.nix {};
  pedalboard = callPackage ./pedalboard.nix {};
  local-attention = callPackage ./local-attention.nix {};
in stdenv.mkDerivation rec {
  pname = "rvc-cli";
  version = "unstable-2024-12-01";

  src = fetchFromGitHub {
    owner = "blaisewf";
    repo = "rvc-cli";
    rev = "7ad2fa8226c3bfdd3315441f2b61cb5a7f6eeae1";
    hash = "sha256-hOwyjECgtDjEp7uBWorANS5jqM/P1IcnVyq+R1T2pFA=";
  };

  nativeBuildInputs = with python3Packages; [ wrapPython gnused ];

  installPhase = ''
    sed -i '1s;^;#!/usr/bin/env python3\n;' rvc_cli.py
    substituteInPlace rvc_cli.py \
      --replace-fail "os.path.join(\"rvc\"" "os.path.join(\"$out/${python3Packages.python.sitePackages}/rvc\"" \
      --replace-fail "os.path.join(current_script_directory, \"logs\")" "\"logs\""

    mkdir -p $out/${python3Packages.python.sitePackages} $out/share
    cp -r rvc $out/${python3Packages.python.sitePackages}
    cp -r logs $out/share
    install -Dm755 rvc_cli.py $out/bin/rvc_cli
  '';

  pythonPath = with python3Packages; [
    distutils tqdm requests torch numpy matplotlib librosa tensorboard wget beautifulsoup4
    pydub transformers ffmpeg sympy noisereduce pedalboard torchcrepe faiss einops local-attention
  ];
  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out $pythonPath"
  '';

  meta = {
    description = "RVC + UVR = A perfect set of tools for voice cloning, easily and free";
    homepage = "https://github.com/blaisewf/rvc-cli";
    license = lib.licenses.cc-by-nc-40;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "rvc_cli";
    platforms = lib.platforms.all;
  };
}
