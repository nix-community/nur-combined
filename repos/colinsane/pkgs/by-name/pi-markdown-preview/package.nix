{
  fetchFromGitHub,
  lib,
  mkPiExtension,
  nix-update-script,
  pandoc,
}:
mkPiExtension (finalAttrs: {
  pname = "pi-markdown-preview";
  version = "0.19.2";

  src = fetchFromGitHub {
    owner = "omaclaren";
    repo = "pi-markdown-preview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-efC2dqeHjcnBlmgzrQuWJqCPzQqXTcF8RqzxLnGUXe4=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-JLWNAH3me6iFeUC/fms5yZY/WEF6ovjVWdPDcXKJZVk=";

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
