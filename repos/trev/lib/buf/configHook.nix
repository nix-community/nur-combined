{
  makeSetupHook,
  buf,
}:
makeSetupHook {
  name = "buf-config-hook";
  propagatedBuildInputs = [buf];
}
./buf-config-hook.sh
