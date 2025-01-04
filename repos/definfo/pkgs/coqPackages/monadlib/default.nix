{
  lib,
  fetchzip,
  mkCoqDerivation,
  coq,
  sets,
  fixedpoints,
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
  pname = "StateMonad";
  inherit version fetcher;
  repo = "monadlib";
  owner = "Wushushu";
  domain = "bitbucket.org";
  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = range "8.15" "8.20";
        out = "816ba614aad4e1d1250d17de4356d5e60d93a23f";
      }
    ] null;

  release."816ba614aad4e1d1250d17de4356d5e60d93a23f".sha256 = "sha256-jhunEWVpf6ZIeHUO3BUmgC6g3n7S3bEDs5VXeiMhBUE=";

  propagatedBuildInputs = [
    sets
    fixedpoints
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/coq/${coq.coq-version}/user-contrib/StateMonad
    mv ./monadnrm ./monaderror $out/lib/coq/${coq.coq-version}/user-contrib/StateMonad
    runHook postInstall
  '';

  meta = {
    homepage = "https://bitbucket.org/qinxiang-SJTU/sets";
    description = "monadlib";
    maintainers = with lib.maintainers; [ definfo ];
    license = lib.licenses.mit;
  };
}
