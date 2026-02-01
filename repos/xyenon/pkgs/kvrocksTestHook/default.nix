{
  lib,
  makeSetupHook,
  kvrocks,
  redis,
}:

makeSetupHook {
  name = "kvrocks-test-hook";
  meta.maintainers = with lib.maintainers; [ xyenon ];
  substitutions = {
    cli = lib.getExe' redis "redis-cli";
    server = lib.getExe' kvrocks "kvrocks";
  };
} ./kvrocks-test-hook.sh
