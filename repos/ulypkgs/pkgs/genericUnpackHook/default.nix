{
  lib,
  makeSetupHook,
  _7zz,
}:

makeSetupHook {
  name = "generic-unpack-hook";

  propagatedBuildInputs = [ _7zz ];

  meta = {
    description = "Unpack source archive supported by 7zz, and strip root directory automatically";
    maintainers = with lib.maintainers; [ ulysseszhan ];
  };
} ./setup-hook.sh
