{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  bun,
  autoPatchelfHook,
}:

buildNpmPackage rec {
  pname = "ax";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "yusukebe";
    repo = "ax";
    rev = "v${version}";
    hash = "sha256-RsRO2WOp4J/SETJa+7FjbaA5PHIW9xmXbQmeN4fBWJM=";
  };

  npmDepsHash = "sha256-THoHXEySkrkWZh0lj/KbepudL3f7vGZHErh+ap2M/J4=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs =
    [ bun ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      autoPatchelfHook
    ];

  dontNpmBuild = true;

  buildPhase = ''
    runHook preBuild

    bun build src/index.ts --compile --outfile ax

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 ax $out/bin/ax

    runHook postInstall
  '';

  meta = {
    description = "The AI-era curl";
    homepage = "https://github.com/yusukebe/ax";
    license = lib.licenses.mit;
    mainProgram = "ax";
    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
