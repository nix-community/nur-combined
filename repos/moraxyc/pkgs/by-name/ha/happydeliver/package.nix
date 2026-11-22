{
  lib,
  buildGoModule,
  callPackage,
  writableTmpDirAsHomeHook,
  versionCheckHook,
  oapi-codegen,

  sources,
  source ? sources.happydeliver,
}:

buildGoModule (finalAttrs: {
  inherit (source)
    pname
    version
    src
    vendorHash
    ;

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
    oapi-codegen
  ];
  ldflags = [
    "-s"
    "-X git.happydns.org/happyDeliver/internal/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/happyDeliver" ];

  preBuild = ''
    oapi-codegen -config api/config-models.yaml api/schemas.yaml
    oapi-codegen -config api/config-server.yaml api/openapi.yaml
    cp -r ${finalAttrs.passthru.frontend} web/build
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";

  passthru = {
    frontend = callPackage ./frontend.nix {
      inherit (finalAttrs) src version pname;
      inherit source;
      meta = lib.removeAttrs finalAttrs.meta [ "mainProgram" ];
    };
  };

  meta = {
    description = "Open-source, self-hosted email deliverability testing platform";
    homepage = "https://happydeliver.org";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "happyDeliver";
  };
})
