{
  libgpg-error,
  runCommand,
  libgcrypt,
  fetchurl,
  jdk25,
  jdk21,
  jdk17,
  jdk8,
  lib,
  javas ? {
    "8" = jdk8;
    "17" = jdk17;
    "21" = jdk21;
    "25" = jdk25;
  },
}: let
  ver = lib.helper.read ./version.json;

  pname = "kryoto-minecraft-launcher";
  inherit (ver) version;

  src = fetchurl (lib.helper.getSingle ver);

  javaBins = runCommand "${pname}-java-bins" {} ''
    mkdir -p $out/bin
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (major: jdk: ''ln -s ${jdk.home}/bin/java "$out/bin/java${major}"'') javas)}
  '';

  meta = {
    description = "Minecraft: Java Edition launcher with Fabric, Quilt, Forge, NeoForge and Modrinth/CurseForge mods";
    homepage = "https://github.com/Kryoto-Dev/kryoto-minecraft-launcher";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [Prinky];
    platforms = ["x86_64-linux"];
    mainProgram = pname;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
in
  lib.helper.mkAppImage {
    inherit pname version src meta;

    passthru = {
      inherit javas;
      javaPaths = lib.makeSearchPath "bin/java" (builtins.attrValues javas);
    };

    desktopName = "Kryoto Minecraft Launcher";
    categories = ["Game"];

    extraPkgs = [
      libgpg-error
      libgcrypt
    ];

    extraBwrapArgs =
      ["--unsetenv GIO_EXTRA_MODULES" "--ro-bind ${javaBins} ${javaBins}"]
      ++ lib.mapAttrsToList (_: jdk: "--ro-bind ${jdk} ${jdk}") javas;

    profile = ''
      export PATH="${javaBins}/bin:$PATH"
    '';
  }
