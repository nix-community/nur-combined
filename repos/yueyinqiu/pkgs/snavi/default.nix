{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
}:

buildDotnetModule (finalAttrs: {
  pname = "snavi";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "yueyinqiu";
    repo = "Snavi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TA/MUSjoe5mknXxqkW8jpcgpoC7164mhoR4Ansx7tRM=";
  };

  projectFile = "src/Snavi/Snavi.csproj";
  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  nugetDeps = ./deps.nix;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "A navi-like interactive command-line cheatsheet tool but it's more safe with structured cheat file and CSharp script support.";
    homepage = "https://github.com/yueyinqiu/Snavi";
    license = lib.licenses.mit;
    mainProgram = "Snavi";
    maintainers = [ ];
  };
})
