{ pkgs }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "IRC-Link-Informant";
  version = "de65edd1c877ecee55a4851a39a19e07e22ae1cc";

  src = pkgs.fetchFromGitHub {
    owner = "afreakk";
    repo = pname;
    rev = version;
    sha256 = "1cghvmv0fnlqrdf5vr7bhpb64zwrqzjzj5wqn6mzrjmmk0hfrwcv";
  };

  cargoSha256 = "05m8ixxgclchcprlpbnk4ivwq5qsp8v5nrflz5lfj1yw90nfqp4h";
  nativeBuildInputs = [pkgs.pkg-config];
  buildInputs = [ pkgs.openssl ];
}
