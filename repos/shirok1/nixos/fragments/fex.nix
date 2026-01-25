{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.boot.binfmt.fex;

  mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\x00\x00\x00\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
  # Data/binfmts/FEX-x86.in
  x86Magic = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03\x00'';
  # Data/binfmts/FEX-x86_64.in
  x86_64Magic = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';

  commonConfig = {
    inherit mask;
    wrapInterpreterInShell = false;
    # A translation of "${pkgs.fex}/share/binfmts/FEX-*".
    interpreter = "${pkgs.fex}/bin/FEXInterpreter";
    offset = 0;
    matchCredentials = true;
    fixBinary = true;
    preserveArgvZero = true;
    # FEX also specifies an additional flag here, `expose_interpreter optional`:
    # this seems to have been set in advance of it being added to the kernel in
    # https://lore.kernel.org/lkml/20230907204256.3700336-1-gpiccoli@igalia.com/.
    # But that hasn't been merged so there's no point specifying it, plus NixOS
    # doesn't support it in the first place (unsurprisingly).
  };
in
{
  options = {
    boot.binfmt.fex.enable = lib.mkEnableOption "Enable the use of FEX to run x86 and x86_64 binaries";
    boot.binfmt.fex.package = lib.mkPackageOption pkgs "fex-headless" { };
  };

  config = lib.mkIf cfg.enable {
    boot.binfmt.registrations.FEX-x86 = commonConfig // {
      magicOrExtension = x86Magic;
    };
    boot.binfmt.registrations.FEX-x86_64 = commonConfig // {
      magicOrExtension = x86_64Magic;
    };
    nix.settings.extra-sandbox-paths = [
      "/run/binfmt"
      "${pkgs.fex}"
    ];
    nix.settings.extra-platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
