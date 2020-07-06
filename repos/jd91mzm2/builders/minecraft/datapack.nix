{ runCommand, lib, callPackage }:

{
  # Data in the pack.mcmeta.
  #
  # Keys:
  # - Name: String, The filename of the datapack
  # - Description: String or JSON text, The description shown in the menu
  meta ? {
    name = "my-datapack";
    description = {
      text = "Nix-generated datapack";
      color = "yellow";
    };
  },

  # data/${key} = ${value}
  #
  # Each value is treated just like `data`, so see that for possible keys of
  # each child set.
  namespaces ? {},

  # data/${name}, shorthand for namespaces."${meta.name}"
  #
  # Keys:
  # - advancements
  # - functions
  # - loot_tables
  # - predicates
  # - recipes
  # - tags
  additions ? {},

  # data/minecraft

  # Modifications to the minecraft namespace. This is a shorthand of
  # `namespaces.minecraft`
  modifications ? {},

  # dimension_type/${name}/${key} = toJSON ${value}
  dimension_type ? {},
  # dimension/${name}/${key} = toJSON ${value}
  dimension ? {},

  extraBuild ? "",
}:

with callPackage ./utils.nix {};

let
  finalNamespaces = {
    "${meta.name}" = additions;
    minecraft = modifications;
  } // namespaces;

  # This is used to create a single namespace, like my-datapack:* or minecraft:*
  mkNamespace = callPackage ./namespace.nix {
    inherit finalNamespaces;
  };
in runCommand "minecraft-datapack-${meta.name}" {} ''
  mkdir $out
  cd $out

  # Create pack.mcmeta
  echo ${escapeShellArg (toJSON {
    pack = {
      description = meta.description;
      pack_format = meta.version or 5;
    };
  })} > pack.mcmeta

  # Create data/''${name} files
  mkdir data
  pushd data > /dev/null

  ${mapSet (name: value: mkNamespace name value) finalNamespaces}

  popd > /dev/null
  ${extraBuild}
''
