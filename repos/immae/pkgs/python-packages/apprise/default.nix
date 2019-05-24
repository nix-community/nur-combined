{ mylibs, pythonPackages }: with pythonPackages;
buildPythonPackage rec {
  pname = "apprise";
  version = "0.7.4";
  src = (mylibs.fetchedGithub ./apprise.json).src;
  propagatedBuildInputs = [ decorator requests
    requests_oauthlib oauthlib urllib3 six click markdown pyyaml
    sleekxmpp
  ];
  doChecks = false;
}
