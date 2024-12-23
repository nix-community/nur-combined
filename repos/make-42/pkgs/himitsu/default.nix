{
  stdenv,
  fetchurl,
  lib,
  pkgs,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "himitsu";
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
    repo = "himitsu";
    rev = "0f0b0694a23c7704c463b685c4b4fc45c192eeee";
    hash = "sha256-ZpGIHszAukOPviBuzfg/6BkijfHk/2/EK6eIxcb2EMo=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "A tiny command line 2FA TOTP client.";
    homepage = "https://github.com/make-42/himitsu";
    license = licenses.gpl3;
    maintainers = [];
    platforms = platforms.linux;
  };

  postInstall = ''
    wrapProgram "$out/bin/himitsu" \
    --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
      pkgs.pkg-config
    ]}
  '';
}
