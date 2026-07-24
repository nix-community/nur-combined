{
  lib,
  stdenv,
  buildGoModule,
  callPackage,
  sources,
  source ? sources.cpa-usage-keeper,
}:

buildGoModule (finalAttrs: {
  inherit (source) pname version src;

  # nix-update auto
  vendorHash = "sha256-aPHZro8Qwy5ptgudMgnfpcktwyVVZTi+XMrr0RTtl6k=";

  ldflags = [
    "-s"
    "-X cpa-usage-keeper/internal/version.Version=v${finalAttrs.version}"
  ];

  preBuild = ''
    rm -rf web/dist
    cp -r ${finalAttrs.passthru.frontend} web/dist
  '';

  postInstall = ''
    mv $out/bin/{server,cpa-usage-keeper}
  '';

  __darwinAllowLocalNetworking = true;

  checkFlags =
    let
      skippedTests = [
        "TestNewClientTLSSkipVerify"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  passthru = {
    frontend = callPackage ./frontend.nix {
      inherit source;
      meta = lib.removeAttrs finalAttrs.meta [ "mainProgram" ];
    };
  };

  meta = {
    description = "Dashboard / Standalone Cli-Proxy-API usage tracker with SQLite persistence and built-in dashboard";
    homepage = "https://github.com/Willxup/cpa-usage-keeper";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "cpa-usage-keeper";
    broken = stdenv.hostPlatform.isLoongArch64;
  };
})
