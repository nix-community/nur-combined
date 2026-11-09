{
  lib,
  buildGoModule,
  fetchFromGitHub,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "gh-actions-lock";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-actions-lock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9jU5NmBFZayhOX8ifc+aMDhaIQ4XVPlLI/dPUoQuzNw=";
  };

  vendorHash = "sha256-MS0GDAo/COikI5LwfgNPR83MhY6fAFg+Lpmzkv86X3M=";

  postPatch = ''
    substituteInPlace cmd/gh-actions-lock/run.go \
      --replace-fail 'return info.Main.Version' 'return "v${finalAttrs.version}"'
  '';

  subPackages = [ "cmd/gh-actions-lock" ];

  __darwinAllowLocalNetworking = true;

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "gh CLI extension that generates and verifies the GitHub Actions dependency lockfile";
    homepage = "https://github.com/github/gh-actions-lock";
    changelog = "https://github.com/github/gh-actions-lock/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "gh-actions-lock";
  };
})
