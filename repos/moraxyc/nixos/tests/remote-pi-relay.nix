{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "remote-pi-relay";

  nodes = {
    plain = _: {
      imports = [ ../modules/services/networking/remote-pi-relay.nix ];

      services.remote-pi-relay = {
        enable = true;
        package = pkgs.remote-pi-relay;
      };
    };

    configured =
      { pkgs, ... }:
      {
        imports = [ ../modules/services/networking/remote-pi-relay.nix ];

        environment.systemPackages = [
          (pkgs.python3.withPackages (ps: [
            ps.cryptography
            ps.websockets
          ]))
        ];

        services.remote-pi-relay = {
          enable = true;
          package = pkgs.remote-pi-relay;
          openFirewall = true;
          configureNginx = true;
          settings = {
            REMOTEPI_RELAY_PORT = 8080;
            RELAY_MAX_CT_MIB = 8;
            RUST_LOG = "debug";
          };
        };
      };
  };

  testScript = ''
    start_all()

    plain.wait_for_unit("remote-pi-relay.service")
    plain.wait_for_open_port(3000)

    assert plain.succeed("curl -fs http://127.0.0.1:3000/health") == "OK"
    assert (
        plain.succeed(
            "curl -s -o /dev/null -w '%{http_code}' "
            "http://127.0.0.1:3000/mesh/0000000000000000000000000000000000000000000000000000000000000000"
        )
        == "404"
    )
    plain.succeed("test -f /var/lib/remote-pi-relay/mesh.db")

    # Configured instance: custom port, max_ct_bytes, nginx WebSocket proxy, and graceful restart.
    configured.wait_for_unit("remote-pi-relay.service")
    configured.wait_for_unit("nginx.service")
    configured.wait_for_open_port(8080)
    configured.wait_for_open_port(80)

    assert configured.succeed("curl -fs http://127.0.0.1:8080/health") == "OK"
    assert configured.succeed("curl -fs http://127.0.0.1/health") == "OK"

    logs = configured.succeed("journalctl -u remote-pi-relay.service")
    assert "max_ct_bytes=8388608" in logs, logs

    # Verify full Ed25519 WebSocket handshake through nginx.
    configured.succeed(
        "python3 - <<'EOF'\n"
        "import asyncio, base64, json, websockets\n"
        "from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey\n"
        "from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat\n"
        "\n"
        "async def check():\n"
        "    sk = Ed25519PrivateKey.generate()\n"
        "    pk_b64 = base64.b64encode(sk.public_key().public_bytes(Encoding.Raw, PublicFormat.Raw)).decode()\n"
        "    async with websockets.connect('ws://127.0.0.1/') as ws:\n"
        "        await ws.send(json.dumps({'type': 'hello', 'pubkey': pk_b64}))\n"
        "        challenge = json.loads(await ws.recv())\n"
        "        assert challenge['type'] == 'challenge' and challenge.get('nonce'), challenge\n"
        "        nonce = base64.b64decode(challenge['nonce'])\n"
        "        sig_b64 = base64.b64encode(sk.sign(nonce)).decode()\n"
        "        await ws.send(json.dumps({'type': 'auth', 'sig': sig_b64}))\n"
        "        await ws.ping()\n"
        "\n"
        "asyncio.run(check())\n"
        "EOF"
    )

    configured.succeed("systemctl restart remote-pi-relay.service")
    configured.wait_for_unit("remote-pi-relay.service")
    configured.wait_for_open_port(8080)
    assert configured.succeed("curl -fs http://127.0.0.1/health") == "OK"
    configured.succeed("test -f /var/lib/remote-pi-relay/mesh.db")
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
