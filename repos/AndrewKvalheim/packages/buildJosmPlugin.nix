{ fetchsvn
, fetchurl
, lib
, stdenv

  # Dependencies
, ant
, jdk
, josm
}:

{ pluginName ? args.pname, ... } @ args:

# Modeled after https://josm.openstreetmap.de/wiki/DevelopersGuide/DevelopingPlugins
let
  inherit (builtins) toFile;
  inherit (lib) versionOlder warnIf;

  josmVersion = "19067";
  josmLegacyRev = "36265";
in
warnIf (versionOlder josmVersion josm.version) "JOSM plugin build environment ${josmVersion} is behind ${josm.version}"
  stdenv.mkDerivation
  (args // {
    srcJosmLegacy = fetchsvn {
      url = "https://josm.openstreetmap.de/osmsvn/applications/editors/josm/";
      rev = josmLegacyRev;
      ignoreExternals = true;
      hash = "sha256-Ko7SG6/6nHPq/x9AE0KL1/Ftr9Kz1DdwHBDAlQ+32RY=";
    };

    srcJosmCore = fetchsvn {
      url = "https://josm.openstreetmap.de/svn/trunk/";
      rev = josmVersion;
      ignoreExternals = true;
      hash = "sha256-Kv8522Bv4Cj4/JhcsGJmOcwBnV8D/oUGoymJ2ARDqZg=";
    };

    srcJosmCoreDist = fetchurl {
      url = "https://josm.openstreetmap.de/download/josm-snapshot-${josmVersion}.jar";
      hash = "sha256-+mHX80ltIFkVWIeex519b84BYzhp+h459/C2wlDR7jQ=";
    };

    unpackPhase = ''
      cp --no-preserve=mode --recursive --reflink=auto $srcJosmLegacy josm
      cp --no-preserve=mode --recursive --reflink=auto $srcJosmCore josm/core
      mkdir josm/core/dist && ln --symbolic $srcJosmCoreDist josm/core/dist/josm-custom.jar
      ln --symbolic josm/core/tools josm/plugins/00_core_tools
      cp --no-preserve=mode --recursive --reflink=auto $src josm/plugins/${pluginName}
    '';

    patches = [
      (toFile "offline.patch" ''
        --- a/josm/plugins/build-common.xml
        +++ b/josm/plugins/build-common.xml
        @@ -118 +118 @@
        -    <target name="compile" depends="init, pre-compile, resolve-tools" unless="skip-compile">
        +    <target name="compile" depends="init, pre-compile" unless="skip-compile">
        @@ -121 +120,0 @@
        -            <path refid="errorprone_javac.classpath"/>
        @@ -138 +136,0 @@
        -            <compilerarg pathref="errorprone.classpath"/>
        @@ -141,2 +138,0 @@
        -            <compilerarg value="-Xplugin:ErrorProne -Xep:StringSplitter:OFF -Xep:ReferenceEquality:OFF -Xep:InsecureCryptoUsage:OFF -Xep:FutureReturnValueIgnored:OFF -Xep:JdkObsolete:OFF -Xep:EqualsHashCode:OFF -Xep:JavaUtilDate:OFF -Xep:DoNotCallSuggester:OFF -Xep:BanSerializableRead:OFF -Xep:RestrictedApiChecker:OFF" unless:set="isJava11"/>
        -            <compilerarg value="-Xplugin:ErrorProne -Xep:StringSplitter:OFF -Xep:ReferenceEquality:OFF -Xep:InsecureCryptoUsage:OFF -Xep:FutureReturnValueIgnored:OFF -Xep:JdkObsolete:OFF -Xep:EqualsHashCode:OFF -Xep:JavaUtilDate:OFF -Xep:DoNotCallSuggester:OFF -Xep:BanSerializableRead:OFF" if:set="isJava11"/>
      '')
    ];

    nativeBuildInputs = [ ant jdk ];

    buildPhase = ''
      cd josm/plugins/${pluginName}
      ant
    '';

    installPhase = ''
      install -D -t $out/share/JOSM/plugins /build/josm/dist/${pluginName}.jar
    '';
  })
