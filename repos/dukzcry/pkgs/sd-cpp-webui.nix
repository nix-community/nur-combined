{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages, stable-diffusion-cpp, which, pciutils
}:

stdenv.mkDerivation rec {
  pname = "sd-cpp-webui";
  version = "unstable-2024-12-04";

  src = fetchFromGitHub {
    owner = "daniandtheweb";
    repo = "sd.cpp-webui";
    rev = "5ea4fd22d5be9023ba49c1467eee1a3b03638a9e";
    hash = "sha256-4hoVGucC6+ObZuJWnMwNWLv2ytKG2cmqSWn8cGC8hnw=";
  };

  nativeBuildInputs = with python3Packages; [ wrapPython ];

  installPhase = ''
    mkdir -p $out/${python3Packages.python.sitePackages}
    cp -r modules $out/${python3Packages.python.sitePackages}
    install -Dm755 sdcpp_webui.py $out/bin/sdcpp_webui
  '';

  pythonPath = with python3Packages; [ gradio stable-diffusion-cpp which pciutils ];
  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out $pythonPath"
  '';

  meta = {
    description = "A simple webui for stable-diffusion.cpp";
    homepage = "https://github.com/daniandtheweb/sd.cpp-webui";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "sdcpp_webui";
    platforms = lib.platforms.all;
  };
}
