{
  lib,
  stdenv,
  fetchFromGitHub,
  writeShellScriptBin,

  meson,
  ninja,
  pkg-config,
  sqlite,
  wayland,
  wayland-scanner,
  xxhash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cclip";
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "heather7283";
    repo = "cclip";
    tag = finalAttrs.version;
    hash = "sha256-rjDCYag0aG9mZuwzWNS5z/CzeEtpdjc9iMypKqIZK60=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    (writeShellScriptBin "git" ''
      if [ "$#" -eq 2 ] && [ "$1" = branch ] && [ "$2" = --show-current ]; then
        echo "master (Nixpkgs)"
      fi
      if [ "$#" -eq 2 ] && [ "$1" = rev-parse ] && [ "$2" = HEAD ]; then
        echo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
      fi
    '')
  ];

  buildInputs = [
    sqlite
    wayland
    xxhash
  ];

  meta = {
    description = "Clipboard manager for wayland";
    homepage = "https://github.com/heather7283/cclip";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "cclip";
    platforms = lib.platforms.linux;
  };
})
