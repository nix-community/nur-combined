{
  pkgs ? import <nixpkgs> { },
}:
pkgs.testers.runNixOSTest {
  name = "fluxdown";
  globalTimeout = 180;

  nodes.machine = {
    imports = [ ../modules/fluxdown.nix ];
    services.fluxdown = {
      enable = true;
      port = 17810;
      environmentFile = "/run/fluxdown.env";
      environment.FLUXDOWN_LANG = "zh";
    };
    environment.systemPackages = [ pkgs.python3 ];
    virtualisation.memorySize = 2048;
  };

  testScript = ''
    import shlex

    def check_http(path, expression):
        script = (
            "import json, urllib.request; "
            f"response = urllib.request.urlopen('http://127.0.0.1:17810{path}', timeout=5); "
            "body = response.read(); "
            f"assert {expression}"
        )
        machine.wait_until_succeeds("python3 -c " + shlex.quote(script), timeout=45)

    start_all()
    machine.succeed("touch /run/fluxdown.env")
    machine.succeed("systemctl restart fluxdown")
    machine.wait_for_unit("fluxdown.service")
    check_http("/", "b'<html' in body.lower() and b'<script' in body.lower()")
    check_http("/api/v1/setup/status", "json.loads(body)['setupRequired'] is True")
    machine.succeed("pgrep -u fluxdown -x fluxdownd")
    machine.succeed("test -d /var/lib/fluxdown/agent")
    machine.succeed("printf 'FLUXDOWN_TOKEN=FluxdownTest2026\n' > /run/fluxdown.env")
    machine.succeed("systemctl restart fluxdown")
    check_http("/api/v1/setup/status", "json.loads(body)['setupRequired'] is False")
    machine.succeed("truncate -s 0 /run/fluxdown.env")
    machine.succeed("systemctl restart fluxdown")
    check_http("/api/v1/setup/status", "json.loads(body)['setupRequired'] is False")
    machine.succeed("systemctl stop fluxdown")
    machine.fail("pgrep -u fluxdown -x fluxdownd")
    machine.fail("pgrep -u fluxdown -x fluxdown-agent")
  '';
}
