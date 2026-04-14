{
  lib,
  stdenv,
  ccacheStdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
  davey,

  xclip,
  wl-clipboard,
  zenity,
  git,
  yt-dlp,
  mpv,
  libsecret,

  buildSystem ? "pyinstaller",
}:
let
  python3-env = (python3.withPackages (ps: with ps; ([
    av
    davey
    pillow
    pynacl
    emoji
    filetype
    numpy
    orjson
    protobuf
    pycryptodome
    pysocks
    python-socks
    qrcode
    soundcard
    soundfile
    urllib3
    websocket-client

    setuptools
    cython
  ]
  ++ (lib.optionals (buildSystem == "nuitka") [ nuitka ] )
  ++ (lib.optionals (buildSystem == "pyinstaller") [ pyinstaller ] )
  ++ (lib.optionals stdenv.hostPlatform.isLinux [
    psutil
  ])
  ++ (lib.optionals stdenv.hostPlatform.isDarwin [
    certifi
  ])
  )));

  buildCommand = {
    pyinstaller = ''
      ${lib.getExe' python3-env "python3"} -m PyInstaller \
        --onedir --hidden-import=uuid \
        --exclude-module=cython --exclude-module=zstandard \
        --collect-data=emoji --collect-data=soundcard \
    '' + (lib.optionalString stdenv.hostPlatform.isLinux ''
      --hidden-import=soundcard.pulseaudio \
    '') + ''
      --noconfirm --clean --name=endcord main.py
    '';
    nuitka = ''
      ${lib.getExe' python3-env "python3"} -m nuitka \
        --standalone \
        --python-flag=-OO --include-module=uuid \
        --nofollow-import-to=cython --nofollow-import-to=tkinter \
        --nofollow-import-to=zstandard --nofollow-import-to=google._upb \
        --include-package-data=emoji:unicode_codes/emoji.json \
        --include-package-data=soundcard \
        --include-module=av.sidedata.encparams \
        --remove-output --output-dir=dist --output-filename=endcord \
        main.py
    '';
  }.${buildSystem};

  installCommand = {
    pyinstaller = ''
      cp -r dist/endcord $out/endcord
    '';
    nuitka = ''
      cp -r dist/main.dist $out/endcord
    '';
  }.${buildSystem};
in
ccacheStdenv.mkDerivation rec {
  pname = "endcord";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "sparklost";
    repo = "endcord";
    tag = version;
    hash = "sha256-1CFr9Y/5qZfkTIOFBuN7MlvJsnmOp9JK/ZJB3INWxpY=";
  };

  propagatedBuildInputs = [
    zenity
    git
    yt-dlp
    mpv
    libsecret
  ] ++ (lib.optionals stdenv.hostPlatform.isLinux [
    xclip
    wl-clipboard
  ]);

  buildInputs = [
    python3-env
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    ${buildCommand}
    ls -R dist

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin

    ${installCommand}
    makeWrapper $out/endcord/endcord $out/bin/endcord

    runHook postInstall
  '';

  meta = {
    description = "Feature rich Discord TUI client";
    homepage = "https://github.com/sparklost/endcord";
    changelog = "https://github.com/sparklost/endcord/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "endcord";
  };
}
