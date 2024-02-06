{ trivialBuild, fetchFromGitHub, eglot, tempel }:
trivialBuild rec {
  pname = "eglot-tempel";
  version = "master";

  src = fetchFromGitHub {
    owner = "fejfighter";
    repo = pname;
    rev = "3bd76e51d68ff64d63d02a100a86840ddb50339c";
    hash = "sha256-GBUHX8Qvcq212avnLhVKBTo8hz6I/OkfIY+YTKwfvQU=";
  };

  packageRequires = [ eglot tempel ];
}

