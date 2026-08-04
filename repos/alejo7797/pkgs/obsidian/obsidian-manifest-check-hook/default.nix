{
  makeSetupHook,
  jq,
}:

makeSetupHook {
  name = "obsidian-manifest-check-hook";
  propagatedBuildInputs = [ jq ];
} ./hook.sh
