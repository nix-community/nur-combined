# FIXME why Google Firebase
# https://github.com/YouROK/TorrServer/issues/570

{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "torr-server";
  version = "136";

  src = fetchFromGitHub {
    owner = "YouROK";
    repo = "TorrServer";
    rev = "MatriX.${version}";
    hash = "sha256-b99ba25AFcunlC+TZoO1kM/krYow99z5XH0RyrZS3E0=";
  };

  sourceRoot = "source/server";

  vendorHash = "sha256-9PpY/fSwueCQlIEj5kTZkKP7gk1271wTAmbG9kDxSBQ=";

  ldflags = [ "-s" "-w" ];

  # fix: mem_test.go:46: open /build/source/server/rutor/rutor.ls: no such file or directory
  doCheck = false;

  postInstall = ''
    mv $out/bin/cmd $out/bin/torr-server
  '';

  meta = {
    description = "Torrent stream server";
    homepage = "https://github.com/YouROK/TorrServer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "torr-server";
    platforms = lib.platforms.all;
  };
}
