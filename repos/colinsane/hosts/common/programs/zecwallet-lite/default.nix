# zcash wallet
#
# N.B.: zecwallet is UNMAINTAINED. as of 2024/01/01 it requires manual intervention to sync:
#   1. launch it, and wait 5min for it to timeout.
#   2. set the node address to https://lwd3.zcash-infra.com:9067
#   3. close the application and re-open
# more info:
# - <https://forum.zcashcommunity.com/t/zecwallet-lightwalletd-server-continuation/45659/>
# - <https://status.zcash-infra.com/>
{ ... }:
{
  sane.programs.zecwallet-lite = {
    # zcash coins. safe to delete, just slow to regenerate (10-60 minutes)
    persist.byStore.private = [ ".zcash" ];
  };
}
