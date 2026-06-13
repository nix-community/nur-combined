{
  cacert,
  cctools,
  copyDesktopItems,
  electron_41,
  extraEnv ? {
    LANG = "en_US.UTF-8";
    T3CODE_DISABLE_AUTO_UPDATE = 1;
    T3CODE_DISABLE_PROVIDER_UPDATE_CHECK = 1;
  },
  fetchFromGitHub,
  fetchPnpmDeps,
  installShellFiles,
  lib,
  libicns,
  makeBinaryWrapper,
  makeDesktopItem,
  nix-update-script,
  node-gyp,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  python3,
  stdenv,
  writableTmpDirAsHomeHook,
  writeDarwinBundle,
  xcbuild,
  enableAzureDevOps ? false,
  azure-cli,
  azure-cli-extensions,
  enableBitbucket ? false,
  bitbucket-cli,
  enableClaude ? false,
  claude-code,
  enableCodex ? false,
  codex,
  enableGitHub ? false,
  gh,
  enableGit ? false,
  git,
  enableGitLab ? false,
  glab,
  enableJujutsu ? false,
  jujutsu,
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    appName = "T3 Code (Alpha)";
    electron = electron_41;
    pnpm = pnpm_10;
    desktopIcon =
      if stdenv.hostPlatform.isDarwin then
        "assets/prod/black-macos-1024.png"
      else
        "assets/prod/black-universal-1024.png";
    runtimePackages =
      lib.optionals enableAzureDevOps [
        azure-cli.withExtensions
        [ azure-cli-extensions.azure-devops ]
      ]
      ++ lib.optionals enableBitbucket [ bitbucket-cli ]
      ++ lib.optionals enableClaude [ claude-code ]
      ++ lib.optionals enableCodex [ codex ]
      ++ lib.optionals enableGitHub [ gh ]
      ++ lib.optionals enableGit [ git ]
      ++ lib.optionals enableGitLab [ glab ]
      ++ lib.optionals enableJujutsu [ jujutsu ];
    runtimePathWrapperArgs = lib.optionalString (runtimePackages != [ ]) ''
      \
        --prefix PATH : ${lib.makeBinPath runtimePackages}
    '';
    extraEnvWrapperArgs = lib.escapeShellArgs (
      lib.concatLists (
        lib.mapAttrsToList (name: value: [
          "--set"
          name
          (toString value)
        ]) extraEnv
      )
    );
  in
  {
    pname = "t3code";
    version = "0.0.27";
    strictDeps = true;
    __structuredAttrs = true;
    NIX_SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    NODE_EXTRA_CA_CERTS = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    SYSTEM_CERTIFICATE_PATH = "${cacert}/etc/ssl/certs/ca-bundle.crt";

    src = fetchFromGitHub {
      owner = "merrkry";
      repo = "t3code";
      rev = "16cbcbd415ecdd1055c41063242eab5543042487";
      hash = "sha256-El6hbvjz/ejpnkPQCvSVekUJ/vy2n7oYbfBoEPpvJL8=";
    };

    postPatch = ''
      substituteInPlace apps/web/vite.config.ts \
        --replace-fail 'const host = process.env.HOST?.trim() || "localhost";' \
                       'const host = process.env.HOST?.trim() || "127.0.0.1";'
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname src;
      inherit pnpm;
      fetcherVersion = 3;
      hash = "sha256-suN0BPR6tK+ZH2oFOZxhr3m3ZZrDflp0r8Btt26xC2Y=";
    };

    nativeBuildInputs = [
      cacert
      git
      installShellFiles
      makeBinaryWrapper
      node-gyp
      nodejs
      pnpm
      pnpmConfigHook
      python3
      writableTmpDirAsHomeHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cctools.libtool
      libicns
      writeDarwinBundle
      xcbuild
    ];

    configurePhase = ''
      runHook preConfigure

      # pnpmConfigHook is registered as a postConfigure hook and populates
      # node_modules from pnpmDeps. The remaining configure steps patch and
      # rebuild selected installed dependencies.
      runHook postConfigure

      chmod --recursive u+rwX node_modules
      patchShebangs node_modules

      # Upstream bumps package.json versions after tagging releases, then applies
      # the same bump in the release workflow before building artifacts.
      node scripts/update-release-package-versions.ts ${finalAttrs.version}

      pnpm exec vp config
      pnpm exec effect-tsgo patch

      # Compile node-pty's native addon. pnpm installs with lifecycle scripts
      # disabled for reproducibility, so run node-pty's install steps manually.
      export npm_config_nodedir=${nodejs}
      nodePtyPackageJson="$(node --eval "process.stdout.write(require.resolve('node-pty/package.json', { paths: [process.cwd() + '/apps/server'] }))")"
      cd "$(dirname "$nodePtyPackageJson")"
      node-gyp rebuild
      node scripts/post-install.js
      cd -
    '';

    buildPhase = ''
      runHook preBuild

      pnpm run build:desktop

      runHook postBuild
    '';

    # pnpm vendors prebuilt native artifacts for non-host platforms, and some
    # of those binaries are statically linked. Let fixup handle wrappers,
    # shebangs, and stripping, but skip patchelf on the vendored tree.
    dontPatchELF = true;
    # The tmpdir audit hook also shells out to patchelf while scanning every
    # vendored ELF for leaked build paths. That produces spurious warnings on
    # static foreign-platform binaries.
    noAuditTmpdir = true;

    installPhase = ''
      runHook preInstall

      mkdir --parents "$out"/libexec/t3code/apps/desktop "$out"/libexec/t3code/apps/server
      cp --recursive --no-preserve=mode node_modules "$out"/libexec/t3code
      cp --recursive --no-preserve=mode apps/server/node_modules "$out"/libexec/t3code/apps/server
      cp --recursive --no-preserve=mode apps/desktop/node_modules "$out"/libexec/t3code/apps/desktop
      cp --recursive --no-preserve=mode apps/server/dist "$out"/libexec/t3code/apps/server
      cp --recursive --no-preserve=mode apps/desktop/dist-electron "$out"/libexec/t3code/apps/desktop

      mkdir --parents "$out"/libexec/t3code/apps/desktop/prod-resources
      install --mode=444 ${desktopIcon} \
        "$out"/libexec/t3code/apps/desktop/prod-resources/icon.png

      find "$out"/libexec/t3code -xtype l -delete

      makeWrapper ${lib.getExe nodejs} "$out"/bin/t3code ${extraEnvWrapperArgs} \
        --add-flags "$out"/libexec/t3code/apps/server/dist/bin.mjs ${runtimePathWrapperArgs}

      makeWrapper ${lib.getExe electron} "$out"/bin/t3code-desktop ${extraEnvWrapperArgs} \
        --add-flags "$out"/libexec/t3code/apps/desktop/dist-electron/main.cjs \
        --inherit-argv0 ${runtimePathWrapperArgs}
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir --parents "$out/Applications/${appName}.app/Contents/"{MacOS,Resources}
      png2icns \
        "$out/Applications/${appName}.app/Contents/Resources/t3code.icns" \
        ${desktopIcon}

      # writeDarwinBundle is a shebangless bash script; run it explicitly via
      # stdenv.shell to avoid Darwin's intermittent ENOEXEC fallback issues.
      ${stdenv.shell} ${lib.getExe writeDarwinBundle} \
        "$out" "${appName}" t3code-desktop t3code
    ''
    + ''
      mkdir --parents \
        "$out"/share/icons/hicolor/scalable/apps
      install --mode=444 ${desktopIcon} \
        "$out"/share/icons/t3code.png
      install --mode=444 assets/prod/logo.svg \
        "$out"/share/icons/hicolor/scalable/apps/t3code.svg

      runHook postInstall
    '';

    postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      for shell in bash fish zsh; do
        installShellCompletion --cmd t3code --"$shell" <("$out/bin/t3code" --completions "$shell")
      done
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "t3code";
        desktopName = appName;
        comment = "Minimal web GUI for coding agents";
        exec = "t3code-desktop %U";
        terminal = false;
        icon = "t3code";
        startupWMClass = "t3code";
        categories = [ "Development" ];
      })
    ];

    passthru = {
      inherit (finalAttrs) pnpmDeps;
      updateScript = nix-update-script {
        extraArgs = [
          "--subpackage"
          "pnpmDeps"
        ];
      };
    };

    meta = {
      description = "Minimal web GUI for coding agents";
      homepage = "https://t3.codes";
      downloadPage = "https://t3.codes/download";
      changelog = "https://github.com/pingdotgg/t3code/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [
        iamanaws
        qweered
      ];
      mainProgram = "t3code-desktop";
      inherit (nodejs.meta) platforms;
    };
  }
)
