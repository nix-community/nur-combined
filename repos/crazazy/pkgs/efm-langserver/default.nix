{ buildGoModule, fetchFromGitHub, lib}:
buildGoModule rec {
  name = "efm-langserver";
  version = "0.0.6";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "efm-langserver";
    rev = "v${version}";
    sha256 = "1zg13nyf7f10f33hz2yjvphs15i2fz2rncb1ziddbvcimjdas053";
  };
  modSha256 = "0sgx9mnr7352kl39j3c239mf47s8grxpfnjzd4pfjzznlqyvna4q";
  subPackages = ["."];

  meta = with lib; {
    description = "General purpose Language Server";
    homepage = https://github.com/mattn/efm-langserver;
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}

