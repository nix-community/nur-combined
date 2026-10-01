{ lib
, rustPlatform
, makeWrapper
, clipnotify
, wl-clipboard
, xclip
, sources
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
  # Upstream publishes neither tags nor releases; nvfetcher tracks the branch
  # tip and exposes its UTC commit date.
  version = "0-unstable-${sources.linuxqq-clipsync.date}";

  src = sources.linuxqq-clipsync.src;

  # The lock file is extracted from the fetched revision and its git
  # dependencies are re-hashed by nvfetcher, so it cannot go stale.
  cargoLock = sources.linuxqq-clipsync.cargoLock."Cargo.lock";

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
