{
  lib,
  vacuCommonArgs,
  writeText,
  caddy,
  runCommand,
}:
let
  configs = import ./configs.nix vacuCommonArgs;
  configText =
    ''
      {
        debug
        default_bind 127.0.0.1
        auto_https off
      }
    ''
    + "\n"
    + lib.concatMapAttrsStringSep "\n" (domain: configText:
      ''
        http://${domain}.localhost {
          ${configText}
        }
      ''
    ) configs;
  unformatted = writeText "static-sites-test-unformatted.caddyfile" configText;
in
runCommand "static-sites-test.caddyfile" { } ''
  # if the file is badly formatted, caddy fmt exits with error code 1 even if it successfully printed the formatted version to stdout
  # do an --overwrite instead so that caddy fmt exits with code 0 when nothing goes wrong
  cp --no-preserve=all ${unformatted} $out
  ${lib.getExe caddy} fmt --overwrite $out
''
