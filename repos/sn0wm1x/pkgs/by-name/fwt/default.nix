{
  lib,
  buildNpmPackage,
  fetchurl,
  nix-update-script,
}:
let
  version = "0.0.6";
  lockFile = builtins.toFile "fwt-package-lock.json" (
    builtins.toJSON {
      name = "@moeru-ai/fwt";
      inherit version;
      lockfileVersion = 3;
      requires = true;
      packages."" = {
        name = "@moeru-ai/fwt";
        inherit version;
        license = "Apache-2.0";
        bin.fwt = "dist/bin.js";
      };
    }
  );
in
buildNpmPackage rec {
  pname = "fwt";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@moeru-ai/fwt/-/fwt-${version}.tgz";
    hash = "sha512-SEWxaGysTDiXpRsJyLahic4oJXKrLnJHTAq3LzhLpa9MT3jbQbMvYCdalZi7zmD0AkB6uYThCtEMcO0YN3PHTQ==";
  };

  postPatch = ''
    cat > package.json <<'EOF'
    {"name":"@moeru-ai/fwt","version":"${version}","type":"module","license":"Apache-2.0","bin":{"fwt":"dist/bin.js"}}
    EOF
    cp ${lockFile} package-lock.json
    mkdir -p node_modules
  '';

  npmDepsHash = "sha256-EV7dQRq5nt6OahSo31bpTC2bCBQc3A6eVQm/N/XLC+g=";
  forceEmptyCache = true;
  dontNpmBuild = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--url"
      "https://github.com/moeru-ai/fwt"
    ];
  };

  meta = {
    description = "Subagent harness, featherweight";
    homepage = "https://github.com/moeru-ai/fwt";
    license = lib.licenses.asl20;
    mainProgram = "fwt";
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ kwaa ];
  };
}
