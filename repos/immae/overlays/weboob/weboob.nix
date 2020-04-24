{ buildPythonPackage, fetchurl, fetchPypi, stdenv
, nose, pillow, prettytable, pyyaml, dateutil, gdata
, requests, feedparser, lxml, gnupg, pyqt5
, libyaml, simplejson, cssselect, pdfminer
, termcolor, google_api_python_client, html2text
, unidecode, html5lib, Babel
}:
let
  mechanize = buildPythonPackage rec {
    pname = "mechanize";
    version = "0.4.4";
    src = fetchPypi {
      inherit version pname;
      sha256 = "9fff89e973bdf1aee75a351bd4dde53ca51a7e76944ddeae3ea3b6ad6c46045c";
    };
    propagatedBuildInputs = [ html5lib ];
    doCheck = false;
  };
in

buildPythonPackage rec {
  pname = "weboob";
  version = "2.0";

  src = fetchurl {
    url = "https://symlink.me/attachments/download/356/${pname}-${version}.tar.gz";
    sha256 = "1p0wd6k28s0cdxkrj5s6vmi120w6v5vfxxyddqg7s2xjxv6mbbbm";
  };

  postPatch = ''
    # Disable doctests that require networking:
    sed -i -n -e '/^ *def \+pagination *(.*: *$/ {
      p; n; p; /"""\|'\'\'\'''/!b

      :loop
      n; /^ *\(>>>\|\.\.\.\)/ { h; bloop }
      x; /^ *\(>>>\|\.\.\.\)/bloop; x
      p; /"""\|'\'\'\'''/b
      bloop
    }; p' weboob/browser/browsers.py weboob/browser/pages.py
  '';

  postInstall = ''
    mkdir -p $out/share/bash-completion/completions/
    cp tools/weboob_bash_completion $out/share/bash-completion/completions/weboob
  '';

  checkInputs = [ nose ];

  nativeBuildInputs = [ pyqt5 ];

  propagatedBuildInputs = [ pillow prettytable pyyaml dateutil
    gdata requests feedparser lxml gnupg pyqt5 libyaml
    simplejson cssselect mechanize pdfminer termcolor
    google_api_python_client html2text unidecode Babel ];

  checkPhase = ''
    nosetests
  '';

  meta = {
    homepage = http://weboob.org;
    description = "Collection of applications and APIs to interact with websites without requiring the user to open a browser";
    license = stdenv.lib.licenses.agpl3;
  };
}

