{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "nix-fod-exporter";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "yueyinqiu";
    repo = "NixFodExporter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Q9nA1PrlbNLxCouGyL6iuro6whR07iK8R3VsoJSrTBU=";
    postFetch = ''
      rm -rf "$out/samples"
    '';
  };

  projectFile = "src/NixFodExporter/NixFodExporter.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  nugetDeps = ./deps.nix;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "Export fixed-output derivations from the Nix store into portable dumps with a restore script";
    homepage = "https://github.com/yueyinqiu/NixFodExporter";
    license = lib.licenses.mit;
    mainProgram = "NixFodExporter";
    maintainers = [ ];
  };
})
