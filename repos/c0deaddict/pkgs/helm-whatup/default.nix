{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "helm-whatup";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "fabmation-gmbh";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-/xOa+mfRDKKbu0fNF/SFJZl+aCC0Wx1OFIzmtyyYLI8=";
  };

  vendorSha256 = "sha256-a6Z5gkXDNru6BZwFUtjpatqlVesAw6rajFk8hS2WlCw=";

  postFixup = ''
    install -dm755 $out/${pname}
    mv $out/bin $out/${pname}/
    install -m644 -Dt $out/${pname} plugin.yaml
  '';

  meta = with lib; {
    description = "A Helm plugin to help users determine if there's an update available for their installed charts.";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ c0deaddict ];
    platforms = platforms.all;
  };
}
