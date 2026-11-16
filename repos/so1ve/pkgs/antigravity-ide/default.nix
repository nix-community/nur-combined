{
  antigravityCli ? callPackage ../antigravity-cli { },
  buildVscode,
  callPackage,
  commandLineArgs ? "",
  coreutils,
  lib,
  source ? callPackage ./source.nix { },
  stdenv,
  useVSCodeRipgrep ? stdenv.hostPlatform.isDarwin,
  writeShellScript,
}:

let
  vscodeVersion = "1.107.0";
  package = buildVscode {
    inherit commandLineArgs useVSCodeRipgrep;
    inherit (source) version src;
    inherit vscodeVersion;

    pname = "antigravity-ide";
    executableName = "antigravity-ide";
    longName = "Antigravity IDE";
    shortName = "Antigravity IDE";
    libraryName = "antigravity-ide";
    iconName = "antigravity-ide";

    sourceRoot = "Antigravity IDE";
    tests = { };
    updateScript = null;

    # When running inside an FHS environment, try linking Google Chrome or Chromium
    # to the hardcoded Playwright search path: /opt/google/chrome/chrome
    customizeFHSEnv =
      args:
      args
      // {
        extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [ "--tmpfs /opt/google/chrome" ];
        extraBuildCommands = (args.extraBuildCommands or "") + ''
          mkdir -p "$out/opt/google/chrome"
        '';
        runScript = writeShellScript "antigravity-ide-wrapper" ''
          for candidate in google-chrome-stable google-chrome chromium-browser chromium; do
            if target=$(command -v "$candidate"); then
              ${coreutils}/bin/ln -sf "$target" /opt/google/chrome/chrome
              break
            fi
          done
          exec ${args.runScript} "$@"
        '';
      };

    meta = {
      mainProgram = "antigravity-ide";
      description = "Agentic development platform, evolving the IDE into the agent-first era";
      homepage = "https://antigravity.google/product/antigravity-ide";
      downloadPage = "https://antigravity.google/download#antigravity-ide";
      changelog = "https://antigravity.google/docs/changelog?tab=ide";
      license = lib.licenses.unfree;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  };
in
package.overrideAttrs (previousAttrs: {
  # The IDE's agy extension downloads a generic Linux agy into ~/.gemini/bin
  # and spawns it as its backend. Outside an FHS environment that binary has no
  # ELF interpreter unless nix-ld is enabled, so the spawn fails with ENOENT.
  # Make the extension use the Nix-built CLI instead. The anchors are class
  # members, whose names survive minification.
  postPatch = (previousAttrs.postPatch or "") + ''
    ext=resources/app/extensions/agy/vscode/extension.js
    agy=${lib.getExe antigravityCli}
    for anchor in 'this\.binaryAcquirer=[A-Za-z0-9_$]+;' 'getInstalledTargetPath\(\)\{return [A-Za-z0-9_$]+\(\)\}'; do
      n=$(grep -oE "$anchor" "$ext" | wc -l)
      if [ "$n" -ne 1 ]; then
        echo "error: expected one match of '$anchor' in $ext, found $n" >&2
        exit 1
      fi
    done
    sed -E -i \
      -e "s|this\.binaryAcquirer=[A-Za-z0-9_\$]+;|this.binaryAcquirer=async()=>\"$agy\";|" \
      -e "s|getInstalledTargetPath\(\)\{return [A-Za-z0-9_\$]+\(\)\}|getInstalledTargetPath(){return \"$agy\"}|" \
      "$ext"
    n=$(grep -oF "\"$agy\"" "$ext" | wc -l)
    if [ "$n" -ne 2 ]; then
      echo "error: expected 2 references to $agy in $ext after patching, found $n" >&2
      exit 1
    fi
  '';
})
