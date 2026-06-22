{
  buildGoModule,
  callPackage,

  picoclaw,
}:

buildGoModule (finalAttrs: {
  pname = "picoclaw-launcher";
  inherit (picoclaw)
    version
    src
    proxyVendor
    vendorHash
    ;

  goModules = picoclaw.goModules.overrideAttrs {
    name = "${finalAttrs.pname}-${finalAttrs.version}-go-modules";
  };

  subPackages = [ "web/backend" ];

  tags = [
    "goolm"
    "stdjson"
  ];

  ldflags = [
    "-s"
    "-X github.com/sipeed/picoclaw/pkg/config.Version=${finalAttrs.version}"
    "-X github.com/sipeed/picoclaw/pkg/config.GitCommit=${finalAttrs.src.rev or finalAttrs.version}"
    "-X github.com/sipeed/picoclaw/pkg/config.BuildTime=1970-01-01T00:00:00Z"
  ];

  preConfigure = ''
    cp -r ${finalAttrs.passthru.frontend} web/backend/dist
  '';

  postInstall = ''
    mv $out/bin/backend $out/bin/picoclaw-launcher
    install -Dm644 web/picoclaw-launcher.png \
      $out/share/icons/hicolor/256x256/apps/picoclaw-launcher.png
    install -Dm444 web/picoclaw-launcher.desktop -t $out/share/applications
  '';

  passthru = {
    # nix-update auto -sfrontend
    frontend = callPackage ./frontend.nix { };
  };

  meta = picoclaw.meta // {
    description = "Web-based configuration and management UI for PicoClaw";
    mainProgram = "picoclaw-launcher";
  };
})
