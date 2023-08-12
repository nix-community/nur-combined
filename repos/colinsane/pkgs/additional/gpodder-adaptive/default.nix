{ gpodder
, fetchFromGitHub
, libhandy
}:
gpodder.overridePythonAttrs (upstream: rec {
  pname = "gpodder-adaptive";
  version = "3.11.1+1";
  src = fetchFromGitHub {
    owner = "gpodder";
    repo = "gpodder";
    rev = "adaptive/${version}";
    hash = "sha256-pn5sh8CLV2Civ26PL3rrkkUdoobu7SIHXmWKCZucBhw=";
  };

  buildInputs = upstream.buildInputs ++ [
    libhandy
  ];
})
