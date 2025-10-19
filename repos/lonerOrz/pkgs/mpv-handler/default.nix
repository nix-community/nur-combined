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
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "akiirui";
    repo = "mpv-handler";
    rev = "v${version}";
    hash = "sha256-QoctjneJA7CdXqGm0ylAh9w6611vv2PD1fzS0exag5A=";
  };

  cargoHash = "sha256-gKDkDLTLzC53obDd7pORsqP6DhORTbx6tvQ4jq61znQ=";

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
