{ config, lib, ... }:
{
  options = with lib; {
    sane.silencedWarnings = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        list of `config.warnings` values you want to ignore, verbatim.
      '';
    };
    sane.silencedAssertions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        list of `config.assertions` values you want to ignore, keyed by `message`, interpreted as a regex.
      '';
    };
    warnings = mkOption {
      apply = builtins.filter (w: !(builtins.elem w config.sane.silencedWarnings));
    };
    assertions = mkOption {
      # N.B.: don't evaluation `<assertion>.message` before checking `<assertion>.assertion`.
      # valid assertions are (defacto) allowed to have non-evaluatable messages.
      apply = builtins.filter (a: !(builtins.any (s: !a.assertion && builtins.match s a.message != null) config.sane.silencedAssertions));
    };
  };
}
