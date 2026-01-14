{
  lib,
  makeSetupHook,
  uv,
}:

makeSetupHook {
  name = "uv-venv-shell-hook";
  substitutions = {
    uv = lib.getExe uv;
  };
  propagatedBuildInputs = [ uv ];
} ./uv-venv-shell-hook.sh
