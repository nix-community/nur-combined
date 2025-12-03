{
  config,
  lib,
  pkgs,
  vacupkglib,
  ...
}:
let
  inherit (lib) mkOption types;
  unitNameRegex =
    let
      # Unit  names cannot begin or end with an underscore (‘_’), a comma (‘,’) or a decimal point (‘.’).  Names must not contain any of the operator characters ‘+’, ‘-’, ‘*’, ‘/’, ‘|’, ‘^’, ‘;’, ‘~’, the comment character ‘#’, or parentheses.  To facilitate copying and pasting from documents, several typographical characters are converted to operators: the figure dash (U+2012), minus (‘-’; U+2212), and en dash (‘–’; U+2013) are converted to the operator ‘-’; the multiplication sign (‘×’; U+00D7), N-ary times operator (U+2A09), dot operator (‘⋅’; U+22C5), and middle dot (‘·’; U+00B7) are converted to the operator ‘*’; the division sign (‘÷’; U+00F7) is converted to the operator ‘/’; and the fraction slash (U+2044) is converted to the operator ‘|’; accordingly, none of these characters can appear in unit names.
      disallowedAnywhere =
        "+*/|^;~#()" + (builtins.fromJSON ''"\u2012\u2212\u2013\u00d7\u2a09\u22c5\u00b7\u00f7\u2044"'');
      disallowedMiddle = "-" + disallowedAnywhere;
      disallowedAtEnd = "23456789_,." + disallowedAnywhere;
      disallowedAtBegin = "-01" + disallowedAtEnd;
      anyExcept = chars: "[^${lib.escapeRegex chars}]";
      singleChar = anyExcept disallowedAtBegin;
      multiChar = "${anyExcept disallowedAtBegin}${anyExcept disallowedMiddle}*${anyExcept disallowedAtEnd}";
      numberSuffix = regex: "${regex}_[0-9\\.,]+";
      fullRegex = "${singleChar}|${multiChar}|${numberSuffix singleChar}|${numberSuffix multiChar}";
    in
    fullRegex;
  unitsAttrsType = types.addCheck (types.attrsOf types.str) (
    attrs: builtins.all (name: (builtins.match unitNameRegex name) != null) (builtins.attrNames attrs)
  );
  unitsDir = pkgs.stdenvNoCC.mkDerivation {
    name = "vacu-units-files";

    src = pkgs.units.src;

    patches = pkgs.units.patches or [ ];

    phases = [
      "unpackPhase"
      "patchPhase"
      "installPhase"
    ];

    installPhase = ''
      mkdir -p "$out"
      cp {definitions,elements}.units "$out"
      ln -s ${../units/currency.units} "$out"/currency.units
      ln -s ${../units/cpi.units} "$out"/cpi.units
      ln -s ${../units/cryptocurrencies.units} "$out"/cryptocurrencies.units
      printf '%s' ${lib.escapeShellArg config.vacu.units.lines} > "$out"/vacu.units
    '';
  };
in
{
  options.vacu.units = {
    originalPackage = mkOption {
      type = types.package;
      default = pkgs.units.override { enableCurrenciesUpdater = false; };
      defaultText = "pkgs.units.override { ... }";
    };
    finalPackage = mkOption {
      type = types.package;
      readOnly = true;
    };
    check = mkOption {
      type = types.package;
      readOnly = true;
    };
    generatedConfigDir = mkOption {
      readOnly = true;
      type = types.package;
    };
    generatedConfigFile = mkOption {
      readOnly = true;
      type = types.pathInStore;
    };
    lines = mkOption {
      default = "";
      type = types.lines;
    };
    extraUnits = mkOption {
      type = unitsAttrsType;
      default = { };
    };
  };
  config = lib.mkMerge [
    {
      vacu.units = {
        finalPackage = vacupkglib.makeWrapper {
          original = config.vacu.units.originalPackage;
          new = "units";
          prepend_flags = [
            "--file"
            config.vacu.units.generatedConfigFile
          ];
        };
        generatedConfigDir = unitsDir;
        generatedConfigFile = "${unitsDir}/vacu.units";
        lines = lib.mkOrder 750 ''
          # default units file, includes elements.units, currency.units, cpi.units
          !include definitions.units

          !include cryptocurrencies.units
        '';
      };
      vacu.textChecks.units-config = ''
        # `units --check` returns success (exit code 0) regardless of success >:(
        # example output:

        # $ result/bin/units --check
        # Currency exchange rates from exchangerate-api.com (USD base) on 2024-11-14 
        # Consumer price index data from US BLS, 2024-02-18 
        # 7247 units, 125 prefixes, 134 nonlinear units
        #

        output="$(${lib.getExe config.vacu.units.finalPackage} --check)"
        printf '%s' "$output"
        filteredLines="$(printf '%s' "$output" \
          | grep -v '^\s*$' \
          | grep -v 'Currency exchange rates from' \
          | grep -v 'Consumer price index data from' \
          | grep -vE '[0-9]+ units, [0-9]+ prefixes, [0-9]+ nonlinear units' || true
        )"
        if [[ -n "$filteredLines" ]]; then
          exit 1
        fi
        touch "$out"
      '';
    }
    {
      vacu.units.lines = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: value: "+${name}	${value}") config.vacu.units.extraUnits
      );
    }
  ];
}
