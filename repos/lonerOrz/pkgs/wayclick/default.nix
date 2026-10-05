{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wayclick";
  version = "0.2.0-unstable-2026-10-04";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "wayclick";
    rev = "6f90ea84521260f4ce6a9cc5316deb6bae614657";
    hash = "sha256-wzFB6Rs0A6nV/7uvk2+Mne5N3NqQ2hAy5ATXU/f+5fc=";
  };

  cargoHash = "sha256-tYlI+hrsfcpK1yBPhlwWmWFWhreIJ8Xh3S1biXP5SfY=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
  ];

  postInstall = ''

    mkdir -p $out/share/wayclick
    cp -r $src/assets/default $out/share/wayclick/config
  '';

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Low-latency key click sound engine using evdev + pygame";
    homepage = "https://github.com/lonerOrz/wayclick";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "wayclick";
  };
})
