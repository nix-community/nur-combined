{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation {
  pname = "hammer-and-meiszel";
  version = "st-unstable-2025-10-10";
  src = fetchFromGitHub {
    owner = "Mrugalla";
    repo = "Hammer-and-Meiszel";
    rev = "8ab4654287809054a6e28a17c8d6bb4584f9f284";
    hash = "sha256-1tY/vGJnpxs+DVyALIZ6gja4/MhNXkLZLRFSgsaepXk=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "Projekt.jucer";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Keytracked polyphonic modal filter effect";
    homepage = "https://github.com/Mrugalla/Hammer-and-Meiszel";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
