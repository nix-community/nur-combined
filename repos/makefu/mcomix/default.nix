{ pkgs, lib ,python2Packages, fetchurl, gtk3}:
python2Packages.buildPythonPackage rec {
  name = "mcomix-${version}";
  version = "1.2.1";

  src = fetchurl {
    url = "mirror://sourceforge/mcomix/${name}.tar.bz2";
    sha256 = "0fzsf9pklhfs1rzwzj64c0v30b74nk94p93h371rpg45qnfiahvy";
  };

  propagatedBuildInputs = with python2Packages;
    [ python2Packages.pygtk gtk3 python2Packages.pillow ];

  # for module in sys.modules.itervalues():
  #   RuntimeError: dictionary changed size during iteration
  doCheck = false;

  meta = {
    homepage = https://github.com/pyload/pyload;
    description = "Free and Open Source download manager written in Python";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ makefu ];
  };
}
