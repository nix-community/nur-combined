{
  lib,
  fetchzip,
  mkCoqDerivation,
  coq,
  sets,
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
  pname = "VCF";
  inherit version fetcher;
  repo = "fixedpoints";
  owner = "qinxiang-SJTU";
  domain = "bitbucket.org";
  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = range "8.15" "8.20";
        out = "b6b518aab7c5e583071b05b3e21a61fe70bb6cff";
      }
    ] null;

  release."b6b518aab7c5e583071b05b3e21a61fe70bb6cff".sha256 = "sha256-dU1h3lpD7JelaiRiLCaECrqpR7miXY6xl+skw2sq2FI=";

  propagatedBuildInputs = [
    sets
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/coq/${coq.coq-version}/user-contrib/VCF
    mv ./* $out/lib/coq/${coq.coq-version}/user-contrib/VCF
    runHook postInstall
  '';

  meta = {
    homepage = "https://bitbucket.org/qinxiang-SJTU/sets";
    description = "VCF";
    maintainers = with lib.maintainers; [ definfo ];
    license = lib.licenses.mit;
  };
}
