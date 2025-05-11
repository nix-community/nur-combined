{
  lib,
  stdenv,
  fetchFromGitHub,
  zig,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zon2nix-unstable";
  version = "0.1.2-unstable-2025-03-20";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "zon2nix";
    rev = "2360e358c2107860dadd340f88b25d260b538188";
    hash = "sha256-89hYzrzQokQ+HUOd3g4epP9jdajaIoaMG81SrCNCqqU=";
  };

  nativeBuildInputs = [
    zig.hook
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    mainProgram = "zon2nix";
    description = "Convert the dependencies in `build.zig.zon` to a Nix expression";
    homepage = "https://github.com/nix-community/zon2nix";
    changelog = "https://github.com/nix-community/zon2nix/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    inherit (zig.meta) platforms;
  };
})
