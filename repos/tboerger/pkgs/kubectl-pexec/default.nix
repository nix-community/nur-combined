{ lib
, buildGoModule
, fetchFromGitHub }:

buildGoModule rec {
  pname = "kubectl-pexec";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ssup2";
    repo = "kpexec";
    rev = "v${version}";
    sha256 = "sha256-3teKIjBc8ToCON+LcVD+WCOSzmYmDHW0T1t8tbodg3Q=";
  };

  vendorSha256 = "sha256-HmRwez3NFSF97Dc6fD/Tt78qNDjovkhlfqloYo2qG68=";

  doCheck = false;
  subPackages = [ "cmd/kpexec" ];

  postInstall = ''
    mv $out/bin/kpexec $out/bin/kubectl-pexec
  '';

  meta = with lib; {
    description = "A kubectl plugin to run commands in a container with high privileges";
    homepage = "https://github.com/ssup2/kpexec/";
    license = licenses.mit;
    maintainers = with maintainers; [ tboerger ];
  };
}
