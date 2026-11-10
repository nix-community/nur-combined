{
  lib,
  stdenv,
  fetchpatch2,
  buildGo127Module,
  callPackage,
  gitMinimal,
  sources,
  source ? sources.cpa-usage-keeper,
}:

buildGo127Module (finalAttrs: {
  inherit (source) pname version src;

  patches = [
    (fetchpatch2 {
      url = "https://github.com/Willxup/cpa-usage-keeper/commit/9c41524c5184170c1093b81863686fd48529e216.patch?full_index=1";
      hash = "sha256-F5abyPJuV8YTy6h6uQRhCX5djmWLxVrKG6SgrOM8JE8=";
    })
  ];

  # nix-update auto
  vendorHash = "sha256-kUPQ41UsZX86WNdeYGy914G3Pk/v/WcOfVw8Unb9SE4=";

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

  nativeCheckInputs = [ gitMinimal ];

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
