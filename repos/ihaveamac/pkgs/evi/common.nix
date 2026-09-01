{
  lib,
  fetchFromGitea,
  stdenv,
}:
rec {
  version = "original-v9.1.0-unstable-2026-08-28";

  outputs = [
    "out"
    "xxd"
  ];

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "evi-editor";
    repo = "evi";
    rev = "2297ea26c53a50122f6e7b1a989128b5de91c09d";
    hash = "sha256-9ay7bbafKVm4mmb1wMx6ClbtKRVr61DWfltEu22exnc=";
  };

  enableParallelBuilding = true;
  enableParallelInstalling = false;

  hardeningDisable = if stdenv.cc.isClang then [ "strictflexarrays1" ] else [ "fortify" ];

  # Use man from $PATH; escape sequences are still problematic.
  postPatch = ''
    substituteInPlace runtime/ftplugin/man.vim \
      --replace "/usr/bin/man " "man "
  '';

  # man page moving is done in postFixup instead of postInstall otherwise fixupPhase moves it right back where it was
  postFixup = ''
    moveToOutput bin/xxd "$xxd"
    moveToOutput share/man/man1/xxd.1.gz "$xxd"
    for manFile in $out/share/man/*/man1/xxd.1*; do
      # moveToOutput does not take full paths or wildcards...
      moveToOutput "share/man/$(basename "$(dirname "$(dirname "$manFile")")")/man1/xxd.1.gz" "$xxd"
    done
  '';

  meta = {
    description = "EVi, a hard-fork of Vim v9.1.0 (Jan 2024) before AI was used in the project";
    homepage = "https://codeberg.org/evi-editor/evi";
    license = lib.licenses.vim;
    platforms = lib.platforms.unix;
    mainProgram = "vim";
    outputsToInstall = [
      "out"
      "xxd"
    ];
  };
}
