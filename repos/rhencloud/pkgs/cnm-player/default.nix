{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  openssl,
  chromaprint,
  dbus,
  makeWrapper,
  cava,
}:

rustPlatform.buildRustPackage rec {
  pname = "cnm-player";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "professor-lee";
    repo = "CNMPlayer";
    rev = "v${version}";
    hash = "sha256-bjYW981d53mxLvLrectpQ7gZArKKqFV71x5JbzmIy1g=";
  };

  cargoHash = "sha256-acgl/zQPT+retjd7dpUBOOyYrE/VEtK4NMZHsp/02SE=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    openssl
    chromaprint
    dbus
  ];

  postInstall = ''
    wrapProgram $out/bin/cnmplayer \
      --prefix PATH : ${lib.makeBinPath [ cava ]}
  '';

  meta = with lib; {
    description = "A command-line music player for NetEase Cloud Music";
    homepage = "https://github.com/professor-lee/CNMPlayer";
    license = licenses.gpl3Only;
    mainProgram = "cnmplayer";
  };
}
