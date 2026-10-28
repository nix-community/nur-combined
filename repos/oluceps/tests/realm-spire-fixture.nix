{
  pkgs,
  host ? "machine",
  address ? "fdcc::91",
}:
{
  module =
    { config, lib, ... }:
    {
      imports = [ ../nixosModules/realm-spire.nix ];
      realm.spire = {
        serverAddress = "::1";
        httpAttestation = {
          trustHttpTransport = true;
          fqdn = "${host}.nyaw.xyz";
          port = 18091;
          agent.trustBundlePath = "/run/bootstrap.pem";
          server.nodes.${host} = {
            fqdn = "${host}.nyaw.xyz";
            addresses = [ address ];
          };
          responder = {
            ipv4Address = null;
            ipv6Address = address;
          };
        };
        server = {
          enable = true;
          registrations.${host} = lib.mapAttrs (
            _: entry: entry // { parentID = "spiffe://${config.realm.trustDomain}/agent/${host}"; }
          ) config.realm.spire.registrations;
        };
      };
    };

  startAgent = ''
    machine.succeed("ip address replace ${address}/128 dev lo")
    machine.wait_for_unit("spire-server.service")
    machine.wait_for_unit("realm-spire-register.service")
    machine.succeed("${pkgs.spire}/bin/spire-server bundle show -socketPath /run/spire/server/private/api.sock > /run/bootstrap.pem")
    machine.succeed("systemctl start --no-block spire-agent.service")
    machine.wait_for_unit("spire-agent.service", timeout=90)
  '';
}
