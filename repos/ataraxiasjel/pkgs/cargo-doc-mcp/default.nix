{
  lib,
  stdenv,
  fetchPnpmDeps,
  fetchFromGitHub,
  nodejs_24,
  pnpm_11,
  pnpmConfigHook,
  makeBinaryWrapper,
  cargo,
  rustc,
  nix-update-script,
}:
let
  nodejs = nodejs_24;
  pnpm = pnpm_11.override { inherit nodejs; };
  src = fetchFromGitHub {
    owner = "spacemeowx2";
    repo = "cargo-doc-mcp";
    rev = "109dcc82d69379abe90f4521b1567564abfbf7b8";
    hash = "sha256-PiGFhkFC9sYdfH4wjLlOUWkNEKAeI6+Fejv40QnT5XM=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit src;

  pname = "cargo-doc-mcp";
  version = "0-unstable-2025-03-19";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-h6cbBh0LxCU99gItqd+qfmWCoqQuTeYRnyKUU6zfte8=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm prune --prod --ignore-scripts

    mkdir -p $out/lib/cargo-doc-mcp
    cp -r build node_modules package.json $out/lib/cargo-doc-mcp/

    makeWrapper ${nodejs}/bin/node $out/bin/cargo-doc-mcp \
      --add-flags "$out/lib/cargo-doc-mcp/build/index.js" \
      --prefix PATH : ${
        lib.makeBinPath [
          cargo
          rustc
        ]
      }

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "A MCP server for managing Rust documentation through cargo doc commands";
    homepage = "https://github.com/spacemeowx2/cargo-doc-mcp";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "cargo-doc-mcp";
  };
})
