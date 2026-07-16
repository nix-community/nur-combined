{
  buildGoModule,
  lib,
  fetchFromGitHub,
  installShellFiles,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "restish";
  version = "2.3.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rest-sh";
    repo = "restish";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tI4o+zkKNnFrqWFEHsNt2+03Luth9KHH+x7P+WwaGNI=";
  };

  vendorHash = "sha256-Y0GwgrkD09WAlmyI6Oe3Kw6L62E7QRTCIThZGXbbn74=";

  ldflags = ["-s" "-w" "-X main.version=${finalAttrs.version}"];

  nativeBuildInputs = [installShellFiles];

  nativeCheckInputs = [writableTmpDirAsHomeHook];

  checkFlags = let
    skippedTests = [
      "TestAPISyncDiscoveryDoesNotSendAuthToCrossOriginLinkSpec"
    ];
  in ["-skip=^(${lib.concatStringsSep "|" skippedTests})$"];

  postInstall = ''
    installShellCompletion --cmd restish \
      --bash <($out/bin/restish shell completion bash) \
      --fish <($out/bin/restish shell completion fish) \
      --zsh <($out/bin/restish shell completion zsh)
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "A CLI for interacting with REST-ish HTTP APIs with some nice features built-in";
    longDescription = ''
      Restish is a CLI for working with REST-ish HTTP APIs.
      It can make generic HTTP requests, discover OpenAPI descriptions, generate API-aware commands,
      manage profiles and auth, render structured output, follow pagination links, and run plugins.
    '';
    homepage = "https://rest.sh/";
    changelog = "https://github.com/danielgtaylor/restish/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "restish";
  };
})
