{ lib, buildGoModule, fetchFromGitHub, installShellFiles }:

buildGoModule rec {
  pname = "spot";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "spot";
    rev = "v${version}";
    hash = "sha256-aacG/s/zo4gMBsRug2i7vUyu1WUg3s+F8wtLsSVt7HQ=";
  };

  vendorHash = null;

  nativeBuildInputs = [ installShellFiles ];

  doCheck = false;

  postInstall = ''
    mv $out/bin/{secrets,spot-secrets}
    installManPage *.1
  '';

  meta = with lib; {
    description = "A tool for effortless deployment and configuration management";
    homepage = "https://simplotask.com/";
    maintainers = [ maintainers.sikmir ];
    license = licenses.mit;
  };
}
