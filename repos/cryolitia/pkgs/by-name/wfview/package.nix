{
  lib,
  stdenv,
  callPackage,
  fetchFromGitLab,
  eigen,
  hidapi,
  libopus,
  libpulseaudio,
  portaudio,
  qt6,
  rtaudio,
}:

let
  qcustomplot = callPackage ./qcustomplot.nix { };
in
stdenv.mkDerivation (finalAttr: {
  pname = "wfview";
  version = "2.10";

  src = fetchFromGitLab {
    owner = "eliggett";
    repo = "wfview";
    rev = "v${finalAttr.version}";
    hash = "sha256-bFTblsDtFAakbSJfSfKgvoxd1DTSv++rxU6R3/uWo+4=";
  };

  patches = [
    # Remove syscalls during build to make it reproducible
    # We also need to adjust some header paths for darwin
    ./remove-hard-encodings.patch
  ];

  buildInputs = (
    [
      eigen
      hidapi
      libopus
      portaudio
      rtaudio
      qcustomplot
    ]
    ++ (with qt6; [
      qtbase
      qtserialport
      qtmultimedia
      qtwebsockets
    ])
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libpulseaudio
    ]
  );

  nativeBuildInputs = with qt6; [
    wrapQtAppsHook
    qmake
  ];

  env.LANG = "C.UTF-8";

  qmakeFlags = [ "wfview.pro" ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -pv $out/Applications 
    mv -v "$out/bin/wfview.app" $out/Applications 

    # wrap executable to $out/bin 
    makeWrapper "$out/Applications/wfview.app/Contents/MacOS/wfview" "$out/bin/wfview"
  '';

  meta = {
    description = "Open-source software for the control of modern Icom radios";
    homepage = "https://wfview.org/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ Cryolitia ];
  };
})
