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
  version = "git-d139e54";

  src = fetchFromGitHub {
    owner = "SHORiN-KiWATA";
    repo = "linuxqq-clipsync";
    rev = "d139e5455ec0578c722b8ed312e7d73e952bb093";
    hash = "sha256-lh1stFaRD88gVo7rtYtEgBtHz824ySsCHBlhkYH/Ymg=";
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
