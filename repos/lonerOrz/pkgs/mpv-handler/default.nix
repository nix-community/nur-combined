{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  mpv,
  yt-dlp,
}:
rustPlatform.buildRustPackage rec {
  pname = "mpv-handler";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "akiirui";
    repo = "mpv-handler";
    rev = "v${version}";
    hash = "sha256-uWV9pjZp5s8H1UDS/T0JK//eJNnsaaby88l/tDqlQHY=";
  };

  cargoHash = "sha256-Cps+cPOv8uV8x0MiBdSqsdJ/8n259K6Y5aVl2aWJ/tE=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    mkdir -p $out/share/applications
    cp ${src}/share/linux/mpv-handler.desktop $out/share/applications/
    cp ${src}/share/linux/mpv-handler-debug.desktop $out/share/applications/
    cp ${src}/share/linux/config.toml $out/share/

    wrapProgram $out/bin/mpv-handler \
      --prefix PATH : ${
        lib.makeBinPath [
          mpv
          yt-dlp
        ]
      }
  '';

  meta = {
    description = "Play website videos and songs with mpv & yt-dlp.";
    homepage = "https://github.com/akiirui/mpv-handler";
    mainProgram = "mpv-handler";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    binaryNativeCode = true;
  };
}
