{
  lib,
  fetchurl,
  runCommand,
  _7zz,
  writeText,
  unzip,
  zip,
}:
let
  lock = lib.importJSON ./lock.json;

  bundle = fetchurl {
    name = "ring-and-luci-mod-bundle-of-suffering.7z";
    url = "https://www.dropbox.com/scl/fi/vr9zpqqpqb04hozyo0v06/ring-and-luci-s-mod-bundle-of-suffering.7z?rlkey=q2u0yo018jzjvdrmbfp2vogsv&st=2926fb9c&dl=1";
    sha256 = "c21615fae36c626f00110747edf8f835382b81b444d498cd03b7efed633aeef8";
  };

  bundleFiles = runCommand "lotpwcraft-bundle-files" { nativeBuildInputs = [ _7zz ]; } ''
    7zz x -bd ${bundle} "*/config" "*/resourcepacks/Portal Compat.zip" >/dev/null
    mv */ $out
    cd $out/config
    rm -r jei/world nostalgic_tweaks/backup forgematica
    rm jei/blacklist.cfg.bak quickskin_preferences.json embeddium-fingerprint.json
  '';

  fetchEntry =
    e:
    fetchurl {
      inherit (e) url hash;
      name = lib.strings.sanitizeDerivationName e.name;
    };

  # Ring's copies drop some files from the upstream packs.
  filterPack =
    e:
    let
      src = fetchEntry e;
      removeList = writeText "remove" (lib.concatLines (e.remove or [ ]));
      keepRegex = "^assets/(${lib.concatStringsSep "|" e.keepNamespaces})/";
    in
    if e ? remove || e ? keepNamespaces then
      runCommand (lib.strings.sanitizeDerivationName e.name)
        {
          nativeBuildInputs = [
            unzip
            zip
          ];
        }
        ''
          cp ${src} $out
          chmod +w $out
          ${
            if e ? remove then
              "cat ${removeList}"
            else
              "unzip -Z1 $out | grep '^assets/.*[^/]$' | grep -Ev '${keepRegex}'"
          } | zip -q -d $out -@
        ''
    else
      src;

  resourcePack = e: {
    inherit (e) name;
    path = if e.source == "bundle" then "${bundleFiles}/resourcepacks/${e.name}" else filterPack e;
  };

  mods = map (e: {
    inherit (e) name;
    path = fetchEntry e;
  }) lock.mods;
  resourcePacks = map resourcePack lock.resourcepacks;

  # Forge appends the modifier to the key; deposit defaults to C, which ok_zoomer also uses.
  # Without version, Minecraft runs the options datafixers as if upgrading from pre-1.13.
  options = writeText "options.txt" ''
    version:3465
    realmsNotifications:false
    bobView:false
    fov:0.5
    gamma:1.0
    guiScale:3
    particles:1
    maxFps:260
    graphicsMode:0
    tutorialStep:none
    joinedFirstServer:true
    onboardAccessibility:false
    soundCategory_music:0.0
    resourcePacks:${
      builtins.toJSON (
        [
          "vanilla"
          "mod_resources"
          "Moonlight Mods Dynamic Assets"
          "fabric"
        ]
        ++ map (p: "file/${p.name}") resourcePacks
      )
    }
    key_dropoff.key.deposit:key.keyboard.c:CONTROL
  '';

  mmcPack = writeText "mmc-pack.json" (
    builtins.toJSON {
      formatVersion = 1;
      components = [
        {
          uid = "net.minecraft";
          version = "1.20.1";
          important = true;
        }
        {
          uid = "net.minecraftforge";
          version = "47.4.10";
        }
      ];
    }
  );

  instanceCfg = writeText "instance.cfg" ''
    InstanceType=OneSix
    name=LOTPWCraft
    OverrideMemory=true
    MinMemAlloc=2048
    MaxMemAlloc=8192
  '';

  linkAll =
    dir: entries:
    lib.concatMapStrings (e: ''
      ln -s "${e.path}" "${dir}/${e.name}"
    '') entries;

  instance = runCommand "lotpwcraft-instance" { } ''
    mkdir -p $out/.minecraft/mods $out/.minecraft/resourcepacks
    cp ${instanceCfg} $out/instance.cfg
    cp ${mmcPack} $out/mmc-pack.json
    cp ${options} $out/.minecraft/options.txt
    cp -r ${bundleFiles}/config $out/.minecraft/config
    ${linkAll "$out/.minecraft/mods" mods}
    ${linkAll "$out/.minecraft/resourcepacks" resourcePacks}
  '';
in
runCommand "lotpwcraft.zip"
  {
    nativeBuildInputs = [ zip ];
    passthru = {
      inherit
        bundle
        instance
        mods
        resourcePacks
        ;
    };
    meta.description = "LOTPWCraft (Halloween) modpack as a MultiMC/Prism instance zip";
  }
  ''
    cp -rL ${instance} lotpwcraft
    chmod -R u+w lotpwcraft
    find lotpwcraft -exec touch -h -d @315964800 {} +
    find lotpwcraft | LC_ALL=C sort | zip -q -X -0 $out -@
  ''
