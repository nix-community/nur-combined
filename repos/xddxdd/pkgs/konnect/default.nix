{ lib
, sources
, buildGoModule
}:

buildGoModule rec {
  inherit (sources.konnect) pname version src;
  vendorSha256 = "sha256-ZrwFUZDTbJx5qvloVOa5qK1ykKNkUn1hjfz0xf+8sWk=";

  meta = with lib; {
    description = "Kopano Konnect implements an OpenID provider (OP) with integrated web login and consent forms.";
    homepage = "https://github.com/Kopano-dev/konnect";
    license = licenses.asl20;
  };
}
