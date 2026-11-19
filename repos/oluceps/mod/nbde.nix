# Policy-gated network-bound unlock of eihort's root (github:milieuim/nbde,
# design in docs/draft/unlock-gate.md). Gates hold one Tang key each for
# eihort; the JWE needs 2 of 3. Nothing here is secret: the JWE and the
# agent's private key stay on eihort's encrypted disk.
{ inputs, ... }:
let
  client = "eihort";
  gates = [
    "yidhra"
    "abhoth"
    "nodens"
  ];

  # Public half of /persist/keys/unlock-agent.ed25519 on eihort
  # (`unlock-gate agent-key --public <key>`).
  agentPublicKey = "lwC760TM3IqUH_s6aBHoqDHrlV8L5cxo95PqCaEYg7M";

  # Set once /persist/keys/crypt-root.jwe exists on eihort: the bootloader
  # install copies it into the initrd and fails while it is missing.
  bound = true;

  meshPort = 7501;
  meshGates =
    config:
    inputs.nixpkgs.lib.genAttrs gates (
      g: "http://[${config.data.node.${g}.unique_addr_nomask}]:${toString meshPort}"
    );
in
{
  flake.modules.nixos.unlock-gate =
    { config, lib, ... }:
    {
      imports = [ inputs.nbde.nixosModules.default ];

      vaultix.secrets.unlock-gate-tg = { };

      services.unlock-gate = {
        enable = agentPublicKey != null;
        gateId = config.networking.hostName;
        # The mesh interface listens on the anchor address only, so it is
        # never reachable from the public internet whatever the firewall says.
        meshAddresses = [ config.data.node.${config.networking.hostName}.unique_addr_nomask ];
        inherit meshPort;
        meshInterface = "vxlan-mesh";
        clients.${client} = {
          inherit agentPublicKey;
          # Either security key may approve.
          approvers = with config.data.keys; [
            skSshPubKey
            skSshPubKey2
          ];
        };
        telegram = {
          tokenFile = config.vaultix.secrets.unlock-gate-tg.path;
          chatId = "-1002215131569";
        };
      };

      assertions = [
        {
          assertion = lib.elem config.networking.hostName gates;
          message = "unlock-gate is imported on ${config.networking.hostName}, which is not in mod/nbde.nix gates.";
        }
      ];
    };

  flake.modules.nixos.unlock-client =
    { config, lib, ... }:
    {
      imports = [ inputs.nbde.nixosModules.default ];

      services.unlock-agent = {
        enable = true;
        keyFile = "/persist/keys/unlock-agent.ed25519";
        gates = meshGates config;
      };

      boot.initrd = lib.mkIf bound {
        nbde = {
          enable = true;
          # LUKS name from mod/disko/eihort.nix.
          volumes.cryptroot.jwe = "/persist/keys/crypt-root.jwe";
        };

        # The agent reaches the gates' public addresses directly from the
        # initrd; DHCPv4 plus SLAAC, as on the running system.
        availableKernelModules = [ "igb" ];
        network.enable = true;
        systemd.network.networks."10-eno1" = {
          matchConfig.MACAddress = config.data.node.${config.networking.hostName}.mac;
          networkConfig = {
            DHCP = "ipv4";
            IPv6AcceptRA = true;
          };
          linkConfig.MTUBytes = "1492";
        };
      };
    };

  flake.modules.nixos.unlock-approve =
    { config, lib, ... }:
    {
      imports = [ inputs.nbde.nixosModules.default ];

      programs.unlock-approve = {
        enable = true;
        inherit client;
        # Key handles of the two security keys (skSshPubKey, skSshPubKey2),
        # tried in order; missing files are skipped and whichever key is
        # plugged in signs. Hosts with the id_sk secret get it first.
        keyFiles =
          lib.optional (config.vaultix.secrets ? id_sk) config.vaultix.secrets.id_sk.path
          ++ map (f: "/home/${config.identity.user}/.ssh/${f}") [
            "id_ed25519_sk_rk_1689543375"
            "id_ed25519_sk_rk_1789088843"
          ];
        gates = meshGates config;
      };
    };
}
