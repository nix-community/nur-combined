{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "helm-mapkubeapis";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "helm";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-6NeePXTdp5vlBLfIlWeXQZMZ0Uz/e1ZCgZmJvBJfaFw=";
  };

  vendorSha256 = "sha256-rVrQqeakPQl3rjzmqzHw74ffreLEVzP153wWJ8TEOIM=";

  postFixup = ''
    mkdir $out/${pname}
    mv $out/bin $out/${pname}/
    install -m644 -Dt $out/${pname} plugin.yaml
  '';

  meta = with lib; {
    description = "Helm plugin which map deprecated or removed Kubernetes APIs in a release to supported APIs";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ c0deaddict ];
    platforms = platforms.all;
  };
}
