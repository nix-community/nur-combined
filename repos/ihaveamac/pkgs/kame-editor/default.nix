{
  lib,
  callPackage,
  stdenv,
  fetchFromGitLab,
  kame-tools,
  rstmcpp,
  qt6,
  portaudio,
  #vgmstream,
  apple-sdk_11,
}:

let
  vgmstream = callPackage ./vgmstream.nix { };
in
stdenv.mkDerivation rec {
  pname = "kame-editor";
  version = "1.4.1-unstable-2025-06-04";

  src = fetchFromGitLab {
    owner = "beelzy";
    repo = pname;
    rev = "21a48fc0d09d7b87cac59454d879bc1d54de356e";
    hash = "sha256-cPGnQHJNh7eavc4xlclAV1b+Ahg3p0Cnj7Sbz3xzj48=";
  };

  postPatch = ''
    substituteInPlace kame-editor.pro \
      --replace-fail "/usr/local/bin/" "$out/bin/" \
      --replace-fail "/usr/local" "/non-existant"
  '';

  qtWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        kame-tools
        vgmstream
        rstmcpp
      ]
    }"
    # even adding qt6.qtwayland doesn't make wayland work for some reason i'm not sure of yet
  ]
  ++ (lib.optional (!stdenv.isDarwin) "--set WAYLAND_DISPLAY \"\"");

  buildInputs = [
    qt6.qtbase
    portaudio
  ]
  ++ lib.optional stdenv.isDarwin apple-sdk_11;
  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir $out/Applications
    mv $out/bin/kame-editor.app $out/Applications/kame-editor.app
    ln -s $out/Applications/kame-editor.app/Contents/MacOS/kame-editor $out/bin/kame-editor
  '';

  meta = with lib; {
    description = "GUI frontend for kame-tools; makes custom 3DS themes.";
    homepage = "https://beelzy.gitlab.io/kame-editor/";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    mainProgram = "kame-editor";
  };
}
