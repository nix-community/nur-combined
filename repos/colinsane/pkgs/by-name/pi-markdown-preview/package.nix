{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
  pandoc,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-markdown-preview";
  version = "0.21.4";

  src = fetchFromGitHub {
    owner = "omaclaren";
    repo = "pi-markdown-preview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+T13yDYPqg1R1XDZGgXDOtC+kzWCzVRa2NYL6iXPxaQ=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-UZWyXRGtnK3RAFSWgya083xmM/duzi1uUY4G6f63g7I=";

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
