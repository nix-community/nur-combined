{ python3, fetchFromGitHub, ncurses }:

with python3.pkgs;
let
	requires = buildPythonPackage rec {
		pname ="Requires";
		version = "0.0.3";
		
		src = fetchPypi {
			inherit pname version;
			sha256 = "0y82wag7frh18csq7jxzgj35ank7m3bihvq1kgxdz7xnxqnwnj5x";
		};
	};
  screepsapi = buildPythonPackage rec {
    pname = "screepsapi";
    version = "0.5.1";
    format = "wheel";

    propagatedBuildInputs = [ nose requires requests websocket_client ];

    src = fetchPypi {
      inherit pname version format;
      sha256 = "12r1amna2l8mh6pqqcr6gjgn7kmfchxz1q7sb15c467zvk80h3fz";
    };
  };
in buildPythonApplication rec {
  version = "0.10.1";
  name = "screepsconsole-${version}";

  src = fetchFromGitHub {
    owner = "jomik";
    repo = "screeps_console";
    rev = "40721da56db7c76c4c8fa6087a9a25b50dc701c9";
    sha256 = "160azvw6757gqgkdp0d4gvcpr7qfpf23qgsv0kcg8fz54a7yp25c";
  };

  buildInputs = [ ncurses ];

  propagatedBuildInputs = [ colorama nose pyyaml requests requires screepsapi six urwid websocket_client ];
}
