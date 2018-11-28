{ lib }: with lib;

rec {
  /*
    The actual container names in are the first 7 letters
    of the node in the deployment by default.
   */
  node2container = substring 0 7;

  /*
    Searches for available containers in the deployment configuration (`resources.machines`)
    and returns all nodes that appear to be container deployments.
   */
  containers = machines: attrNames
    (filterAttrs (_: v: v.deployment.targetEnv == "container") machines);

  /*
    Generates a firewall configuration in an environment with a wireguard interface (wg0),
    a physical interface and containers with their own interfaces.

    By default everything else will be dropped.
   */
  gen-firewall = wg0: eth0: machines:
    let
      mkMachine = m:
        let
          m' = node2container m;
        in
          ''
            ip46tables -A FORWARD -i ${wg0} -o ve-${m'} -j ACCEPT
            ip46tables -A FORWARD -o ve-${m'} -i ${wg0} -j ACCEPT
            ip46tables -A FORWARD -i ve-${m'} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
          '';
    in
      ''
        ip46tables -F FORWARD
        ip46tables -P FORWARD DROP

        ip46tables -A FORWARD -i ${wg0} -o ${eth0} -j ACCEPT
        ip46tables -A FORWARD -i ${eth0} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

        ip46tables -A FORWARD -i ve-+ -o ${eth0} -j ACCEPT
        ip46tables -A FORWARD -o ve-+ -i ${eth0} -j ACCEPT

        ${concatStrings (map mkMachine machines)}
      '';
}
