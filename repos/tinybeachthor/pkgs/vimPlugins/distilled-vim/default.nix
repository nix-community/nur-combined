{ buildVimPluginFrom2Nix, fetchFromGitHub }:

buildVimPluginFrom2Nix {
  pname = "distilled-vim";
  version = "2019-08-02";

  src = fetchFromGitHub {
    owner = "KKPMW";
    repo = "distilled-vim";
    rev = "58fe63d119419db9b6924ec9fe90504f4642afee";
    sha256 = "0j3pwclm6j2z0imxsa3km85gnnwhxbc69xlrwnm62l64lfnxammw";
  };
}
