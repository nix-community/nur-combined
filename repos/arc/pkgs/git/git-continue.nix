{ stdenvNoCC, fetchFromGitHub }: stdenvNoCC.mkDerivation rec {
  pname = "git-continue";
  version = "2022-01-22";

  src = fetchFromGitHub {
    owner = "arcnmx";
    repo = pname;
    rev = "14923252c19dfdd13c3cc403e354cb30e6512eda";
    sha256 = "17zf6cw4wjl6wjbc37bjp84qzpcdv68azhniisb3va6s0m6lx4m1";
  };

  installPhase = ''
    runHook preInstall

    install -Dm0755 git-continue.sh $out/bin/git-continue

    runHook postInstall
  '';
}
