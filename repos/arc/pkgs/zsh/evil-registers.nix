{ fetchFromGitHub, buildZshPlugin }: buildZshPlugin rec {
	pname = "evil-registers";
  version = "3.1";

	src = fetchFromGitHub {
		owner = "zsh-vi-more";
		repo = pname;
		rev = version;
		sha256 = "12xbr453gckm3vknkpb5cfzbpc6qg5a4fn9h8n0xl6n41ikpx7mn";
	};
}
