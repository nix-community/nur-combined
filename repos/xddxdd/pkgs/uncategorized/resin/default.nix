{
  lib,
  sources,
  buildGoModule,
  buildNpmPackage,
}:

let
  frontendDist = buildNpmPackage (finalAttrs: {
    pname = "${sources.resin.pname}-webui";
    inherit (sources.resin) version src;

    sourceRoot = "source/webui";

    npmDepsHash = "sha256-HM1+bcEry9BY39xt7qUgRwnNfXwyfBJyUeFAPosrnKU=";

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist/* $out/
      runHook postInstall
    '';
  });
in
buildGoModule (finalAttrs: {
  inherit (sources.resin) pname version src;

  vendorHash = "sha256-iLZRA3n3Rn5sGxDUNg9+C8XmGDVBLyn/ceZ84/NRyLg=";

  proxyVendor = true;

  tags = [
    "with_quic"
    "with_wireguard"
    "with_grpc"
    "with_utls"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Resinat/Resin/internal/buildinfo.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/resin" ];

  preBuild = ''
    rm -rf webui/dist
    mkdir -p webui/dist
    cp -r ${frontendDist}/* webui/dist/
  '';

  meta = {
    mainProgram = "resin";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "High-performance intelligent proxy pool gateway with sticky sessions";
    homepage = "https://github.com/Resinat/Resin";
    license = lib.licenses.mit;
  };
})
