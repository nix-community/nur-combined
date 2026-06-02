{
  lib,
  stdenvNoCC,
  nur,
}:
stdenvNoCC.mkDerivation {
  name = "jmap2nats-chart";
  inherit (nur.repos.josh.jmap2nats) src;

  buildCommand = ''
    mkdir $out
    cp -R $src/charts/jmap2nats/* $out/
  '';

  meta = {
    description = "A Helm chart for jmap2nats";
    homepage = "https://github.com/josh/jmap2nats/tree/main/charts/jmap2nats";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
