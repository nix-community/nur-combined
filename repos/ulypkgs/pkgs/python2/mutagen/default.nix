{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  pycodestyle,
  pyflakes,
  pytest,
  setuptools,
  pkgs,
}:

buildPythonPackage (finalAttrs: {
  pname = "mutagen";
  version = "1.43.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2HO663gVMR00IKqwodg/BQ9igijLwtYEWhShZGBBG8k=";
  };

  propagatedBuildInputs = [ setuptools ];
  checkInputs = [
    pkgs.faad2
    pkgs.flac
    pkgs.vorbis-tools
    pkgs.liboggz
    pkgs.glibcLocales
    pycodestyle
    pyflakes
    pytest
    hypothesis
  ];
  LC_ALL = "en_US.UTF-8";

  meta = with lib; {
    description = "Python multimedia tagging library";
    homepage = "https://mutagen.readthedocs.io";
    license = licenses.lgpl2Plus;
    platforms = platforms.all;
  };
})
