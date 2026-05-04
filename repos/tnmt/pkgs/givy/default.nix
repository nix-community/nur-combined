{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  nix-update-script,
}:

let
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "hokaccha";
    repo = "givy";
    rev = "v${version}";
    hash = "sha256-BbApYzugK3LDaPOliaCaVvFrQKV36stMOO78tiEFEng=";
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    pname = "givy-frontend";
    inherit version src;

    sourceRoot = "${src.name}/frontend";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_10
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src sourceRoot;
      pnpm = pnpm_10;
      fetcherVersion = 2;
      hash = "sha256-DNsOnoRLWJPCarOXHaKR4XyqPyE7PQWykm1cFDLtM/o=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  });
in
buildGoModule {
  pname = "givy";
  inherit version src;

  vendorHash = "sha256-0XTUCcMbACSSWvcX56Bdy+d+U6pFtqG9iS0Csc0UKZI=";

  subPackages = [ "." ];

  postPatch = ''
    mkdir -p frontend/dist
    cp -r ${frontend}/* frontend/dist/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/hokaccha/givy/cmd.Version=v${version}"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Local GitHub-like git viewer with a web UI";
    homepage = "https://github.com/hokaccha/givy";
    license = lib.licenses.mit;
    mainProgram = "givy";
    maintainers = [ ];
  };
}
