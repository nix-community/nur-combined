{ fetchFromGitHub }:

let repo = fetchFromGitHub {
	owner = "adi1090x";
	repo = "polybar-themes";
	rev = "786166cf976d4a64f90bb108fb76bb4eb33555f3";
	sha256 = "0db7j02g133zlhy3ccvny9gkvzciwi4fi5dkisclnzy1pzhxdg6g";
  };
in repo
