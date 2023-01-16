{ lib
, buildGoModule
, fetchFromGitHub }:

buildGoModule rec {
  pname = "kubectl-resource-versions";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "chengshiwen";
    repo = "kubectl-resource-versions";
    rev = "v${version}";
    sha256 = "sha256-iHxJCM7mTHAQXbcrAvfocs+EEw/1xliA7qd1AcAEaPc=";
  };

  vendorSha256 = "sha256-7tVHrQGfU8/GhGI4P7he8OeE1vZ3wrnu+tbT97WxVAU=";

  doCheck = false;
  subPackages = [ "." ];

  postInstall = ''
    mv $out/bin/kubectl-resource-versions $out/bin/kubectl-resource_versions
  '';

  meta = with lib; {
    description = "A kubectl plugin to print the supported API resources";
    homepage = "https://github.com/chengshiwen/kubectl-resource-versions/";
    license = licenses.asl20;
    maintainers = with maintainers; [ tboerger ];
  };
}
