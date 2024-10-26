{
  lib,
  fetchzip,
  mkCoqDerivation,
  coq,
  version ? null,
}:

let
  fetcher =
    {
      rev,
      repo,
      owner,
      sha256,
      domain,
      ...
    }:
    fetchzip {
      url = "https://${domain}/${owner}/${repo}/get/${rev}.zip";
      inherit sha256;
    };
in
mkCoqDerivation {
  pname = "SetsClass";
  inherit version fetcher;
  repo = "sets";
  owner = "qinxiang-SJTU";
  domain = "bitbucket.org";
  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = range "8.15" "8.20";
        out = "539782edb2d8691ebfdb0a76bdcafac4c9d16f7e";
      }
    ] null;

  release."539782edb2d8691ebfdb0a76bdcafac4c9d16f7e".sha256 = "sha256-YKzg4k70YbnK1XFSSXMKXkxA7tk4pTUPXCLkf9ULsDQ=";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/coq/${coq.coq-version}/user-contrib/SetsClass
    mv ./* $out/lib/coq/${coq.coq-version}/user-contrib/SetsClass
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://bitbucket.org/qinxiang-SJTU/sets";
    description = "SetsClass";
    maintainers = with maintainers; [ ];
    license = licenses.mit;
  };
}
