{
  lib,
  stdenv,
  fetchFromGitHub,
  python,
}:

python.pkgs.buildPythonApplication rec {
  pname = "voe-dl";
  version = "1.5.1";

  #pyproject = true;

  src =
  #if true then /home/user/src/p4ul17/voe-dl else
  fetchFromGitHub {
    owner = "p4ul17";
    repo = "voe-dl";
    /*
    rev = "v${version}";
    hash = "sha256-EoVMBhdnbk/3Q7qxLWAc2doM6LGcqGAqLB6tZz5gJkg=";
    */
    # https://github.com/p4ul17/voe-dl/pull/44
    rev = "3bf5f4caecae34c857ece01dec26017a322ad29c";
    hash = "sha256-dlCX0ZUGzOy0X8iUMA2KBRK4O3XI8ATbGx81QlYo5/4=";
  };

  propagatedBuildInputs = with python.pkgs; [
    requests
    beautifulsoup4
    yt-dlp
    wget
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    chmod +x dl.py
    cp dl.py $out/bin/voe-dl
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/voe-dl \
      --set PYTHONPATH "${python.pkgs.makePythonPath propagatedBuildInputs}"
  '';

  meta = {
    description = "A Python downloader for voe.sx videos";
    homepage = "https://github.com/p4ul17/voe-dl";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "voe-dl";
    platforms = lib.platforms.all;
  };
}
