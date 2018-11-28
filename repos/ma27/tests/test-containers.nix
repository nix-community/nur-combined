{ lib, node2container, containers, gen-firewall }:

lib.runTests {

  testNode2Container = {
    expr = node2container "hartzfor";
    expected = "hartzfo";
  };

  testContainers = {
    expr =
      let deployment = { a.deployment.targetEnv = "container"; b.deployment.targetEnv = "none"; };
      in
        containers deployment;

    expected = [ "a" ];
  };

  testGenFirewall = {
    expr = lib.removeSuffix "\n" (lib.removeSuffix "\n" (gen-firewall "wg0" "eth0" [ "a" "b" "c" ]));
    expected = lib.removeSuffix "\n" ''
      ip46tables -F FORWARD
      ip46tables -P FORWARD DROP

      ip46tables -A FORWARD -i wg0 -o eth0 -j ACCEPT
      ip46tables -A FORWARD -i eth0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

      ip46tables -A FORWARD -i ve-+ -o eth0 -j ACCEPT
      ip46tables -A FORWARD -o ve-+ -i eth0 -j ACCEPT

      ip46tables -A FORWARD -i wg0 -o ve-a -j ACCEPT
      ip46tables -A FORWARD -o ve-a -i wg0 -j ACCEPT
      ip46tables -A FORWARD -i ve-a -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      ip46tables -A FORWARD -i wg0 -o ve-b -j ACCEPT
      ip46tables -A FORWARD -o ve-b -i wg0 -j ACCEPT
      ip46tables -A FORWARD -i ve-b -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      ip46tables -A FORWARD -i wg0 -o ve-c -j ACCEPT
      ip46tables -A FORWARD -o ve-c -i wg0 -j ACCEPT
      ip46tables -A FORWARD -i ve-c -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    '';
  };

}
