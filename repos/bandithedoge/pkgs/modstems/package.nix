{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  libopenmpt,
  meson,
  ninja,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "modstems";
  version = "0-unstable-2024-08-20";
  src = fetchFromGitHub {
    owner = "bandithedoge";
    repo = "modstems";
    rev = "9a1b68176f4b10d1676723a36678788cf2790c1a";
    hash = "sha256-Ffp6/CWNxf2L43cvTkZE9k35pScYsMF7UXh8IG721pw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    libopenmpt.dev
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Dumps \"stems\" from module files using libopenmpt ";
    homepage = "https://github.com/bandithedoge/modstems";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "modstems";
  };
}
