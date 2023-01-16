{ lib
, buildGoModule
, fetchFromGitHub }:

buildGoModule rec {
  pname = "kubectl-oomd";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "jdockerty";
    repo = "kubectl-oomd";
    rev = "v${version}";
    sha256 = "sha256-OqiBIS0I20P8xfGats3eKIpzWmMEYFRdKQxqRMu6aYk=";
  };

  vendorSha256 = "sha256-7zqbvsYHCZB8b5YGfyTVBCXgtsRtRN7v01QsKdo1gDU=";

  doCheck = false;
  subPackages = [ "cmd/plugin" ];

  postInstall = ''
    mv $out/bin/plugin $out/bin/kubectl-oomd
  '';

  meta = with lib; {
    description = "A kubectl plugin that shows pods/containers which have recently been OOMKilled";
    homepage = "https://github.com/jdockerty/kubectl-oomd/";
    license = licenses.asl20;
    maintainers = with maintainers; [ tboerger ];
  };
}
