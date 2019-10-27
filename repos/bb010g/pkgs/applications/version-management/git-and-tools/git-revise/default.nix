{ stdenv, buildPythonApplication, fetchPypi
, git
}:

buildPythonApplication rec {
  pname = "git-revise";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "16sxmxksb5gjj6zfh1wy2czqj9nm4sd3j4fbrsphs8l065dzzikj";
  };

  outputs = [ "out" "man" ];

  propagatedBuildInputs = [ git ];

  meta = let inherit (stdenv) lib; in {
    description = "Efficiently update, split, and rearrange git commits";
    homepage = https://github.com/mystor/git-revise;
    license = lib.licenses.mit;
    maintainers = let m = lib.maintainers; in [ m.bb010g ];
    platforms = lib.platforms.all;
  };
}
