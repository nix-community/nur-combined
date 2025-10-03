{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "commiter";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "lmdevv";
    repo = "commiter";
    rev = "32b230ef2577d516040671dd3d9394633392e9eb";
    sha256 = "04xg4n5sgs9c0370lzkhrnq9kfwhm9ll2hgnfwv0jnxkrk4h7806";
  };

  vendorHash = null;

  meta = with lib; {
    description = "CLI tool for generating AI-powered commit messages";
    homepage = "https://github.com/lmdevv/commiter";
    license = licenses.mit;
    maintainers = [ "lmdevv" ];
  };
}
