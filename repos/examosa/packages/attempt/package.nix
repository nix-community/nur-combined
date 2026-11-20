{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "attempt";
  version = "1.1.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "MaxBondABE";
    repo = "attempt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ixMz5ZFq2WvwBcVHaxHnKWxAFYZ+/8BSaejSlGTW9/Y=";
  };

  cargoHash = "sha256-hxk97/DNM0febIJLXido6ejM1y3is0yx9MqmbdnmT0s=";

  patches = [./tests.patch];

  postPatch = ''
    substituteInPlace src/main.rs tests/e2e.rs \
      --replace-fail '/bin/true' "$(type -P true)" \
      --replace-fail '/bin/false' "$(type -P false)"
  '';

  passthru.updateScript = nix-update-script {extraArgs = ["--use-github-releases"];};

  meta = {
    description = "CLI for retrying fallible commands";
    homepage = "https://maxbondabe.github.io/attempt/";
    changelog = "https://github.com/MaxBondABE/attempt/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.unlicense;
    maintainers = [lib.maintainers.examosa];
    mainProgram = "attempt";
    platforms = lib.platforms.all;
  };
})
