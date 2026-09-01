{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
  pandoc,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-markdown-preview";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "omaclaren";
    repo = "pi-markdown-preview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mtAwvOYlYA7Wd55ID6XIhWvz7css0CPMABOowksYS3o=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-eN72MfapupdoR0XlsJptZT/amst5MYdVKWKjTueHnVQ=";

  propagatedBuildInputs = [
    pandoc
  ];

  dontNpmBuild = true;  # package.json defines no build script

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Rendered markdown + LaTeX preview for pi, with terminal, browser, and PDF output";
    homepage = "https://github.com/omaclaren/pi-markdown-preview";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
