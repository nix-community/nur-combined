{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  cutefish-toolkit,
  icu,
  pcre2,
  libxkbcommon,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-terminal";
  version = cu.version "2026-10-22";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "terminal";
    rev = "bd1d32202d66899d5ba0af55f00d871cc8d9b32c";
    hash = "sha256-4dEgfbaxOij/iv2QGyPzGrjZVbuS1Qmv20kF7OWuppI=";
  };

  postPatch = ''
    substituteInPlace cutefish-terminal.desktop \
      --replace-fail 'Exec=/usr/bin/cutefish-terminal' 'Exec=cutefish-terminal'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    pcre2
    libxkbcommon
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "Terminal emulator for the Cutefish desktop";
    license = with lib.licenses; [
      gpl3Plus
      gpl2Plus
      bsd3
    ];
    mainProgram = "cutefish-terminal";
  };
}
