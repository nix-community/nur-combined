{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  jq,
  nix-update-script,
}:

buildDotnetModule (finalAttrs: {
  pname = "dotnet-verify";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "VerifyTests";
    repo = "Verify.Terminal";
    tag = "${finalAttrs.version}";
    hash = "sha256-4jvOA02dt+GTsfh+Td/59+3jiHV62mZgTx6fxJOIMJU=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  projectFile = [ "src/Verify.Terminal/Verify.Terminal.csproj" ];
  testProjectFile = [ "src/Verify.Terminal.Tests/Verify.Terminal.Tests.csproj" ];
  nugetDeps = ./deps.json;
  dotnetFlags = [
    "-p:TargetFramework=net10.0"
  ];

  postPatch = ''
    # Use the SDK selected by nixpkgs. This keeps dependency regeneration
    # working when upstream pins a newer feature band in global.json.
    jq --arg version "${dotnetCorePackages.sdk_10_0.version}" \
      '.sdk.version = $version' \
      global.json > global.json.tmp
    mv global.json.tmp global.json
  '';

  nativeBuildInputs = [ jq ];

  postFixup = ''
    mv "$out/bin/Verify.Terminal" "$out/bin/dotnet-verify"
  '';

  MINVERVERSIONOVERRIDE = finalAttrs.version;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ ];
    };
  };

  meta = {
    description = "A dotnet tool for managing Verify snapshots";
    homepage = "https://github.com/VerifyTests/Verify.Terminal";
    license = lib.licenses.mit;
    mainProgram = "dotnet-verify";
  };
})
