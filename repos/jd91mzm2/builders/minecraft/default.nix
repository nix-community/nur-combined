{ runCommand, lib, callPackage, writeShellScript }:

with callPackage ./utils.nix {};

rec {
  mkDatapack = callPackage ./datapack.nix {};

  installDatapack = datapack: name: writeShellScript "install.sh" ''
    ${./install.sh} ${escapeShellArg datapack} ${escapeShellArg name} "$@"
  '';

  mkLayer = height: block: {
    inherit height block;
  };

  genSuperflat =
    {
      biome ? "minecraft:plains",
      layers ? [
        (mkLayer 1 "minecraft:bedrock")
        (mkLayer 2 "minecraft:dirt")
        (mkLayer 1 "minecraft:grass_block")
      ],
    }:
    {
      type = "minecraft:flat";
      settings = {
        inherit biome layers;
        structures = {
          structures = {};
        };
      };
    };

  genNormal =
    {
      setting ? "minecraft:overworld",
      seed,
    }:
    {
      type = "minecraft:noise";
      inherit seed;
      settings = setting;
      biome_source = {
        type = "minecraft:vanilla_layered";
        inherit seed;
        large_biomes = false;
        legacy_biome_init_layer = false;
      };
    };

  # See https://minecraft.gamepedia.com/Custom_dimension#Defaults
  dimensionSettings = {
    overworld = {
      ultrawarm = false;
      natural = true;
      shrunk = false;
      piglin_safe = false;
      respawn_anchor_works = false;
      bed_works = true;
      has_raids = true;
      has_skylight = true;
      has_ceiling = false;
      # fixed_time = N/A;
      ambient_light = 0.0;
      logical_height = 256;
      infiniburn = "minecraft:infiniburn_overworld";
    };
    nether = {
      ultrawarm = true;
      natural = false;
      shrunk = true;
      piglin_safe = true;
      respawn_anchor_works = true;
      bed_works = false;
      has_raids = false;
      has_skylight = false;
      has_ceiling = true;
      fixed_time = 18000;
      ambient_light = 0.1;
      logical_height = 128;
      infiniburn = "minecraft:infiniburn_nether";
    };
    end = {
      ultrawarm = false;
      natural = false;
      shrunk = false;
      piglin_safe = false;
      respawn_anchor_works = false;
      bed_works = false;
      has_raids = true;
      has_skylight = false;
      has_ceiling = false;
      fixed_time = 6000;
      ambient_light = 0.0;
      logical_height = 256;
      infiniburn = "minecraft:infiniburn_end";
    };
  };
}
