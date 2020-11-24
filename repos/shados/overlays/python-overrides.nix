self: super:
let
  pyNames = [
    "python" "python2" "python3"
    "python27" "python36" "python37" "python38" "python39" "python310"
    "pypy" "pypy2" "pypy27" "pypy3" "pypy36"
  ];
  overriddenPython = name: [
    { inherit name; value = super.${name}.override { packageOverrides = self.pythonOverrides; }; }
    { name = "${name}Packages"; value = super.recurseIntoAttrs self.${name}.pkgs; }
  ];
  overriddenPythons = builtins.concatLists (map overriddenPython pyNames);
in {
  pythonOverrides = pyself: pysuper: {};
  lib = (super.lib or { }) // {
    # The below is a straight wrapper for clarity of intent, use like:
    # pythonOverrides = buildPythonOverrides (pyself: pysuper: { ... # overrides }) super.pythonOverrides;
    buildPythonOverrides = newOverrides: currentOverrides: super.lib.composeExtensions newOverrides currentOverrides;
  };
} // builtins.listToAttrs overriddenPythons
