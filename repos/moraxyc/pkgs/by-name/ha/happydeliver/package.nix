{
  lib,
  buildGoModule,
  callPackage,
  writableTmpDirAsHomeHook,
  versionCheckHook,

  sources,
  source ? sources.happydeliver,
}:

buildGoModule (finalAttrs: {
  inherit (source) pname version src;

  proxyVendor = true;
  # nix-update auto
  vendorHash = "sha256-JiWSBYoZ2b+44LtfK+meB6SE9hZpR7I9X/Two1EthGQ=";

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  ldflags = [
    "-s"
    "-X git.happydns.org/happyDeliver/internal/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/happyDeliver" ];

  preBuild = ''
    go generate ./...
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
