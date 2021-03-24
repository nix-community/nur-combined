{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "helm-whatup";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "fabmation-gmbh";
    repo = pname;
    rev = "v${version}";
    sha256 = "1lhvm46dmrg68cg3aj5yminnac2vkivcwhfvg2ahy6fs7y3dchmj";
  };

  vendorSha256 = "0b4ljqnqag2rikdamhq0xdasbnkax7c541cw0nxbndn38n17k9kb";

  postInstall = ''
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
