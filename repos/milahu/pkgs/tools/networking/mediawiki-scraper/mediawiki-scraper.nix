{ lib
, buildPythonPackage
, buildPythonApplication
, fetchFromGitHub
, internetarchive
, kitchen
, mwclient
, requests
, lxml
, poetry-core
, file-read-backwards
, pymysql
, python3
, pkgs

# FIXME move to pkgs/python3/pkgs

, fetchPypi

#, poster3
, paste
, webob
, pyopenssl
, nose

#, pywikibot
, sseclient

#, mwparserfromhell

#, wikitools3
}:

let

  # https://github.com/NixOS/nixpkgs/pull/175279
  # fix: error: poster3 is unmaintained and source is no longer available
  poster3 = buildPythonPackage rec {
    pname = "poster3";
    version = "0.9.0";
    src = fetchFromGitHub {
      owner = "EvanDarwin";
      repo = "poster3";
      rev = "88e0149cce746d4fe8781da45ca6e0d772356237";
      sha256 = "sha256-LgnaNbcsyjlWBtvrgIxYHv56dutLdLwboGKWHeOizFQ=";
    };
    checkInputs = [
      paste
      webob
      pyopenssl
      nose
    ];
    # tests are still in python2
    doCheck = false;
    postFixup = ''
      # create alias
      cd $out/lib/python*/site-packages
      ln -s poster poster3
      ln -s poster-${version}.dist-info poster3-${version}.dist-info
    '';
    meta = with lib; {
      description = "Streaming HTTP uploads and multipart/form-data encoding";
      homepage = "https://github.com/EvanDarwin/poster3";
      license = licenses.mit;
      maintainers = with maintainers; [ ];
    };
  };

  pywikibot = buildPythonPackage rec {
    pname = "pywikibot";
    version = "8.1.2";
    # git: https://gerrit.wikimedia.org/r/pywikibot/core
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-C6OwfMNBfX0MD/tNSQHi4nBwutTwIVt3KMK6fpMV98I=";
    };
    postPatch = ''
      substituteInPlace setup.py \
        --replace "'sseclient<0.0.23,>=0.0.18'" "'sseclient'"
    '';
    propagatedBuildInputs = [
      mwparserfromhell
      requests
      sseclient
    ];
    doCheck = false;
    /*
      checkInputs = [
      paste
      webob
      pyopenssl
      nose
      mock
      ];
    */
    meta = with lib; {
      description = "Python MediaWiki Bot Framework";
      homepage = "https://www.mediawiki.org/wiki/Manual:Pywikibot";
      license = licenses.mit;
      maintainers = with maintainers; [ ];
    };
  };

  mwparserfromhell = buildPythonPackage rec {
    pname = "mwparserfromhell";
    version = "0.6.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-kr7JUorjTScok8yvK1J9+FwxT/KM+7MFY0BGewldg0w=";
    };
    doCheck = false;
  };

  wikitools3 = buildPythonPackage rec {
    pname = "wikitools3";
    version = "3.0.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-tJPmgG+xmFrRrylMVjZK66bqZ6NmVTvBG2W39SedABI=";
    };
    postPatch = ''
      # relax dependencies
      substituteInPlace setup.py \
        --replace "'poster3>=0.8.1,<0.9.0'" "'poster3'"
      substituteInPlace pyproject.toml \
        --replace 'poster3 = "^0.8.1"' 'poster3 = "*"'
      substituteInPlace PKG-INFO \
        --replace "poster3 (>=0.8.1,<0.9.0)" "poster3"
    '';
    buildInputs = [
      poster3
    ];
    propagatedBuildInputs = [
      poster3
    ];
  };

in

buildPythonApplication rec {
  pname = "mediawiki-scraper";
  version = "3.0.0-unstable-2023-06-09";
  src = fetchFromGitHub {
    owner = "mediawiki-client-tools";
    repo = "mediawiki-scraper";
    rev = "eb1529a4c18ec3d71485aea3351330f6a52cdae7";
    sha256 = "sha256-x5sCRznbiV17QcoS6VBwm4NTE4ObZ7PxC75QelT86yI=";
  };
  format = "pyproject";
  postPatch = ''
    # relax dependencies
    sed -i -E 's/==.*$//; s/--hash=.*$//' requirements.txt
    sed -i -E 's/= "\^.*"/= "*"/; s/pre-commit-poetry-export = /#&/' pyproject.toml
  '';

  # fix: ./result/bin/launcher: ModuleNotFoundError: No module named 'dumpgenerator'
  postFixup = ''
    # fix import path
    cd $out/bin
    for f in .*-wrapped; do
      substituteInPlace "$f" --replace "], site._init_pathinfo());" ",'$out/${pkgs.python3.sitePackages}/wikiteam3'], site._init_pathinfo());"
    done
  '';

  propagatedBuildInputs = [
    internetarchive
    kitchen
    mwclient
    requests
    lxml
    file-read-backwards
    pymysql
    wikitools3
    pywikibot
  ];
  buildInputs = [
    poetry-core
  ];
  meta = with lib; {
    homepage = "https://github.com/mediawiki-client-tools/mediawiki-scraper";
    description = "tools for downloading and preserving wikis";
    maintainers = [];
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
