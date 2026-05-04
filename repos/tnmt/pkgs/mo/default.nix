{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  go_1_26,
  jq,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  nix-update-script,
}:

let
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "k1LoW";
    repo = "mo";
    rev = "v${version}";
    hash = "sha256-ALozRRSjcQzOR3CM4m9ouuoUBgbNTsLLVgVG+2PhRKQ=";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "mo-frontend";
    inherit version src;

    # Vite writes to `../static/dist` (relative to `internal/frontend`),
    # so the build needs the full source tree, not just the frontend
    # subdirectory.
    sourceRoot = "${src.name}";

    nativeBuildInputs = [
      jq
      nodejs
      pnpmConfigHook
      pnpm_10
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 2;
      sourceRoot = "${src.name}/internal/frontend";
      hash = "sha256-bjVW04Tm7sy+N690b9JjI4HlVJ9tjla+V16MIpr8nAA=";
    };

    pnpmRoot = "internal/frontend";

    # `pnpm.executionEnv.nodeVersion` makes pnpm fetch Node from
    # nodejs.org at build time, which fails inside the Nix sandbox.
    # Strip it before pnpm runs so it uses the Nix-provided nodejs.
    postPatch = ''
      jq 'del(.pnpm.executionEnv)' internal/frontend/package.json > internal/frontend/package.json.tmp
      mv internal/frontend/package.json.tmp internal/frontend/package.json
    '';

    buildPhase = ''
      runHook preBuild
      cd internal/frontend
      pnpm build
      cd ../..
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r internal/static/dist $out
      runHook postInstall
    '';
  });
in
(buildGoModule.override { go = go_1_26; }) {
  pname = "mo";
  inherit version src;

  vendorHash = "sha256-Q1POssns162x8M2Gz+e9h+jbZO6oNuN8n3HDhiqmOKQ=";

  subPackages = [ "." ];

  postPatch = ''
    mkdir -p internal/static/dist
    cp -r ${frontend}/* internal/static/dist/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/k1LoW/mo/version.Revision=v${version}"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Markdown viewer that opens .md files in a browser";
    homepage = "https://github.com/k1LoW/mo";
    license = lib.licenses.mit;
    mainProgram = "mo";
    maintainers = [ ];
  };
}
