{ makeSetupHook, gradle }:

let
  gradle-unwrapped =
    if gradle ? passthru && gradle.passthru ? unwrapped then gradle.passthru.unwrapped else gradle;

in
makeSetupHook {
  name = "gradle-setup-hook";
  propagatedBuildInputs = [ gradle-unwrapped ];
  passthru.gradle = gradle-unwrapped;
} ./setup-hook.sh
