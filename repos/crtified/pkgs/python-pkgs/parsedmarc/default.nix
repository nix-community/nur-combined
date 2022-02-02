{ lib, buildPythonPackage, fetchFromGitHub, Babel, alabaster, boto3, codecov
, dateparser, dnspython, doc8, docutils, elasticsearch-dsl, expiringdict, flake8
, geoip2, imagesize, imapclient, jinja2, kafka-python, lxml, mailsuite, nose
, packaging, publicsuffix2, pygments, requests, rstcheck, sphinx
, sphinx_rtd_theme, tqdm, urllib3, wheel, xmltodict }:

buildPythonPackage rec {
  pname = "parsedmarc";
  version = "7.0.1";

  propagatedBuildInputs = [
    Babel
    alabaster
    boto3
    codecov
    dateparser
    dnspython
    doc8
    docutils
    elasticsearch-dsl
    expiringdict
    flake8
    geoip2
    imagesize
    imapclient
    jinja2
    kafka-python
    lxml
    mailsuite
    nose
    packaging
    publicsuffix2
    pygments
    requests
    rstcheck
    sphinx
    sphinx_rtd_theme
    tqdm
    urllib3
    wheel
    xmltodict
  ];

  doCheck = false; # Tests require network connection

  src = fetchFromGitHub {
    owner = "domainaware";
    repo = "parsedmarc";
    rev = "6d689ca8f552d9639fca2773ee540ae95e244203";
    hash = "sha256-EWxdp3lgXZ8ptMTe4XiUKb5s50evURJSbAt1dJyTdeM=";
  };

  meta = with lib; {
    description =
      "parsedmarc is a Python module and CLI utility for parsing DMARC reports.";
    homepage = "https://domainaware.github.io/parsedmarc/";
    license = licenses.asl20;
  };
}
