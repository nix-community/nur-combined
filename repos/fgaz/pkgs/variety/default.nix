{ stdenv, fetchurl, python2Packages, intltool, imagemagick, gtk3 }:

with python2Packages; buildPythonApplication rec {
  name = "variety-${version}";
  version = "0.6.6";
  src = fetchurl {
    url = "https://launchpad.net/variety/trunk/${version}/+download/variety_${version}.tar.gz";
    sha256 = "1f794b8lfb47mc5cq196iyi1fmzhslmic6svnnmkkyjdm4zn2hzz";
  };
  propagatedBuildInputs = [ intltool distutils_extra imagemagick gtk3 pillow pycairo requests dbus-python pycurl httplib2 configobj pygtk pygobject3 beautifulsoup4 ];
  doCheck = false;

  meta.broken = true;
}
