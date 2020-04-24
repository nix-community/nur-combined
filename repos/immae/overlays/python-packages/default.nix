let
  fromMyPythonPackages = name: self: super: {
    pythonOverrides = self.buildPythonOverrides (pyself: pysuper: {
      "${name}" = self."${pyself.python.pname}PackagesPlus"."${name}";
    }) super.pythonOverrides;
  };
in
{
  # https://github.com/NixOS/nixpkgs/issues/44426
  # needs to come before all other in alphabetical order (or make use of
  # lib.mkBefore)
  __pythonOverlayFix = self: super: let
    pyNames = [ "python3" "python36" "python37" ];
    overriddenPython = name: [
      { inherit name; value = super.${name}.override { packageOverrides = self.pythonOverrides; }; }
      { name = "${name}Packages"; value = self.recurseIntoAttrs self.${name}.pkgs; }
    ];
    overriddenPythons = builtins.concatLists (map overriddenPython pyNames);
  in {
    pythonOverrides = pyself: pysuper: {};
    buildPythonOverrides = newOverrides: currentOverrides: super.lib.composeExtensions newOverrides currentOverrides;
  } // super.lib.attrsets.listToAttrs overriddenPythons;


  apprise = fromMyPythonPackages "apprise";
  buildbot = import ./buildbot.nix;
  wokkel = fromMyPythonPackages "wokkel";
  pymilter = fromMyPythonPackages "pymilter";
}
