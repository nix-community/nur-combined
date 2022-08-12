{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "helm-2to3";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "helm";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-gwIDPV56btTY1Mf/Pb8Fb+7T4dHOme+jeK5Wgtnk218=";
  };

  vendorSha256 = "sha256-m2+pKEqJQJSTQffpNRA+Qi8IHCohA26S62RoI991rls=";

  postFixup = ''
    install -dm755 $out/${pname}
    mv $out/bin/${pname} $out/bin/2to3
    mv $out/bin $out/${pname}/
    install -m644 -Dt $out/${pname} plugin.yaml
  '';

  meta = with lib; {
    description = "Helm v3 plugin which migrates and cleans up Helm v2 configuration and releases in-place to Helm v3";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ c0deaddict ];
    platforms = platforms.all;
  };
}
