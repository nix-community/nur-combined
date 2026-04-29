{
  makeSetupHook,
  buf,
}:

makeSetupHook {
  name = "buf-hook";
  propagatedBuildInputs = [ buf ];
} ./hook.sh
