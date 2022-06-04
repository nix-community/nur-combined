{ stdenvNoCC, fetchFromGitHub }: stdenvNoCC.mkDerivation rec {
  pname = "git-fixup";
  version = "2021-09-19";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    rev = "30d7b7ec18205042ad63c82ef1e082a908050903";
    sha256 = "0g26y9bla50mq2gwkpax3flpqwz6p1sl42xxk8mzhx9m8nwnlp9n";
  };

  installPhase = ''
    runHook preInstall

    install -Dm0755 git-fixup.sh $out/bin/git-fixup

    runHook postInstall
  '';
}
