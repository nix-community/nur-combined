{ stdenvNoCC, fetchFromGitHub }: stdenvNoCC.mkDerivation rec {
  pname = "git-continue";
  version = "2025-08-23";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    rev = "9c03469ff6231d7eb336bf0926b0a4df2176d6ac";
    sha256 = "sha256-IfmSji2DwwJg/uYzkLGIE6mzN5CPC3o9pQ0PtTu5P0U=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm0755 git-continue.sh $out/bin/git-continue

    runHook postInstall
  '';
}
