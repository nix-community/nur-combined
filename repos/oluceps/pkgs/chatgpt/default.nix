{ lib
#, stdenv
, fetchFromGitHub
, rustPlatform
# , pkg-config
# , openssl
# , Security
# , CoreServices
}:

rustPlatform.buildRustPackage rec {
  pname = "chatgpt";
  version = "0.7.4";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "lencx";
    repo = pname;
    hash = "sha256-7ns8oiYTPfVwRSLJbny1gxPxqnwZqcy0XuPLR2skj/M=";
  };

  cargoHash = lib.fakeHash;

  # nativeBuildInputs = [ pkg-config ];

  # buildInputs = [ openssl ];

  # cargoBuildFlags = [
  #   "--features=aead-cipher-extra,local-dns,local-http-native-tls,local-redir,local-tun"
  # ];

  # all of these rely on connecting to www.example.com:80
  # checkFlags = [
  #   "--skip=http_proxy"
  #   "--skip=tcp_tunnel"
  #   "--skip=udp_tunnel"
  #   "--skip=udp_relay"
  #   "--skip=socks4_relay_connect"
  #   "--skip=socks5_relay_aead"
  #   "--skip=socks5_relay_stream"
  # ];

  meta = with lib; {
    description = "ChatGPT Desktop Application (Mac, Windows and Linux)";
    homepage = "https://github.com/lencx/ChatGPT";
    license = licenses.asl20;
    maintainers = with maintainers; [ oluceps ];
  };
}
