{ fetchFromGitHub, buildZshPlugin }: buildZshPlugin rec {
	pname = "ex-commands";
  version = "2021-05-25";

	src = fetchFromGitHub {
		owner = "zsh-vi-more";
		repo = pname;
		rev = "53854329298afd7ba9544cac9124f95c73cc9e96";
		sha256 = "1ki9l96jpac7srf3gg0wkyx5glsxqmyb8k6d1374phgk99a8gq5q";
	};
}
