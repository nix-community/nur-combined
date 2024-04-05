{
  lib,
  buildGoModule,
  fetchFromGitHub,
  ...
}: let
  pname = "lilipod";
  version = "0.0.2-dev";

in buildGoModule rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "89luca89";
    repo = pname;
    rev = "1a9914399f9b250d605a4eaf7f55d33c3d084981";
    hash = "sha256-u10TgNd/2xGmtTng6FUxv2o3ax/8xQfdTI7ElhnBBcE=";
  };

  buildPhase = ''
    make
  '';

  installPhase = ''
    ls
    mkdir -p      $out/bin
    mv pty.tar.gz $out/bin
    mv lilipod    $out/bin
  '';

  vendorHash = null; #"sha256-6hCgv2/8UIRHw1kCe3nLkxF23zE/7t5RDwEjSzX3pBQ=";

  meta = with lib; {
    description = " Lilipod is a simple container manager, able to download, unpack and use OCI images from various container registries.";
    homepage = "https://github.com/89luca89/lilipod";
    license = licenses.gpl3;
  };
}
