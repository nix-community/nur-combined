{ stdenv, lib, fetchFromGitHub, buildGoModule, cyrus_sasl }:

buildGoModule rec {
  pname = "mqtt-proxy";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "grepplabs";
    repo = "mqtt-proxy";
    rev = "v${version}";
    hash = "sha256-odSVoBBjg4TGP5Jw+7p9+kTBR2JP1ZJUKR3lBcOjK4g=";
  };

  vendorHash = null;

  buildInputs = [ cyrus_sasl ];

  ldflags = [ "-X github.com/prometheus/common/version.Version=${version}" ];

  meta = with lib; {
    description = "MQTT Proxy allows MQTT clients to send messages to other messaging systems";
    inherit (src.meta) homepage;
    #license = licenses.cc-by-nc-nd-40;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
