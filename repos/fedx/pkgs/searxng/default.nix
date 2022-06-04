{ lib, nixosTests, python3, python3Packages, fetchFromGitHub, fetchpatch }:

with python3Packages;

toPythonModule (buildPythonApplication rec {
  pname = "searxng";
  version = "1.0.0-searxng-alpha-202206022146";

  # pypi doesn't receive updates
  src = fetchFromGitHub {
    owner = "searxng";
    repo = "searxng";
    rev = "96dc4369d535dc20178a3e7df793c8f2427d2c79";
    sha256 = "sha256-ITTL0MypbuIIFt2xsB5tkjXu0jsH1l3fMHjbEid+zO0=";
  };

#   patches = [
#     # Fix a crash, remove with the next update
#     (fetchpatch {
#       url = "https://github.com/searx/searx/commit/9c10b150963babb7f0b52081693a42b2e61eede9.patch";
#       sha256 = "0svp8799628wja2hq59da6rxqi99am8p6hb8y27ciwzsjz0wwba7";
#     })
#   ];

  postPatch = ''
    sed -i 's/==.*$//' requirements.txt
  '';

  preBuild = ''
    export SEARX_DEBUG="true";
  '';

/*  propagatedBuildInputs = [
    Babel
    certifi
    python-dateutil
    flask
    flaskbabel
    gevent
    grequests
    jinja2
    langdetect
    lxml
    ndg-httpsclient
    pyasn1
    pyasn1-modules
    pygments
    pysocks
    pytz
    pyyaml
    requests
    speaklater
    werkzeug
  ];*/
   propagatedBuildInputs = [
     certifi
     babel
     flaskbabel
     flask
     jinja2
     lxml
     pygments
     python-dateutil
     pyyaml
     httpx
     brotli
     uvloop
     httpx-socks
     langdetect
     setproctitle
     redis
     markdown-it-py
     pkgs.kodiPackages.typing_extensions
     h2
   ];

  # tests try to connect to network
  doCheck = false;

  pythonImportsCheck = [ "searx" ];

  postInstall = ''
    # Create a symlink for easier access to static data
    mkdir -p $out/share
    ln -s ../${python3.sitePackages}/searx/static $out/share/
  '';

  passthru.tests = { inherit (nixosTests) searx; };

  meta = with lib; {
    homepage = "https://github.com/searx/searx";
    description = "A privacy-respecting, hackable metasearch engine";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ matejc fpletz globin danielfullmer ];
  };
})
