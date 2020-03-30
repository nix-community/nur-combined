{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "kubernix";
  version = "dev-2020-03-30";

  src = fetchFromGitHub {
    owner = "saschagrunert";
    repo = pname;
    rev = "efc0ab7f590e864c754bc48f4da51560caeb2b18";
    sha256 = "0sxk7016cknl9hzcl933ngfrq1iyak83bk5jmcy64015f6l4fjx9";
  };

  cargoSha256 = "12ka9xxjjj2892wsbd0arlrwgnap41j9118ch67ilk5pbimzi4d6";
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Single dependency Kubernetes clusters for local testing, experimenting and development";
    homepage = https://github.com/saschagrunert/kubernix;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ saschagrunert ];
    platforms = platforms.linux;
  };
}
