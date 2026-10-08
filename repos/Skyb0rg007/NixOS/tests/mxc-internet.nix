# Stands in for the public hosts the mxc test scripts probe to prove a sandbox
# can (or cannot) reach the outside world: 1.1.1.1 and 9.9.9.9 for bubblewrap,
# 140.82.114.6 for LXC, all on ports 80 and 443. The machine routes everything
# through this node, which owns those addresses and accepts any connection.
{
  nodes.internet =
    { pkgs, ... }:
    {
      networking.firewall.enable = false;
      networking.interfaces.eth1.ipv4.addresses =
        map
          (address: {
            inherit address;
            prefixLength = 32;
          })
          [
            "1.1.1.1"
            "9.9.9.9"
            "140.82.114.6"
          ];
      systemd.services.anchors = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${pkgs.python3.interpreter} ${pkgs.writeText "anchors.py" ''
          import asyncio

          async def accept(reader, writer):
              writer.close()

          async def main():
              servers = [await asyncio.start_server(accept, "0.0.0.0", port) for port in (80, 443)]
              await asyncio.gather(*(server.serve_forever() for server in servers))

          asyncio.run(main())
        ''}";
      };
    };

  nodes.machine =
    { nodes, ... }:
    {
      networking.defaultGateway = {
        address = nodes.internet.networking.primaryIPAddress;
        interface = "eth1";
      };
    };
}
