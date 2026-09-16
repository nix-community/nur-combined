{
  fetchFromGitHub,
  zig_0_16,
  stdenv,
  lib
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fx";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "fx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3LV9d9bymKSGD/j46BTDsSHA/s1+fdfbx2ouY1czGpE=";
  };

  nativeBuildInputs = [
    zig_0_16
  ];

  buildPhase = ''
    runHook preBuild
    zig build -Doptimize=ReleaseSafe -Dcpu=baseline
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 zig-out/bin/fx $out/bin/fx
    runHook postInstall
  '';

  meta = {
    description = "Unix-like coding agent";
    homepage = "https://fx.sh";
    changelog = "https://github.com/vercel-labs/fx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [Prinky];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "fx";
  };
})
