{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "herdr-plus";
  version = "0.1.16";

  src = fetchFromGitHub {
    owner = "cloudmanic";
    repo = "herdr-plus";
    rev = "v0.1.16";
    hash = "sha256-WWu83LMBB9V0OFF1g4qmIkoTqOgXgWeNynv4Fk84xas=";
  };

  vendorHash = "sha256-im2gPhLarMf1w/8rhxbOe9EhUdvseffukT9tqU4EEXI=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X internal/version.Version=0.1.16"
  ];

  postInstall = ''
    mkdir -p $out/share/cloudmanic.herdr-plus/bin
    cp herdr-plugin.toml $out/share/cloudmanic.herdr-plus/herdr-plugin.toml
    cp $out/bin/herdr-plus $out/share/cloudmanic.herdr-plus/bin/herdr-plus
  '';

  meta = {
    description = "Herdr plugin that adds projects and quick actions";
    homepage = "https://github.com/cloudmanic/herdr-plus";
    license = lib.licenses.mit;
    mainProgram = "herdr-plus";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
