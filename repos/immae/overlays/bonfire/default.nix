self: super: {
  bonfire = let
    click = self.python3Packages.click.overridePythonAttrs(old: rec {
      version = "6.7";
      src = self.python3Packages.fetchPypi {
        pname = "click";
        inherit version;
        sha256 = "02qkfpykbq35id8glfgwc38yc430427yd05z1wc5cnld8zgicmgi";
      };
      postPatch = ''
        substituteInPlace click/_unicodefun.py --replace "'locale'" "'${self.locale}/bin/locale'"
      '';
      doCheck = false;
    });
  in
    super.bonfire.overridePythonAttrs(old: {
      version = "0.0.8";
      src = self.fetchFromGitHub {
        owner = "blue-yonder";
        repo = "bonfire";
        rev = "0a0f18469d484aba6871fa7421bbb2c00ccefcb0";
        sha256 = "1y2r537ibghhmk6jngw0zwvh1vn2bihqcvji50ffh1j0qc6q3x6x";
      };
      postPatch = "";
      propagatedBuildInputs = self.lib.remove self.python3Packages.click old.propagatedBuildInputs ++ [ click ];
      meta.broken = false;
    });
}
