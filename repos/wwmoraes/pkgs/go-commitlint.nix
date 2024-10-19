{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
	pname = "commitlint";
	version = "0.10.1";

	src = fetchFromGitHub {
		owner = "conventionalcommit";
		repo = "commitlint";
		rev = "refs/tags/v${version}";
		hash = "sha256-CnwYsF35zr5Gzcgzhky8lkdV9dDTTL85IAE6zDoI19w=";
		leaveDotGit = true;
		postFetch = ''
			cd "$out"
			git rev-parse HEAD > $out/COMMIT
			TZ=UTC0 git show --quiet --date=iso-local --format=%cd > $out/BUILD_TIME
			find "$out" -name .git -print0 | xargs -0 rm -rf
		'';
	};

	vendorHash = "sha256-4fV75e1Wqxsib0g31+scwM4DYuOOrHpRgavCOGurjT8=";

	ldflags = [
		"-s"
		"-w"
		"-X github.com/conventionalcommit/commitlint/internal.version=v${version}"
	];

	preBuild = ''
		ldflags+=" -X 'github.com/conventionalcommit/commitlint/internal.commit=$(cat COMMIT)'"
		ldflags+=" -X 'github.com/conventionalcommit/commitlint/internal.buildTime=$(cat BUILD_TIME)'"
	'';

	tags = [
		"urfave_cli_no_docs"
	];

	meta = with lib; {
		description = "commitlint checks if your commit messages meets the conventional commit format";
		homepage = "https://github.com/conventionalcommit/commitlint";
		license = licenses.mit;
		maintainers = with maintainers; [ wwmoraes ];
	};
}
