{ lib
, rustPlatform
, fetchFromGitHub
, makeWrapper
, clipnotify
, wl-clipboard
, xclip
}:

let
  runtimeDependencies = [
    clipnotify
    wl-clipboard
    xclip
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "linuxqq-clipsync";
  version = "git-cbbca25";

  src = fetchFromGitHub {
    owner = "SHORiN-KiWATA";
    repo = "linuxqq-clipsync";
    rev = "cbbca254f6dad6155bf55236a195f5343cddbe25";
    hash = "sha256-ztbtsCCxA4qKEE9/qprcxbbbfD4uG70DAeLKzezLIxQ=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram "$out/bin/linuxqq-clipsync" \
      --prefix PATH : ${lib.makeBinPath runtimeDependencies}
  '';

  passthru = {
    inherit runtimeDependencies;
  };

  meta = {
    description = "Synchronize X11 and Wayland clipboards for Linux QQ";
    homepage = "https://github.com/SHORiN-KiWATA/linuxqq-clipsync";
    license = lib.licenses.mit;
    mainProgram = "linuxqq-clipsync";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
