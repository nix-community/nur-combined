{ python
, makeSetupHook
}:

let
  pythonCheckInterpreter = python.interpreter;
in makeSetupHook {
  name = "ha-manifest-requirements-check-hook";
  substitutions = {
    inherit pythonCheckInterpreter;
    checkRequirements = ./check_requirements.py;
  };
} ./ha-manifest-requirements-check-hook.sh
