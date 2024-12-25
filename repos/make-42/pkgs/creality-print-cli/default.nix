{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "creality-print-cli";
  version = "0.0.1";

  buildInputs = with pkgs; [
    gcc
    go
    pkg-config
  ];

  nativeBuildInputs = with pkgs; [pkg-config makeWrapper];

  subPackages = ["."];

  src = fetchFromGitHub {
    owner = "make-42";
    repo = "creality-print-cli";
    rev = "dcbfaaa91effa05b6344f6985cb998a817ae074f";
    hash = "sha256-WgPKy1L8396Agd1+OCzO0eQjueToWKJ5Q3Fe8mT0e1w=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "A simple TUI for monitoring prints over LAN for a Creality printer ";
    homepage = "https://github.com/make-42/creality-print-cli";
    license = licenses.gpl3;
    maintainers = [];
    platforms = platforms.linux;
  };

  postInstall = ''
    wrapProgram "$out/bin/creality-print-cli" \
    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      pkgs.pkg-config
    ]}
  '';
}
