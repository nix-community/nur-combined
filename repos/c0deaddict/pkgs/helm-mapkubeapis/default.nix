{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "helm-mapkubeapis";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "helm";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6NeePXTdp5vlBLfIlWeXQZMZ0Uz/e1ZCgZmJvBJfaFw=";
  };

  vendorHash = "sha256-rVrQqeakPQl3rjzmqzHw74ffreLEVzP153wWJ8TEOIM=";

  postFixup = ''
    mkdir $out/${pname}
    mv $out/bin $out/${pname}/
    cp -r {config,plugin.yaml} $out/${pname}/
  '';

  meta = with lib; {
    description = "Helm plugin which map deprecated or removed Kubernetes APIs in a release to supported APIs";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ c0deaddict ];
    platforms = platforms.all;
  };
}
