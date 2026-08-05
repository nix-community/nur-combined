{
  fetchFromGitHub,
  buildGoModule,
  lib,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "masque-go";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "quic-go";
    repo = "masque-go";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OvY+/3PtqmFNNwgMSOPSoqZAhHcpYDAJRyJDy/oIrgg=";
  };
  vendorHash = "sha256-UypofpTr5F1QvuJHhmy7SxKDUHljWeXYC4lUDB0kiMI=";

  # This test requires a working DNS server
  checkFlags = [ "-skip=^TestProxyNXDOMAIN$" ];

  postInstall = ''
    mv $out/bin/{,masque-go-}client
    mv $out/bin/{,masque-go-}proxy
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Implementation of RFC 9298 based on quic-go";
    longDescription = ''
      masque-go is a part of the quic-go protocol suite.
      masque-go implements the protocol described in Proxying UDP in HTTP (RFC 9298).
      It is also called MASQUE or CONNECT-UDP.

      The proxy can be started with the following:

      ```
      $ openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem \
          -sha256 -days 10 -nodes -addext "subjectAltName = localhost"
      $ template='https://localhost:8080/masque?h={target_host}&p={target_port}'
      $ masque-go-proxy -b [::]:8080 -c cert.pem -k key.pem -t "$template"
      ```

      The client can connect with:

      ```
      $ masque-go-client -t "$template" https://www.example.com
      ```
    '';
    homepage = "https://quic-go.net";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
