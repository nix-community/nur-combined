{
  lib,
  stdenv,
  fetchFromGitHub,
  unstableGitUpdater,
  xclip,
  wl-clipboard,
  clipnotify,
  python3,
  makeWrapper,
  which
}:
stdenv.mkDerivation rec {
  name = "wl-x11-clipsync";
  version = "0-unstable-2025-01-30";

  pname = name;
  
  src = fetchFromGitHub {
    owner = "arabianq";
    repo = "wl-x11-clipsync";
    rev = "fc3ac4d1d57ffdc3222e818c8a58d20c91f3fcf3";
    hash = "sha256-Cez4ywJtOjHM1GVRuPvyOgwjftzHK3UyGCBw2VQkIrA=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ python3 ];

  installPhase = ''
    mkdir -p $out/share/wl-x11-clipsync
    cp ./clipsync.py $out/share/wl-x11-clipsync/clipsync
    chmod +x $out/share/wl-x11-clipsync/clipsync
    patchShebangs --host $out/share/wl-x11-clipsync/clipsync
    makeWrapper $out/share/wl-x11-clipsync/clipsync $out/bin/clipsync \
      --prefix PATH : "${lib.makeBinPath [ xclip wl-clipboard clipnotify which ]}"
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Python script synchronizes the clipboard between Wayland";
    homepage = "https://github.com/arabianq/wl-x11-clipsync";
    license = licenses.unlicense;
    platforms = platforms.linux;
    mainProgram = "clipsync";
  };
}

