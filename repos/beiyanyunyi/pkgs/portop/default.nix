{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:

let
  source = lib.importJSON ./source.json;
in
buildGoModule (finalAttrs: {
  pname = "portop";
  inherit (source) version vendorHash;

  src = fetchFromGitHub {
    inherit (source) owner repo rev;
    hash = source.narHash;
  };

  subPackages = [ "cmd/portop" ];
  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X github.com/padovanl/portop/internal/cli.Version=${finalAttrs.version}"
  ];

  checkPhase = ''
    runHook preCheck
    # Tests scan all listening ports; concurrent package tests create and close
    # sockets that would appear as unrelated drift in TestBaselineSaveThenDiff.
    # Serialize packages while retaining the complete Linux test suite.
    # Darwin's build sandbox cannot inspect processes through system ps/lsof.
    # Keep all other tests, and run the complete suite on Linux.
    go test -p 1 ./... ${lib.optionalString stdenv.hostPlatform.isDarwin "-skip '^(TestCollectFindsRealListener|TestCollectIsSafeForConcurrentCalls|TestRunJSONFindsRealListener|TestRunJSONFilterByPort|TestRunComposeAuditJSON|TestBaselineSaveThenDiff|TestConfigSuppliesFlagDefault|TestExplicitFlagOverridesConfig|TestProcessCommands|TestWebProcessActions|TestDarwinLoadCurrentProcess|TestDarwinLiveSocketsAndOwnership)$'"}
    runHook postCheck
  '';

  meta = {
    description = "Terminal UI for inspecting TCP and UDP ports and their owners";
    homepage = "https://github.com/padovanl/portop";
    license = lib.licenses.mit;
    mainProgram = "portop";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
