{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "kubernix";
  version = "dev-2020-04-30";

  src = fetchFromGitHub {
    owner = "saschagrunert";
    repo = pname;
    rev = "5a33f33e58cb95fb2673fdba8da244ab1851d585";
    sha256 = "1kygm3ijpfpy2sypx6kvjg83j7pwy43li55cacifqcwbn4w6sphs";
  };

  cargoSha256 = "0r1q5mj6znny435jw7ch02srgsb5cb6f2iz8s96n5c5vdz60cyj1";
  doCheck = false;

  meta = with stdenv.lib; {
    description = "Single dependency Kubernetes clusters for local testing, experimenting and development";
    homepage = https://github.com/saschagrunert/kubernix;
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ saschagrunert ];
    platforms = platforms.linux;
  };
}
