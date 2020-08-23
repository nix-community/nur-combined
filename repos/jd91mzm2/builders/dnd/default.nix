{ writeText, callPackage, selfLib }:

{
  macroTools = rec {
    mkMacros = macros: writeText "macros.json" (builtins.toJSON {
      schema_version = 2;
      inherit macros;
    });

    mkMacro = { name, actions ? [], showToken ? false, showMacrobar ? false }: {
      attributes = {
        action = builtins.concatStringsSep "\n" actions;
        istokenaction = showToken;
        inherit name;
        visibleto = "";
      };
    } // (if !showMacrobar then {} else {
      macrobar = {
        color = null;
        name = null;
      };
    });

    escape = text:
      builtins.replaceStrings
        [ "|" "}" "," "&" ] [ "&verbar;" "&rcub;" "&comma;" "&amp;" ]
        text;

    mkSelect = prompt: attrs:
      assert builtins.tail (builtins.attrNames attrs) != [];
      "?{" + (escape prompt) + "|"
      + builtins.concatStringsSep "|" (map (key: (escape key) + ", " + (escape attrs."${key}")) (builtins.attrNames attrs))
      + "}";

    mkTemplate = { type ? "default", values ? [] }:
      "&{template:${type}}" + (builtins.concatStringsSep "" (builtins.map (value: "{{" + value + "}}") values));
  };

  chants = import ./chants.nix;
  spells = callPackage ./spells.nix { inherit selfLib; };
}
