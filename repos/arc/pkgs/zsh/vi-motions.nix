{ fetchFromGitHub, buildZshPlugin }: buildZshPlugin rec {
	pname = "vi-motions";
  version = "0.3";

  pluginName = "motions";

	src = fetchFromGitHub {
		owner = "zsh-vi-more";
		repo = pname;
		rev = version;
		sha256 = "11idlh0wbycxy0q5x6ij9wfwf8mcpx3b5w5xd9skph99pq19kics";
	};
}
