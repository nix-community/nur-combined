{
  name,
  shell ? null,
}:
{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  cfg = config.programs.${name};
in
{
  meta.maintainers = with lib.maintainers; [ wwmoraes ];

  options.programs.${name} = with lib.types; {
    check-sourced = mkOption {
      type = bool;
      default = false;
      description = "Include warnings from sourced files";
    };
    color = mkOption {
      type = nullOr (enum [
        "auto"
        "always"
        "never"
      ]);
      default = null;
      description = "Use color";
    };
    include-warnings = mkOption {
      type = listOf str;
      default = [ ];
      apply = builtins.concatStringsSep ",";
      description = "Consider only given types of warnings";
    };
    exclude-warnings = mkOption {
      type = listOf str;
      default = [ ];
      apply = builtins.concatStringsSep ",";
      description = "Exclude types of warnings";
    };
    extended-analysis = mkOption {
      type = bool;
      default = true;
      description = "Perform dataflow analysis";
    };
    format = mkOption {
      type = nullOr (enum [
        "checkstyle"
        "diff"
        "gcc"
        "json"
        "json1"
        "quiet"
        "tty"
      ]);
      default = null;
      description = "Output format";
    };
    norc = mkOption {
      type = bool;
      default = false;
      description = "Don't look for .shellcheckrc files";
    };
    rcfile = mkOption {
      type = nullOr path;
      default = null;
      description = "Prefer the specified configuration file over searching for one";
    };
    optional-checks = mkOption {
      type = listOf str;
      default = [ ];
      apply = builtins.concatStringsSep ",";
      description = "List of optional checks to enable (or 'all')";
    };
    source-paths = mkOption {
      type = listOf path;
      default = [ ];
      apply = paths: builtins.concatStringsSep ":" (map toString paths);
    };
    shell = mkOption {
      type =
        if shell != null then
          enum [ shell ]
        else
          nullOr (enum [
            "sh"
            "bash"
            "dash"
            "ksh"
            "busybox"
          ]);
      default = shell;
      readOnly = shell != null;
      description = "Specify dialect";
    };
    severity = mkOption {
      type = nullOr (enum [
        "error"
        "warning"
        "info"
        "style"
      ]);
      default = null;
      description = "Minimum severity of errors to consider";
    };
    wiki-link-count = mkOption {
      type = nullOr ints.unsigned;
      default = null;
      description = "The number of wiki links to show, when applicable";
    };
    allow-external-sources = mkOption {
      type = bool;
      default = false;
      description = "Allow 'source' outside of FILES";
    };
  };

  config = lib.mkIf cfg.enable {
    settings.formatter.${name} = {
      options = lib.flatten [
        (lib.optional cfg.check-sourced "--check-sourced")
        (lib.optional (cfg.color != null) "--color=${cfg.color}")
        (lib.optional (cfg.include-warnings != "") "--include=${cfg.include-warnings}")
        (lib.optional (cfg.exclude-warnings != "") "--exclude=${cfg.exclude-warnings}")
        "--extended-analysis=${lib.boolToString cfg.extended-analysis}"
        (lib.optional (cfg.format != null) "--format=${cfg.format}")
        (lib.optional cfg.norc "--norc")
        (lib.optional (cfg.rcfile != null) "--rcfile=${cfg.rcfile}")
        (lib.optional (cfg.optional-checks != "") "--enable=${cfg.optional-checks}")
        (lib.optional (cfg.source-paths != "") "--source-path=${cfg.source-paths}")
        (lib.optional (cfg.shell != null) "--shell=${cfg.shell}")
        (lib.optional (cfg.severity != null) "--severity=${cfg.severity}")
        (lib.optional (cfg.wiki-link-count != null) "--wiki-link-count=${cfg.wiki-link-count}")
        (lib.optional cfg.allow-external-sources "--external-sources")
      ];
    };
  };
}
