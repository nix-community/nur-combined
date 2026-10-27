{
  lib,
  stdenvNoCC,
  fetchzip,
  makeWrapper,
  nodejs_24,
  openssl,
}:

stdenvNoCC.mkDerivation rec {
  pname = "portless";
  version = "0.15.12";

  # The npm tarball ships a prebuilt bundle with no runtime dependencies;
  # the GitHub source is a pnpm monorepo that would need a full build.
  src = fetchzip {
    url = "https://registry.npmjs.org/portless/-/portless-${version}.tgz";
    hash = "sha256-WeraRlX9zAIa7mqoIY4e0Pa3rFhhTKmulMoKgWNTD6A=";
  };

  nativeBuildInputs = [ makeWrapper ];

  # openssl generates the local CA; sudo/security etc. come from the system.
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/portless $out/bin
    cp -r . $out/lib/portless
    makeWrapper ${lib.getExe nodejs_24} $out/bin/portless \
      --add-flags $out/lib/portless/dist/cli.js \
      --suffix PATH : ${lib.makeBinPath [ openssl ]}
    runHook postInstall
  '';

  meta = {
    description = "Replace port numbers with stable, named .localhost URLs";
    homepage = "https://github.com/vercel-labs/portless";
    license = lib.licenses.asl20;
    mainProgram = "portless";
  };
}
