{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  autoPatchelfHook,
  makeWrapper,
  icu,
  openssl,
  zlib,
  runCommand,
}:

let
  # Map Nix systems to the platform directories published inside the npm tarball.
  platformDir =
    {
      x86_64-linux = "linux-x64";
      aarch64-linux = "linux-arm64";
      x86_64-darwin = "osx-x64";
      aarch64-darwin = "osx-arm64";
    }
    .${stdenv.hostPlatform.system}
      or (throw "work-iq: unsupported system ${stdenv.hostPlatform.system}");

  # Stable marketplace plugins shipped alongside the CLI. Preview plugins are
  # intentionally omitted. Skills are installed under share/skills/work-iq per
  # https://github.com/NixOS/nixpkgs/issues/547426.
  stablePlugins = [
    "workiq"
    "workiq-productivity"
    "microsoft-365-agents-toolkit"
  ];

  # .NET single-file host links libstdc++ at load time; ICU/OpenSSL/zlib are
  # dlopened for globalization and TLS and must be on the loader path (Linux).
  runtimeLibs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    icu
    openssl
    zlib
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "work-iq";
  # CLI version from the @microsoft/workiq npm package (canonical binary distro).
  version = "1.0.0";

  # Upstream publishes no buildable CLI source. The GitHub repo is a plugin
  # marketplace; the workiq CLI ships only as platform-native binaries inside
  # the npm tarball.
  src = fetchurl {
    url = "https://registry.npmjs.org/@microsoft/workiq/-/workiq-${finalAttrs.version}.tgz";
    hash = "sha256-LGtPdLMh923WEsQrqajx5skE3Ipvc1ZooZhKgXzXR0U=";
  };

  # Plugin/skill tree from the canonical marketplace repository. Untagged;
  # pinned by commit and refreshed by update.sh together with the CLI.
  plugins = fetchFromGitHub {
    owner = "microsoft";
    repo = "work-iq";
    rev = "b27a6c3062bf3b30156675f7ec2f572e94a1e8cd";
    hash = "sha256-h6EBisSKuZFgfybESNRIi/GOzwJ5jaYsXdUYfxbzUxk=";
  };

  sourceRoot = "package";

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = runtimeLibs;

  dontConfigure = true;
  dontBuild = true;
  # Single-file .NET apphost: stripping corrupts the appended bundle.
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    # Keep the real binary name free of a leading "." — wrapProgram's default
    # `.foo-wrapped` rename makes System.CommandLine's RootCommand name empty
    # (GetFileNameWithoutExtension(".workiq-wrapped") == "").
    install -Dm755 "bin/${platformDir}/workiq" "$out/libexec/work-iq/workiq"

    # .NET single-file extraction needs a writable cache directory. Prefer an
    # explicit extract base so the binary works even when HOME is unset/odd.
    # ICU and friends are dlopened (not DT_NEEDED), so put them on LD_LIBRARY_PATH.
    makeWrapper "$out/libexec/work-iq/workiq" "$out/bin/workiq" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
      --run 'export DOTNET_BUNDLE_EXTRACT_BASE_DIR="''${DOTNET_BUNDLE_EXTRACT_BASE_DIR:-''${XDG_CACHE_HOME:-$HOME/.cache}/workiq-dotnet}"'

    # Agent skills: $out/share/skills/work-iq/<skill-name>/SKILL.md
    mkdir -p "$out/share/skills/work-iq"
    for plugin in ${lib.concatStringsSep " " stablePlugins}; do
      skills="${finalAttrs.plugins}/plugins/$plugin/skills"
      if [ -d "$skills" ]; then
        cp -r "$skills"/. "$out/share/skills/work-iq/"
      fi
    done

    # Full stable plugin trees (mcp/plugin manifests + skills) for consumers
    # that want marketplace-style layout rather than the flattened skill view.
    mkdir -p "$out/share/work-iq/plugins"
    for plugin in ${lib.concatStringsSep " " stablePlugins}; do
      cp -r "${finalAttrs.plugins}/plugins/$plugin" "$out/share/work-iq/plugins/$plugin"
    done
    install -Dm644 "${finalAttrs.plugins}/marketplace.json" \
      "$out/share/work-iq/marketplace.json"

    install -Dm644 package.json "$out/share/doc/work-iq/package.json"
    if [ -d EULA ]; then
      mkdir -p "$out/share/doc/work-iq"
      cp -r EULA "$out/share/doc/work-iq/"
    fi

    runHook postInstall
  '';

  passthru = {
    inherit (finalAttrs) plugins;
    updateScript = ./update.sh;

    tests = {
      version-and-skills = runCommand "work-iq-version-and-skills" { } ''
        export HOME=$(mktemp -d)
        export XDG_CACHE_HOME="$HOME/.cache"

        ${lib.getExe finalAttrs.finalPackage} version | grep -F '${finalAttrs.version}'
        ${lib.getExe finalAttrs.finalPackage} --help | grep -Eqi 'work ?iq|Microsoft 365'

        test -f ${finalAttrs.finalPackage}/share/skills/work-iq/workiq/SKILL.md
        test -f ${finalAttrs.finalPackage}/share/skills/work-iq/daily-outlook-triage/SKILL.md
        test -f ${finalAttrs.finalPackage}/share/skills/work-iq/teams-app-developer/SKILL.md
        test -d ${finalAttrs.finalPackage}/share/work-iq/plugins/workiq
        test ! -e ${finalAttrs.finalPackage}/share/work-iq/plugins/workiq-preview

        touch "$out"
      '';
    };
  };

  meta = {
    description = "CLI and MCP server for Microsoft 365 Copilot (Work IQ), with bundled agent plugins and skills";
    homepage = "https://github.com/microsoft/work-iq";
    downloadPage = "https://www.npmjs.com/package/@microsoft/workiq";
    changelog = "https://www.npmjs.com/package/@microsoft/workiq?activeTab=versions";
    # CLI binaries are under Microsoft Work IQ CLI EULA (SEE EULA in the npm
    # package); marketplace plugins/skills in the GitHub repo are MIT.
    license = with lib.licenses; [
      unfree
      mit
    ];
    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
      fromSource
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "workiq";
  };
})
