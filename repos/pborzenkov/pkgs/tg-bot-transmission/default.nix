{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "tg-bot-transmission";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "pborzenkov";
    repo = "tg-bot-transmission";
    rev = "v${version}";
    sha256 = "078x28r6cnaqwi4sdfz8xw7gvwrv0dllpj0j111iq5kzf7h4iclz";
  };

  vendorSha256 = "0ks1xx2b43890wz985q493wsfvcs6nh1g8zb8jbvwq7nh30phh2n";

  subPackages = [ "cmd/bot" ];

  ldflags = [ "-X main.Version=${version}" ];

  meta = with lib; {
    description = "Telegram bot for Transmission torrent client.";
    homepage = "https://github.com/pborzenkov/tg-bot-transmission";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ pborzenkov ];
  };
}
