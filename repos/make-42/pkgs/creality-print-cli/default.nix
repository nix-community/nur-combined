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
    rev = "5c2fdea304c8ee55cfab464935a61fcff63920d6";
    hash = "sha256-TNrTvgJ4oGSaIC9iAOZvL7s+hEz06zLDYFcm0D/hEek=";
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
