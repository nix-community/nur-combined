{ fetchFromGitHub, buildZshPlugin }: buildZshPlugin rec {
	pname = "vi-increment";
  version = "0.3";

	src = fetchFromGitHub {
		owner = "zsh-vi-more";
		repo = pname;
		rev = version;
		sha256 = "19j8zyxqkr5rxlm985css59b3fhp148njlxq61bagsvzzac6b13d";
	};
}
