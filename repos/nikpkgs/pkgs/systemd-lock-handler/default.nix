{
  lib,
  buildGoModule,
  fetchFromSourcehut,
  ...
}: let
  pname = "systemd-lock-handler";
  version = "2.4.2";

in buildGoModule rec {
  inherit pname version;

  src = fetchFromSourcehut {
    owner = "~whynothugo";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-sTVAabwWtyvHuDp/+8FKNbfej1x/egoa9z1jLIMJuBg=";
  };

  vendorHash = "sha256-dWzojV3tDA5lLdpAQNC9NaADGyvV7dNOS3x8mfgNNtA=";

  meta = with lib; {
    description = "Translates systemd-system lock/sleep signals into systemd-user target activations.";
    homepage = "https://git.sr.ht/~whynothugo/systemd-lock-handler";
    license = licenses.isc;
  };
}
