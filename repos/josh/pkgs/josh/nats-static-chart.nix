{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation {
  name = "nats-static-chart";
  inherit (nur.repos.josh.nats-static) src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/nats-static/* $out/
  '';

  meta = {
    description = "A Helm chart for nats-static";
    homepage = "https://github.com/josh/nats-static/tree/main/charts/nats-static";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
