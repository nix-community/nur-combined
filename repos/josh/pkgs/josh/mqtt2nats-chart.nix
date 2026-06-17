{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation {
  name = "mqtt2nats-chart";
  inherit (nur.repos.josh.mqtt2nats) src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/mqtt2nats/* $out/
  '';

  meta = {
    description = "A Helm chart for mqtt2nats";
    homepage = "https://github.com/josh/mqtt2nats/tree/main/charts/mqtt2nats";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
