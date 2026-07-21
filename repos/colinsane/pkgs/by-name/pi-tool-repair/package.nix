{
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  lib,
  nix-update-script,
  nodejs,
  pnpm,
  pnpmConfigHook,
}:
buildNpmPackage (finalAttrs: {
  pname = "pi-tool-repair";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "monotykamary";
    repo = "pi-tool-repair";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B98sZ5pbp2tSXu1qz46IUlY92ingxQbhQsBF171WNyk=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-y7HljhPm5/jpSJw8AfjDiqrbG/09eB6vw2sWwpMIvC0=";
  };
  npmConfigHook = pnpmConfigHook;

  nativeBuildInputs = [
    nodejs
    pnpm
    # pnpmConfigHook
  ];

  dontNpmBuild = true;  # no build action in package.json

  postInstall = ''
    mv $out/lib/node_modules/pi-tool-repair/* $out
    rmdir $out/lib/node_modules/pi-tool-repair
    rmdir $out/lib/node_modules
    rmdir $out/lib
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Validate-then-repair Pi extension for malformed LLM tool calls";
    homepage = "https://github.com/monotykamary/pi-tool-repair";
    maintainers = with lib.maintainers; [ colinsane ];
    license = lib.licenses.mit;
  };
})
