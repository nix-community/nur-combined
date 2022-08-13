{ pkgs, lib, buildGo117Module, fetchFromGitHub }:

buildGo117Module rec {
  pname = "gloc";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-VgfbFEUmfW4KJLnaimUkwx7T3kyVp0kvQ0NzEQYJK+I=";
  };

  vendorSha256 = "sha256-4E6Plktk91pMqUEnTy5iqzae2jqbd5c28GiPuxffrfI=";
  proxyVendor = true;

  meta = with lib; {
    description = "Run a shell command in all the git repos in a directory";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/gloc";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
