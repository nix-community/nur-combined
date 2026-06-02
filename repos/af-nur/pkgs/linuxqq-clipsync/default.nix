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
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "SHORiN-KiWATA";
    repo = "linuxqq-clipsync";
    rev = "ef51b206ff91376a121d4dbcb0d999579291c294";
    hash = "sha256-1i+P//j9tFwnvQwS/XUU5cuEfXS4cSEdttOjgsOOP50=";
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
