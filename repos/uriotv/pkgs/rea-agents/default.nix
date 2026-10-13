{
  lib,
  stdenv,
  buildNpmPackage,
  fetchurl,
  nodejs_24,
  autoPatchelfHook,
  makeWrapper,
  ghidra,
  jdk21,
  callPackage,
  withGhidra ? true,
  withFullTools ? stdenv.hostPlatform.system == "x86_64-linux",
}:

let
  tools = callPackage ./runtime-tools.nix { inherit ghidra jdk21; };
  toolWrapperArgs = lib.concatStringsSep " \\\n        " (
    lib.mapAttrsToList (
      name: value: "--set-default ${name} ${lib.escapeShellArg (toString value)}"
    ) tools.environment
  );
in
assert withFullTools -> withGhidra;
assert withFullTools -> stdenv.hostPlatform.system == "x86_64-linux";
buildNpmPackage (finalAttrs: {
  pname = "rea-agents";
  version = "6.4.0";

  # The npm tarball ships the compiled dist/ tree, so no TypeScript toolchain
  # is needed. It omits the lockfile, which is taken from the matching tag.
  src = fetchurl {
    url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${finalAttrs.version}.tgz";
    sha256 = "sha256-WesWBLjbdfUi1Kl1w2zmtKKtRl5DutFl+aj3KDkdubg=";
  };

  packageLock = fetchurl {
    url = "https://raw.githubusercontent.com/morluto/rea/rea-agents-${finalAttrs.version}/package-lock.json";
    sha256 = "sha256-tlXiEYl71yAy72kmG+hxDlA3se3neBBsj+9zAwetAFk=";
  };

  postPatch = ''
    cp ${finalAttrs.packageLock} package-lock.json
  '';

  npmDepsHash = "sha256-XuiMtaM/MPDkhjiHCr9dGC7WlsRBmsWepuNHRxAs3Nw=";

  nodejs = nodejs_24;

  # dist/ is prebuilt; the upstream build and prepack scripts need the
  # source checkout and dev tooling, which the published package lacks.
  dontNpmBuild = true;
  npmPackFlags = [ "--ignore-scripts" ];

  # @lydell/node-pty ships prebuilt pty.node addons.
  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  # The default package can decompile native binaries out of the box. Keep
  # explicit caller settings usable for another Ghidra installation or provider.
  postFixup = lib.optionalString withGhidra ''
    for command in rea rea-agents; do
      wrapProgram "$out/bin/$command" \
        --set-default GHIDRA_INSTALL_DIR "${ghidra}/lib/ghidra" \
        --set-default JAVA_HOME "${jdk21.home}" \
        --set-default REA_ANALYSIS_PROVIDER auto \
        --prefix PATH : ${lib.makeBinPath ([ jdk21 ] ++ lib.optionals withFullTools tools.packages)} \
        ${lib.optionalString withFullTools toolWrapperArgs}
    done
    ${lib.optionalString withFullTools ''
      # The NativeAOT extension rejects unrelated targets if globally enabled.
      # Ship it ready to use through a separate CLI/MCP entry point.
      makeWrapper "$out/bin/rea" "$out/bin/rea-nativeaot" \
        --set-default REA_GHIDRA_NATIVEAOT_JAR \
          "${tools.nativeAot}/share/java/rea-ghidra-nativeaot.jar"
      install -Dm444 ${./check-runtime.py} "$out/share/rea/check-runtime.py"
      makeWrapper ${tools.pwntoolsPython}/bin/python3 "$out/bin/rea-check" \
        --add-flags "$out/share/rea/check-runtime.py $out/bin/rea" \
        --set-default GHIDRA_INSTALL_DIR "${ghidra}/lib/ghidra" \
        --set-default JAVA_HOME "${jdk21.home}" \
        --set-default REA_BUNDLED_NATIVEAOT_JAR \
          "${tools.nativeAot}/share/java/rea-ghidra-nativeaot.jar" \
        --prefix PATH : ${lib.makeBinPath ([ jdk21 ] ++ tools.packages)} \
        ${toolWrapperArgs}
    ''}
  '';

  # Fail the build if an upstream dependency changes to a release line that
  # REA cannot use, rather than shipping another unconfigured backend.
  doInstallCheck = withGhidra;
  installCheckPhase = ''
    runHook preInstallCheck
    unset GHIDRA_INSTALL_DIR JAVA_HOME REA_ANALYSIS_PROVIDER
    export HOME="$TMPDIR/rea-home"
    mkdir -p "$HOME"
    "$out/bin/rea" doctor --provider ghidra --json > "$TMPDIR/rea-ghidra-doctor.json"
    ${lib.optionalString withFullTools ''
      "$out/bin/rea-check" > "$TMPDIR/rea-runtime-check.json"
    ''}
    runHook postInstallCheck
  '';

  passthru = {
    inherit withGhidra withFullTools;
    runtimeTools = lib.optionalAttrs withFullTools tools;
  };

  meta = with lib; {
    description = "Reverse-engineering tools and MCP server for coding agents";
    homepage = "https://rea.tools/";
    changelog = "https://github.com/morluto/rea/releases/tag/rea-agents-${finalAttrs.version}";
    license = licenses.mit;
    platforms =
      if withFullTools then
        [ "x86_64-linux" ]
      else if withGhidra then
        ghidra.meta.platforms
      else
        platforms.linux ++ platforms.darwin;
    mainProgram = "rea";
    sourceProvenance = with sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
})
