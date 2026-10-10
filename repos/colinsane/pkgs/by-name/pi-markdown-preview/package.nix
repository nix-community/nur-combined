{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
  pandoc,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-markdown-preview";
  version = "0.21.3";

  src = fetchFromGitHub {
    owner = "omaclaren";
    repo = "pi-markdown-preview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qy8+SFzGuAV0M0K3qsvlQ/vz7LS9yGTMSn9BhWT94CQ=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-fuKmoPsrICwf2tMOxhTUPTGoGc2G0xPQ8EifYz7kdVk=";

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
