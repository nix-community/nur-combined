{ callPackage, finalNamespaces }:

with callPackage ./utils.nix {};

ns: data: ''
  # Create
  mkdir ${escapeShellArg ns}
  pushd ${escapeShellArg ns} > /dev/null

  ${optionalString (data ? advancements) (extractJSON data.advancements "advancements")}

  ${
    optionalString (data ? functions) ''
      mkdir functions
      ${
        mapSet (name: value: ''
          echo ${escapeShellArg value} > functions/${escapeShellArg name}.mcfunction
        '') data.functions
      }
    ''
  }

  ${optionalString (data ? loot_tables) (extractJSON data.loot_tables "loot_tables")}
  ${optionalString (data ? predicates) (extractJSON data.predicates "predicates")}
  ${optionalString (data ? recipes) (extractJSON data.recipes "recipes")}

  ${
    optionalString (data ? tags) ''
      mkdir tags
      pushd tags > /dev/null
      ${
        mapSet (categoryName: categoryData:
          let
            # map
            # { tick = ["function1"]; }
            # to
            # { tick = { replace = false; values = ["function1"] } }
            patchedCategoryData = mapAttrs
              (_: tagData: if builtins.typeOf tagData != "list"
                           then tagData
                           else { replace = false; values = tagData; })
              categoryData;
          in ''
            ${extractJSON patchedCategoryData "${categoryName}"}
          '') data.tags
      }
      popd > /dev/null
    ''
  }

  ${
    optionalString (ns == "minecraft") ''
      ${
        mapSet (ns: data: ''
          ${optionalString (data ? dimension_type) (extractJSON data.dimension_type "dimension_type/${ns}")}
          ${optionalString (data ? dimension) (extractJSON data.dimension "dimension/${ns}")}
        '') finalNamespaces
      }
    ''
  }

  popd > /dev/null
''
