{ fetchsvn
, lib
, stdenvNoCC
, writeScript

  # Dependencies
, josm
}:

let
  inherit (builtins) toFile;
  inherit (lib) escapeShellArg fakeHash;

  srcLegacyBase = "https://josm.openstreetmap.de/osmsvn";
in
stdenvNoCC.mkDerivation (josm-plugin-build-env:
let
  # Workaround to absence of sparse checkout support in `fetchsvn`
  mkSrcLegacy = path: hash: fetchsvn {
    inherit hash;
    url = "${srcLegacyBase}/applications/editors/josm/${path}";
    rev = josm-plugin-build-env.versionLegacy;
    ignoreExternals = true;
  };
in
{
  pname = "josm-plugin-build-env";
  versionLegacy = "36507"; # TODO: Can this be derived from `pkgs.josm`?
  versionTools = josm.version;
  version = "${josm-plugin-build-env.versionTools}-${josm-plugin-build-env.versionLegacy}";
  meta = {
    homepage = "https://josm.openstreetmap.de/wiki/DevelopersGuide/DevelopingPlugins";
    license = josm.meta.license;
  };

  passthru.updateScript = writeScript "update-${josm-plugin-build-env.pname}" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash --packages common-updater-scripts subversion
    set -Eeuo pipefail

    version_legacy="$(svn info --show-item 'revision' ${escapeShellArg "${srcLegacyBase}/"})"

    for key in srcLegacyCommon srcLegacyDist srcLegacyTools; do
      update-source-version ${escapeShellArg josm-plugin-build-env.pname} \
        "$version_legacy" \
        --source-key="$key" \
        --version-key='versionLegacy' \
        --ignore-same-hash \
        --ignore-same-version
    done
  '';

  srcLegacyCommon = mkSrcLegacy "plugins/build-common.xml" "sha256-sXk0oltWwrfOISCCBpcHBCU5es6Dulqe68CprUpTt0Y=";
  srcLegacyDist = mkSrcLegacy "dist" "sha256-VJEzZja0neku9FJsmcRY8NDBLXZPOElyg+1Fcc1MkKE=";
  srcLegacyTools = mkSrcLegacy "plugins/00_tools" "sha256-2HoDySGB1PXL4n/HsVO9H1BGAXhbaHCiUxA2tFXDlJE=";
  srcTools = fetchsvn {
    url = "https://josm.openstreetmap.de/svn/trunk/tools/";
    rev = josm-plugin-build-env.versionTools;
    ignoreExternals = true;
    hash = {
      "19555" = "sha256-QVyVwS4hckTSI8/iFvawLqB83fcafTzKUlRd2FIo220=";
      "19613" = "sha256-QVyVwS4hckTSI8/iFvawLqB83fcafTzKUlRd2FIo220=";
    }."${josm-plugin-build-env.versionTools}" or fakeHash;
  };

  unpackPhase = ''
    mkdir --parents 'core/dist' 'dist' 'plugins'

    ln --symbolic '${josm}/share/josm/josm.jar' 'core/dist/josm-custom.jar'
    ln --symbolic "$srcTools" 'core/tools'
    ln --symbolic "$srcLegacyDist/"* 'dist/'
    ln --symbolic "$srcTools" 'plugins/00_core_tools'
    ln --symbolic "$srcLegacyTools" 'plugins/00_tools'
    cp "$srcLegacyCommon" 'plugins/build-common.xml'
  '';

  patches = [
    (toFile "offline.patch" ''
      --- a/plugins/build-common.xml
      +++ b/plugins/build-common.xml
      @@ -123 +123 @@
      -    <target name="compile" depends="init, pre-compile, resolve-tools, plugin-classpath-actual" unless="skip-compile">
      +    <target name="compile" depends="init, pre-compile, plugin-classpath-actual" unless="skip-compile">
      @@ -126 +125,0 @@
      -            <path refid="errorprone_javac.classpath"/>
      @@ -146 +144,0 @@
      -            <compilerarg pathref="errorprone.classpath"/>
      @@ -149 +146,0 @@
      -            <compilerarg value="-Xplugin:ErrorProne -Xep:StringSplitter:OFF -Xep:ReferenceEquality:OFF -Xep:InsecureCryptoUsage:OFF -Xep:FutureReturnValueIgnored:OFF -Xep:JdkObsolete:OFF -Xep:EqualsHashCode:OFF -Xep:JavaUtilDate:OFF -Xep:DoNotCallSuggester:OFF -Xep:BanSerializableRead:OFF" />
    '')
  ];

  installPhase = ''
    cp --recursive '.' "$out"
  '';
})
