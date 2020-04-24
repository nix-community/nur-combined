self: super: {
  weboob = self.callPackage ./weboob.nix {
    inherit (super.python3Packages) buildPythonPackage fetchPypi nose
    pillow prettytable pyyaml dateutil gdata requests feedparser lxml
    pyqt5 simplejson cssselect pdfminer termcolor
    google_api_python_client unidecode Babel html5lib html2text;
  };
}
