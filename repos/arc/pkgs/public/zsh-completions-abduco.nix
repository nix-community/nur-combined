{ fetchFromGitHub, stdenvNoCC }: stdenvNoCC.mkDerivation {
	pname = "zsh-completions-abduco";
	version = "2019-04-27";

	src = fetchFromGitHub {
		owner = "arcnmx";
		repo = "zsh-abduco-completion";
		rev = "d8df9f1343d33504d43836d02f0022c1b2b21c0b";
		sha256 = "1n40c2dk7hcpf0vjj6yk0d8lvppsk2jb02wb0zwlq5r72p2pydxf";
	};

	skipBuild = true;

	installPhase = ''
		runHook preInstall

		install -Dm0755 -t $out/share/zsh/site-functions _abduco

		runHook postInstall
	'';

	meta.priority = -10;
}
