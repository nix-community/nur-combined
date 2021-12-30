{ python
, makeSetupHook
}:

let
  pythonCheckInterpreter = python.interpreter;
in makeSetupHook {
  name = "manifest-requirements-check-hook";
  substitutions = {
    inherit pythonCheckInterpreter;
    checkRequirements = ./check_requirements.py;
  };
} ./manifest-requirements-check-hook.sh
