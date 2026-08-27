{
  lib,
  buildGoApplication,
  source,
  stdenv,
}: let
  pluginId = "antigravity-coding-filter";
  version = lib.removePrefix "v" source.version;

  # The host derives the plugin id and version from the file name.
  pluginFile = "${pluginId}-v${version}.${
    if stdenv.hostPlatform.isDarwin
    then "dylib"
    else "so"
  }";
in
  buildGoApplication rec {
    inherit (source) pname src;
    inherit version;

    modules = ./gomod2nix.toml;

    # The plugin ABI needs cgo. Shared with gomod2nix's dependency cache.
    CGO_ENABLED = "1";

    # Keeps the check phase off .github/scripts.
    subPackages = ["."];

    ldflags = [
      "-s"
      "-w"
    ];

    # A shared library, not a command.
    buildPhase = ''
      runHook preBuild

      go build -buildmode=c-shared -ldflags "$ldflags" -o ${pluginFile} .

      runHook postBuild
    '';

    # The generated C header is for plugin authors, not the host.
    installPhase = ''
      runHook preInstall

      install -Dm444 ${pluginFile} -t $out/lib/cliproxyapiplus/plugins
      install -Dm644 LICENSE README.md -t $out/share/doc/${pname}

      runHook postInstall
    '';

    # buildPhase above displaces goBuildHook, the only thing that writes the file goCheckHook then sources.
    preCheck = ''
      touch "$TMPDIR/buildFlagsArray"
    '';

    doCheck = true;

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      test -f $out/lib/cliproxyapiplus/plugins/${pluginFile}
      test ! -e $out/lib/cliproxyapiplus/plugins/${pluginId}.h
      grep -qF cliproxy_plugin_init $out/lib/cliproxyapiplus/plugins/${pluginFile}

      test -f $out/share/doc/${pname}/LICENSE
      test -f $out/share/doc/${pname}/README.md

      runHook postInstallCheck
    '';

    passthru = {
      inherit pluginFile pluginId;
    };

    meta = {
      description = "CLIProxyAPI v7 dynamic plugin for blocking or rewriting non-Antigravity coding software signals";
      homepage = "https://github.com/jellyfish-p/cpa-plugin-antigravity-coding-filter";
      changelog = "https://github.com/jellyfish-p/cpa-plugin-antigravity-coding-filter/releases/tag/${source.version}";
      license = lib.licenses.mit;
      maintainers = [
        {
          name = "mzwing";
        }
      ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
  }
