{ lib, pkgs, fetchgit, python3Packages}:

python3Packages.buildPythonPackage rec {
  name = "procset-${version}";
  version = "v1.0";

  src = fetchgit {
    url = "https://gitlab.inria.fr/bleuse/procset.py.git";
    rev = version;
    sha256 = "1cnmbw4sgl9156lgvakdkpjr7mgd2wasqz1zml9qzk29p705420z";
  };

  LC_ALL = "en_US.UTF-8";
  buildInputs = [ pkgs.glibcLocales ];

  meta = with lib; {
    longDescription = ''
      Toolkit to manage sets of closed intervals.
      procset is a pure python module to manage sets of closed intervals. It can be
      used as a small python library to manage sets of resources, and is especially
      useful when writing schedulers.'';
    description = ''Toolkit to manage sets of closed intervals.'';
    homepage    = "https://gitlab.inria.fr/bleuse/procset.py";
    platforms   = platforms.all;
    license     = licenses.lgpl3;
    broken      = false;
  };
}
