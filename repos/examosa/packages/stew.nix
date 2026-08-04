{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
}:
buildGoModule (finalAttrs: {
  pname = "stew";
  version = "0.6.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "marwanhawari";
    repo = "stew";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ecmTvo01xbAui9YLeEaQ90/GM1aYmjS+Tae8cE95krU=";
  };

  vendorHash = null;

  ldflags = ["-s"];

  checkFlags = let
    skippedTests = [
      "Test_extractBinary"
      "Test_getGithubJSON"
      "Test_getGithubSearchJSON"
      "Test_readGithubJSON"
      "Test_readGithubSearchJSON"
      "TestDownloadFile"
      "TestNewGithubProject"
      "TestNewGithubSearch"
      "TestInstallBinary"
      "TestInstallBinary_Fail"
    ];
  in ["-skip=^(${lib.concatStringsSep "|" skippedTests})$"];

  passthru.updateScript = nix-update-script {};

  meta = {
    broken = stdenv.hostPlatform.isLinux;
    description = "An independent package manager for compiled binaries";
    homepage = "https://github.com/marwanhawari/stew";
    license = lib.licenses.mit;
    mainProgram = "stew";
  };
})
