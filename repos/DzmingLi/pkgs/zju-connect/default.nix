{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
  pkg-config,
  stdenv,
}:
buildGoModule (finalAttrs: {
  pname = "zju-connect";
  version = "nightly-unstable-2026-06-24";
  src = fetchFromGitHub {
    owner = "Mythologyli";
    repo = "zju-connect";
    rev = "d598a232a5a706cb98dc681794a1d8fe4be4028d";
    hash = "sha256-hjT+FDh5jtXIJW1SMl24V6JwalViHzBoz7v1V2Ot1AA=";
  };
  vendorHash = "sha256-lDxroSrPwwYF2w7qXR+PQYkre8E+nOwPzDiMoeScjO0=";

  patches = [
    # Sangfor tunnel resilience patch. Three independent but related
    # mitigations against server-side enforcement that otherwise crashes
    # the gvisor-backed SOCKS5 mode (observed extensively at HUST):
    #
    # 1. Periodic /por/update_session.csp keepalive ping. Without this,
    #    sangfor deployments with strict idle timeout close the session,
    #    surfacing as "broken pipe" / panic cascades in the tunnel layer.
    #    Mirrors what the official EasyConnect client does.
    #
    # 2. Typed handling of HandCmdMsg cmd codes returned by the server
    #    (cmd 0x08 SHUTDOWN, 0x05/0x06/0x07/0x09 RECONNECTLATER), and
    #    clean process exit on SHUTDOWN instead of panicking with a
    #    gvisor stack trace. Identified via reverse engineering of
    #    svpnservice (jumptable @ 0x4e6fd0 in EasyConnect 7.6.7).
    #
    # 3. Client-side ACL filter at the dialer. When proxy_all forces VPN
    #    routing for a dst:port not in the server-issued IPResources
    #    whitelist, refuse the connection locally instead of forwarding
    #    upstream — the server's response to a non-whitelisted packet is
    #    to terminate the entire L3 tunnel (cmd 0x08), killing all
    #    in-flight connections. Mirrors what CSClient does in the
    #    official client.
    ./sangfor-resilience.patch
  ];

  buildInputs = [
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    mainProgram = "zju-connect";
    description = "SSL VPN client based on EasierConnect";
    homepage = "https://github.com/Mythologyli/zju-connect";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.unix;
  };
})
