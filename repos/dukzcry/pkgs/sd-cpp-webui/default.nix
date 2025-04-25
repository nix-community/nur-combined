{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages, stable-diffusion-cpp, which, pciutils
}:

stdenv.mkDerivation rec {
  pname = "sd-cpp-webui";
  version = "unstable-2025-02-22";

  src = fetchFromGitHub {
    owner = "daniandtheweb";
    repo = "sd.cpp-webui";
    rev = "9ded8d67e90fa80f1b55334001069623d1ec2e13";
    hash = "sha256-3eHiYi6RLxXGZFbIJxulJBRRHIBm+BfWRjKHD9MvqQU=";
  };

  nativeBuildInputs = with python3Packages; [ wrapPython ];

  patches = [
    ./fix-gallery.patch
  ];

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
