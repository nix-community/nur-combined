{ stdenv, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "augr";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "Geemili";
    repo = "augr";
    rev = "v${version}";
    sha256 = "1pxjs2qmak4fy5b8zshzxv6kflh2p65nlhkdvg1ncbn66p6im0wh";
  };

  cargoSha256 = "0ajhwjsll88i9gr1wq2hcmyi7y6zyc96pbmz8siwcnnsv36m2wb3";

  meta = with stdenv.lib; {
    broken = true;

    description = "A simple command line time tracker";
    homepage = https://github.com/Geemili/augr;
    license = licenses.gpl3;
    maintainers = [ maintainers.suhr ];
    platforms = platforms.all;
  };
}
