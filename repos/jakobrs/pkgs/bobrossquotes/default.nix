{ buildPythonApplication, lib, fetchFromGitHub }:

buildPythonApplication rec {
  pname = "bobrossquotes";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "kz6fittycent";
    repo = "BobRossQuotes";
    rev = version;
    hash = "sha256:08m83m39y6cqdpa4g3lar0ppsny4mnar2fziin1jip2csxi58p66";
  };

  meta = {
    description = "A bunch of quotes from Bob Ross";
    license = lib.licenses.mit;
  };
}
