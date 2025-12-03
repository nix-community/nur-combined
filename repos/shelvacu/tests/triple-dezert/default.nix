{ vaculib, vacuRoot, ... }:
{
  name = "trip-megatest";

  nodes.triple-dezert =
    { lib, config, ... }:
    let
      domains = builtins.attrNames config.security.acme.certs;
      disableAcmes = vaculib.mapListToAttrs (d: {
        name = "acme-${d}";
        value = {
          enable = lib.mkForce false;
        };
      }) domains;
      reEnableSelfsigned = vaculib.mapListToAttrs (d: {
        name = "acme-selfsigned-${d}";
        value = {
          wantedBy = [ "container@frontproxy.service" ];
          before = [ "container@frontproxy.service" ];
        };
      }) domains;
      unitsToDisable = [
        "container@vacustore.service"
        "container@nix-cache-nginx.service"
        "openvpn-awootrip.service"
      ];
      disableUnits = vaculib.mapNamesToAttrsConst { enable = lib.mkForce false; } unitsToDisable;
    in
    {
      imports = [
        /${vacuRoot}/common
        /${vacuRoot}/hosts/triple-dezert
      ];
      vacu.underTest = true;
      systemd.services = disableAcmes // reEnableSelfsigned;
      systemd.units = disableUnits;
      boot.zfs.extraPools = lib.mkForce [ ];
      security.acme.defaults.email = lib.mkForce "me@example.org";
      security.acme.defaults.server = lib.mkForce "https://example.com"; # self-signed only
    };

  skipTypeCheck = true;

  testScript = ''
    import re
    import time

    start_all()
    triple_dezert.wait_for_unit("container@frontproxy.service")
    def check_running():
      output = triple_dezert.succeed("nixos-container run frontproxy -- systemctl --no-pager show haproxy")
      line_pattern = re.compile(r"^([^=]+)=(.*)$")
      def tuple_from_line(line):
        match = line_pattern.match(line)
        assert match is not None
        return match[1], match[2]

      unit_info = dict(tuple_from_line(line) for line in output.split("\n") if line_pattern.match(line))
      state = unit_info["ActiveState"]
      if state == "failed":
        triple_dezert.execute("nixos-container run frontproxy -- journalctl -u haproxy")
        raise Exception("haproxy failed")
      if state == "active":
        return True
      if state == "inactive":
        status, jobs = triple_dezert.execute("nixos-container run frontproxy -- systemctl --no-pager list-jobs --full 2>&1")
        if "No jobs" in jobs:
          raise Exception("haproxy is inactive and no jobs")
      return False

    success = False
    for _ in range(60):
      if check_running():
        success = True
        break
      time.sleep(1)
    if not success:
      raise Exception("Timeout")
    triple_dezert.wait_for_open_port(80)
    triple_dezert.succeed("curl -vv http://shelvacu.com/ --resolve shelvacu.com:80:127.0.0.1")
  '';
}
