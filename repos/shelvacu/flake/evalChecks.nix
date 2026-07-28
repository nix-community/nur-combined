{ lib, vaculib, ... }: {
  options.flake.evalChecks.vaculib = lib.mkOption { type = lib.types.bool; };
  config.flake.evalChecks.vaculib = vaculib._unmerged._tests.allTestsGood;
}
