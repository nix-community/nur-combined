{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
  pandoc,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-markdown-preview";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "omaclaren";
    repo = "pi-markdown-preview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5c63d3+kenP/4AZub1mVKU0bBZ+H+FklroiLBIwuyX0=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-1rS6jz5Q5hLwWwYn162AGW92f5vFTK2FS2X/ONd861o=";

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
