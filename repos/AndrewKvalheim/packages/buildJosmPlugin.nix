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

  josmLegacyRev = "36353"; # TODO: Derive from pkgs.josm
in
stdenv.mkDerivation
  (args // {
    srcJosmLegacy = fetchsvn {
      url = "https://josm.openstreetmap.de/osmsvn/applications/editors/josm/";
      rev = josmLegacyRev;
      ignoreExternals = true;
      hash = "sha256-aqPreB4PDxWX+JXmucygkdKLNZJzfTQq3tqz6HtnNsQ=";
    };

    srcJosmCore = fetchsvn {
      url = "https://josm.openstreetmap.de/svn/trunk/";
      rev = josm.version;
      ignoreExternals = true;
      hash = "sha256-uRt1pnsQPc8pLF1Be8jgWOOqatgVGyOdnx3AWUMqu8w=";
    };

    unpackPhase = ''
      cp --no-preserve=mode --recursive --reflink=auto $srcJosmLegacy josm
      cp --no-preserve=mode --recursive --reflink=auto $srcJosmCore josm/core
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
