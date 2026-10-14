{ lib, ... }:
{
  name = "daed-next";

  meta.maintainers = with lib.maintainers; [ ccicnce113424 ];

  nodes.machine =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.curl ];

      services.daed-next.enable = true;
    };

  testScript = ''
    import re

    machine.wait_for_unit("daed-next.service")
    machine.wait_for_open_port(2023)

    # --state and DAED_PRODUCT_LOG_DIR from the module decide where state lands.
    machine.succeed("test -f /var/lib/daed/daed.db")
    machine.succeed("test -f /var/lib/daed/logs/current.jsonl")

    # The dashboard is served from the web root the package points at.
    index = machine.succeed("curl --fail --max-time 10 http://127.0.0.1:2023/")
    assert "<title>daed</title>" in index, index

    asset = re.search(r'(?:src|href)="\./(assets/[^"]+)"', index)
    assert asset, index
    machine.succeed(f"curl --fail --max-time 10 http://127.0.0.1:2023/{asset.group(1)}")

    # The control plane answers unauthenticated health checks.
    machine.succeed("curl --fail --max-time 10 http://127.0.0.1:2023/api/health")
  '';
}
