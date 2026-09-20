# Adapt the generated Caddyfile while building it, so a config Caddy cannot
# parse fails the build instead of the deploy.
#
# Caddy reads its Caddyfile when the unit starts, which is after the new
# system is on the machine and the old one is gone: a config it rejects leaves
# caddy.service dead, and the only sign of it is a failed unit in the middle of
# a switch. Adapting is the same work it does at startup, so anything it would
# refuse there is refused here instead, with the build output to read.
#
# Adapt, not validate: validating provisions the modules too, which reaches for
# certificates and keys that exist on the host and not in the sandbox.
{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.caddy;
  # What the upstream module would have used. Taking the option's default keeps
  # this a wrapper around whatever that module generates rather than a second
  # copy of it — and it reads the Caddyfile options, not cfg.configFile, so
  # overriding cfg.configFile with it does not close a loop.
  generated = options.services.caddy.configFile.default;

  validated = pkgs.runCommand "Caddyfile-validated" { } ''
    mkdir -p $out
    cp --no-preserve=mode ${generated} $out/Caddyfile
    # Adapting writes the JSON to stdout, which is of no interest; a config it
    # cannot convert is, and that is a non-zero exit.
    ${lib.getExe cfg.package} adapt --config $out/Caddyfile >/dev/null
  '';
in
{
  # Only the Caddyfile path is checked. `settings` is JSON that Caddy consumes
  # directly with no adapter in between, and a cross-built Caddy is not ours to
  # run — the upstream module skips its own `caddy fmt` for the same reason.
  config =
    lib.mkIf
      (cfg.enable && cfg.settings == { } && pkgs.stdenv.buildPlatform == pkgs.stdenv.hostPlatform)
      {
        # mkDefault, so this displaces the option's own default while still
        # losing to a host that sets configFile itself.
        services.caddy.configFile = lib.mkDefault "${validated}/Caddyfile";
      };
}
