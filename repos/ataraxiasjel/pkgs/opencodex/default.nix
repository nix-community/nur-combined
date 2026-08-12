{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  bun,
  versionCheckHook,
}:

let
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "lidge-jun";
    repo = "opencodex";
    rev = "v${version}";
    hash = "sha256-IZLVVUbVRirOwNmPRyr/3VI1zE0c85TaAHEoOgi+iwg=";
  };

  packageLock = ./package-lock.json;
  guiPackageLock = ./gui-package-lock.json;

  gui = buildNpmPackage {
    pname = "opencodex-gui";
    inherit version src;

    # The repo keeps frontend sources in gui/; the fetched tree's top dir is src.name.
    sourceRoot = "${src.name}/gui";

    npmDepsHash = "sha256-BvFAFT3Gegf759AdZIlO5s6aKQSFji1282UGKnT2Xo0=";

    # npmConfigHook requires a package-lock.json at the source root; the repo
    # only ships bun.lock, so vendored lockfile is copied in.
    postPatch = ''
      cp ${guiPackageLock} package-lock.json
    '';

    # `npm run build` = `tsc -b && vite build`, producing dist/.
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r dist $out/
      runHook postInstall
    '';

    meta = {
      description = "opencodex web dashboard (static build)";
    };
  };
in

buildNpmPackage {
  pname = "opencodex";
  inherit version src;

  npmDepsHash = "sha256-xHJUGAwUbK7Q5uMTMI75Z4/MUHX/fdnCo1Z4S0s6WY8=";

  # The root has no `build` script; TS runs directly under Bun.
  dontNpmBuild = true;

  # prepack runs `bun run prepare:package`; skip it.
  npmPackFlags = [ "--ignore-scripts" ];

  postPatch = ''
    cp ${packageLock} package-lock.json
    # The bundled `bun` npm dep is unused (OPENCODEX_BUN_PATH takes precedence) and
    # its postinstall fails offline; strip it from package.json to match the lockfile.
    # awk (not node) so this also runs under fetchNpmDeps's stdenvNoCC.
    awk '!/"bun":/' package.json > package.json.tmp && mv package.json.tmp package.json
  '';

  # Make the built dashboard visible to npm pack (files: [...] includes gui/dist).
  preInstall = ''
    mkdir -p gui
    cp -r ${gui}/dist gui/dist
  '';

  postFixup = ''
    wrapProgram $out/bin/ocx \
      --set OPENCODEX_BUN_PATH ${lib.getExe bun} \
      --prefix PATH : ${lib.makeBinPath [ bun ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Universal provider proxy for OpenAI Codex & Claude Code";
    longDescription = ''
      Use any LLM (Claude, Gemini, Grok, DeepSeek, Ollama, ...) with Codex CLI,
      App, SDK, and Claude Code. Provides a local proxy that translates Codex's
      Responses API into whatever provider you point it at, including streaming,
      tool calls and reasoning tokens, plus a web dashboard.
    '';
    homepage = "https://github.com/lidge-jun/opencodex";
    changelog = "https://github.com/lidge-jun/opencodex/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
    platforms = lib.platforms.unix;
    mainProgram = "ocx";
  };
}
