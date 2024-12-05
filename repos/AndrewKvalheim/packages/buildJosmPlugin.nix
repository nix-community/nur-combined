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
in
stdenv.mkDerivation
  (args // {
    srcJosmPlugins = fetchsvn {
      url = "https://josm.openstreetmap.de/osmsvn/applications/editors/josm/";
      rev = "36353"; # TODO: Derive from pkgs.josm
      ignoreExternals = true;
      hash = "sha256-aqPreB4PDxWX+JXmucygkdKLNZJzfTQq3tqz6HtnNsQ=";
    };

    srcJosmTools = fetchsvn {
      url = "https://josm.openstreetmap.de/svn/trunk/tools/";
      rev = josm.version;
      ignoreExternals = true;
      hash = "sha256-d1wHGlEmyNW+8Zmhu4Gvynhy56kAWPz/jBK5mIymP8g=";
    };

    unpackPhase = ''
      cp --no-preserve=mode --recursive --reflink=auto $srcJosmPlugins josm
      mkdir josm/core && cp --no-preserve=mode --recursive --reflink=auto $srcJosmTools josm/core/tools
      mkdir josm/core/dist && ln --symbolic ${josm}/share/josm/josm.jar josm/core/dist/josm-custom.jar
      ln --symbolic josm/core/tools josm/plugins/00_core_tools
      cp --no-preserve=mode --recursive --reflink=auto $src josm/plugins/${pluginName}
    '';

    patches = [
      (toFile "offline.patch" ''
        --- a/josm/plugins/build-common.xml
        +++ b/josm/plugins/build-common.xml
        @@ -115 +115 @@
        -    <target name="compile" depends="init, pre-compile, resolve-tools" unless="skip-compile">
        +    <target name="compile" depends="init, pre-compile" unless="skip-compile">
        @@ -124 +123,0 @@
        -            <path refid="errorprone_javac.classpath"/>
        @@ -140 +138,0 @@
        -            <compilerarg pathref="errorprone.classpath"/>
        @@ -143 +140,0 @@
        -            <compilerarg value="-Xplugin:ErrorProne -Xep:StringSplitter:OFF -Xep:ReferenceEquality:OFF -Xep:InsecureCryptoUsage:OFF -Xep:FutureReturnValueIgnored:OFF -Xep:JdkObsolete:OFF -Xep:EqualsHashCode:OFF -Xep:JavaUtilDate:OFF -Xep:DoNotCallSuggester:OFF -Xep:BanSerializableRead:OFF" />
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
