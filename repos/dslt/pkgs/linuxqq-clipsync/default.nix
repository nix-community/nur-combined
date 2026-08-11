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
  version = "git-2451e01";

  src = fetchFromGitHub {
    owner = "SHORiN-KiWATA";
    repo = "linuxqq-clipsync";
    rev = "2451e01e51259134992355439b2c3eb8f6a48d96";
    hash = "sha256-zknlSToOq/ydrbvtmBP6HKgp+wcLS5SULpoHcx/Kldo=";
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
