{ fetchFromGitHub, buildZshPlugin }: buildZshPlugin rec {
	pname = "directory-marks";
  version = "2020-03-14";

  pluginName = "vi-directory-marks";

	src = fetchFromGitHub {
		owner = "zsh-vi-more";
		repo = pname;
		rev = "9dc358c84920b192e4dbb9abc077957a0982c672";
		sha256 = "1hpdjgw620b30z3sqa846ynmh7znqylh5miv2ns5p15pzld8jq77";
	};
}
