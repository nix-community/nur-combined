{ fetchFromGitHub, buildZshPlugin }: buildZshPlugin rec {
	pname = "vi-quote";
  version = "2021-01-06";

	src = fetchFromGitHub {
		owner = "zsh-vi-more";
		repo = pname;
		rev = "13399086a4c31e8c0e09562ca0c4205ee4c055bd";
		sha256 = "0pci93xscdch2dkrswywxi84x1f9jlh0iw060jhjg8ayvhf7xikk";
	};
}
