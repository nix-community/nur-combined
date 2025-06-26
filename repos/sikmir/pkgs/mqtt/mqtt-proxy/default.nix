{
  lib,
  fetchFromGitHub,
  buildGoModule,
  cyrus_sasl,
}:

buildGoModule (finalAttrs: {
  pname = "mqtt-proxy";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "grepplabs";
    repo = "mqtt-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-odSVoBBjg4TGP5Jw+7p9+kTBR2JP1ZJUKR3lBcOjK4g=";
  };

  vendorHash = null;

  buildInputs = [ cyrus_sasl ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "MQTT Proxy allows MQTT clients to send messages to other messaging systems";
    homepage = "https://github.com/grepplabs/mqtt-proxy";
    #license = lib.licenses.cc-by-nc-nd-40;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "mqtt-proxy";
  };
})
