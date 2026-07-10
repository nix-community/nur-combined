{ fetchsvn
, lib
, stdenv

  # Dependencies
, ant
, jdk
, josm
}:

# Modeled after https://josm.openstreetmap.de/wiki/DevelopersGuide/DevelopingPlugins
let
  inherit (builtins) toFile;
  inherit (lib) extendMkDerivation;
in
extendMkDerivation {
  constructDrv = stdenv.mkDerivation;

  excludeDrvArgNames = [ "pluginName" ];

  extendDrvArgs = _: { pluginName ? args.pname, ... } @ args: {
    srcJosmPlugins = fetchsvn {
      url = "https://josm.openstreetmap.de/osmsvn/applications/editors/josm/";
      rev = "36501";
      ignoreExternals = true;
      hash = "sha256-Uv5De8QMM2VoGRno9ofMC82R/Th04pMJiEAGOdgedDU=";
    };

    srcJosmTools = fetchsvn {
      url = "https://josm.openstreetmap.de/svn/trunk/tools/";
      rev = josm.version;
      ignoreExternals = true;
      hash = {
        "19555" = "sha256-QVyVwS4hckTSI8/iFvawLqB83fcafTzKUlRd2FIo220=";
      }."${josm.version}" or lib.fakeHash;
    };

    unpackPhase = ''
      cp --no-preserve=mode --recursive "$srcJosmPlugins" 'josm'
      mkdir 'josm/core' && cp --no-preserve=mode --recursive "$srcJosmTools" 'josm/core/tools'
      mkdir 'josm/core/dist' && ln --symbolic '${josm}/share/josm/josm.jar' 'josm/core/dist/josm-custom.jar'
      ln --symbolic 'josm/core/tools' 'josm/plugins/00_core_tools'
      cp --no-preserve=mode --recursive "$src" 'josm/plugins/${pluginName}'
    '';

    patches = [
      (toFile "offline.patch" ''
        --- a/josm/plugins/build-common.xml
        +++ b/josm/plugins/build-common.xml
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

    nativeBuildInputs = [ ant jdk ];

    buildPhase = ''
      runHook preBuild

      env --chdir 'josm/plugins/${pluginName}' \
        ant

      runHook postBuild
    '';

    installPhase = ''
      install -D --target-directory "$out/share/JOSM/plugins" \
        '/build/josm/dist/${pluginName}.jar'
    '';
  };
}
