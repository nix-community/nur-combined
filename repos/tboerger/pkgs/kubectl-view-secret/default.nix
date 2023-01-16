{ lib
, buildGoModule
, fetchFromGitHub }:

buildGoModule rec {
  pname = "kubectl-view-secret";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "elsesiy";
    repo = "kubectl-view-secret";
    rev = "v${version}";
    sha256 = "sha256-YBPwJQFP0B0YhJ/ecbCW+ko8byu4Y4Yv2IGH7GQT4PA=";
  };

  vendorSha256 = "sha256-DyC9HiUt4Oyc6q1nFN7Uis+odREW6e/oQpzf2DNvJz8=";

  doCheck = false;
  subPackages = [ "cmd" ];

  postInstall = ''
    mv $out/bin/cmd $out/bin/kubectl-view_secret
  '';

  meta = with lib; {
    description = "A kubectl plugin to decode Kubernetes secrets";
    homepage = "https://github.com/elsesiy/kubectl-view-secret/";
    license = licenses.mit;
    maintainers = with maintainers; [ tboerger ];
  };
}
