{ lib
, buildGoModule
, fetchFromGitHub }:

buildGoModule rec {
  pname = "kubectl-ktop";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "vladimirvivien";
    repo = "ktop";
    rev = "v${version}";
    sha256 = "sha256-9TKXOKGsxtmyTGGVq7GDy4v3I9BF5SDc48dhrj1pw9Q=";
  };

  vendorSha256 = "sha256-IbWdq6t9tgly7MRRIRJK5sDHus+sF0AT843aI4quO3c=";

  doCheck = false;
  subPackages = [ "." ];

  postInstall = ''
    mv $out/bin/ktop $out/bin/kubectl-ktop
  '';

  meta = with lib; {
    description = "A top-like tool for your Kubernetes clusters";
    homepage = "https://github.com/vladimirvivien/ktop/";
    license = licenses.asl20;
    maintainers = with maintainers; [ tboerger ];
  };
}
