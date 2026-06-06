{
  lib,
  symlinkJoin,
  writeShellApplication,
  writeText,
  ast-grep,
}:

{
  name ? "ast-grep",
  languages,
  ruleDirs ? [ ],
  extraConfig ? { },
}:

let
  languageConfig = lib.mapAttrs (
    _languageName:
    {
      grammar ? null,
      libraryPath ? "${grammar}/parser",
      extensions,
      expandoChar ? null,
      languageSymbol ? null,
    }:
    lib.filterAttrs (_: value: value != null) {
      inherit
        libraryPath
        extensions
        expandoChar
        languageSymbol
        ;
    }
  ) languages;

  config = writeText "sgconfig.yml" (
    lib.generators.toYAML { } (
      extraConfig
      // {
        inherit ruleDirs;
        customLanguages = languageConfig;
      }
    )
  );

  wrapper =
    wrapperName:
    writeShellApplication {
      name = wrapperName;
      text = ''
        case "''${1-}" in
          run|scan|test|lsp)
            subcommand="$1"
            shift
            exec ${ast-grep}/bin/ast-grep "$subcommand" --config ${config} "$@"
            ;;
          new|completions|help|--help|-h|--version|-V)
            exec ${ast-grep}/bin/ast-grep "$@"
            ;;
          *)
            exec ${ast-grep}/bin/ast-grep run --config ${config} "$@"
            ;;
        esac
      '';
    };
in
symlinkJoin {
  inherit name;
  paths = [
    (wrapper "ast-grep")
    (wrapper "sg")
  ];
  passthru = {
    inherit config;
  };
}
