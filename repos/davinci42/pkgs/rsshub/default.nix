{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nix-update-script,
  callPackage,
  nodejs_24,
  pnpm_10,
  pnpmConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rsshub";
  version = "2026.10.10-8410.c3dfdf4";

  src = fetchFromGitHub {
    owner = "DIYgod";
    repo = "RSSHub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MudCxIYKejMR94Ez5bWN7xcuHy5cDsPF3vHjpPEuCis=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-yOd7b9yH7QF1pyWq0mIpbdh3JyLe1dwW1jlYCjy0YwU=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    nodejs_24
    pnpm_10
    pnpmConfigHook
  ];

  postPatch = ''
    substituteInPlace lib/registry.ts \
      --replace-fail 'import { registerApiRoutes, registerRssRoutes }' \
        'import { applyModulesToNamespaces, registerApiRoutes, registerRssRoutes }' \
      --replace-fail "import { isWorker } from '@/utils/is-worker';" \
        "import { isWorker } from '@/utils/is-worker'; import { directoryImport } from '@/utils/directory-import';" \
      --replace-fail 'if (config.isPackage) {' 'if (process.env.BUILD_ROUTES_MODE) {
        applyModulesToNamespaces(await directoryImport({
          targetDirectoryPath: path.join(__dirname, "./routes"),
          importPattern: /\.tsx?$/,
        }), namespaces);
      } else if (config.isPackage) {'
    cat > lib/utils/git-hash.ts <<'EOF'
    const gitHash = '${lib.last (lib.splitString "." (lib.last (lib.splitString "-" finalAttrs.version)))}';
    const gitDate = new Date('${
      lib.replaceStrings [ "." ] [ "-" ] (builtins.head (lib.splitString "-" finalAttrs.version))
    }T00:00:00Z');
    export { gitDate, gitHash };
    EOF
  '';

  buildPhase = ''
    runHook preBuild
    BUILD_ROUTES_MODE=1 pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib/rsshub/lib
    cp -r dist node_modules $out/lib/rsshub/
    cp -r lib/assets $out/lib/rsshub/lib/
    makeWrapper ${lib.getExe nodejs_24} $out/bin/rsshub \
      --set NODE_ENV production \
      --set-default NO_LOGFILES true \
      --add-flags "$out/lib/rsshub/dist/index.mjs"
    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {
      attrPath = "rsshub";
      extraArgs = [
        "-f"
        "."
        "--use-github-releases"
      ];
    };
    tests.packaging = callPackage ../../tests/pkgs/rsshub.nix {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "RSS feed generator";
    homepage = "https://github.com/DIYgod/RSSHub";
    license = lib.licenses.agpl3Only;
    mainProgram = "rsshub";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
})
