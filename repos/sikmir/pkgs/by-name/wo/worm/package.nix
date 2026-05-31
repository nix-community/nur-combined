{
  lib,
  stdenv,
  buildNimPackage,
  fetchFromGitHub,
  pkg-config,
  libx11,
  libxft,
  libxinerama,
}:

buildNimPackage rec {
  pname = "worm";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "codic12";
    repo = "worm";
    tag = "v${version}";
    hash = "sha256-DnmFDFVjya24e3PcIOa0nAeKfbfCgQ73sKaNGe4zErg=";
  };

  lockFile = ./lock.json;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxft
    libxinerama
  ];

  postInstall = ''
    install -Dm644 assets/worm.desktop -t $out/share/applications
  '';

  meta = {
    description = "A dynamic, tag-based window manager written in Nim";
    homepage = "https://github.com/codic12/worm";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
    broken = true;
  };
}
