{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libconfig,
  meson,
  ninja,
}:

stdenv.mkDerivation {
  pname = "socketcand";
  version = "0.6.1-unstable-2025-05-21";

  src = fetchFromGitHub {
    owner = "linux-can";
    repo = "socketcand";
    rev = "6dd5d33d4645ab221e8cd265c08607366e21ddf1";
    hash = "sha256-Pvh0lowK3mQLRu+TotjZS75bwztNvbY7rC3gZUSdjVA=";
  };

  nativeBuildInputs = [
    installShellFiles
    meson
    ninja
  ];

  buildInputs = [ libconfig ];

  postInstall = ''
    installManPage $src/socketcand.1
  '';

  meta = {
    description = "Server to access CAN sockets over ASCII protocol";
    homepage = "https://github.com/linux-can/socketcand";
    license = with lib.licenses; [
      gpl2Only
      bsd3
    ];
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
