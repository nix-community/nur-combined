{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "kubernix";
  version = "dev-2020-04-16";

  src = fetchFromGitHub {
    owner = "saschagrunert";
    repo = pname;
    rev = "9368a8f0e0c01e245659fb7516f3a4827db25ef1";
    sha256 = "1ivq1vqmz9w6j1604lip4clfcka29zkk85qzjhsjbfbsp2j86kk3";
  };

  cargoSha256 = "0dipb6amljrf4dma32svln6649lwrlwan7ls3y6w2nfq4swhvzpw";
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Single dependency Kubernetes clusters for local testing, experimenting and development";
    homepage = https://github.com/saschagrunert/kubernix;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ saschagrunert ];
    platforms = platforms.linux;
  };
}
