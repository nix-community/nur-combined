{ pkgs, ... }:
let
  watcher =
    pkgs.writers.writePython3 "simpsons-counter"
      {
        libraries = [ pkgs.python3Packages.zstandard ];
        flakeIgnore = [ "E501" ];
      }
      ''
        import datetime
        import glob
        import json
        import os
        import time
        import urllib.error
        import urllib.request

        import zstandard

        BASE = "https://countapi.mileshilliard.com/api/v1"
        KEY = "simpsonspenisthing"
        # /hit fails with "Database error occurred" at or above this
        STUCK = 2**63 - 1
        BODY_LIMIT = 256 * 1024
        INTERVAL = 5
        MAX_INTERVAL = 120
        UA = "simpsons-counter (shelvacu)"


        def fetch(url):
            rec = {"time": datetime.datetime.now(datetime.timezone.utc).isoformat(), "url": url}
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            try:
                try:
                    resp = urllib.request.urlopen(req, timeout=30)
                except urllib.error.HTTPError as e:
                    resp = e
                with resp:
                    rec["status"] = resp.status
                    rec["headers"] = list(resp.headers.items())
                    body = resp.read(BODY_LIMIT + 1)
            except Exception as e:
                rec["error"] = repr(e)
                return rec, None
            rec["truncated"] = len(body) > BODY_LIMIT
            body = body[:BODY_LIMIT]
            rec["body"] = body.decode("utf-8", "backslashreplace")
            return rec, body


        def compress_old(today):
            for name in sorted(glob.glob("*.jsonl")):
                if name == f"{today}.jsonl":
                    continue
                with open(name, "rb") as src, open(f"{name}.zst.tmp", "wb") as dst:
                    zstandard.ZstdCompressor(level=19).copy_stream(src, dst)
                os.rename(f"{name}.zst.tmp", f"{name}.zst")
                os.remove(name)


        current_day = None


        def record(rec):
            global current_day
            day = rec["time"][:10]
            if day != current_day:
                compress_old(day)
                current_day = day
            with open(f"{day}.jsonl", "a") as f:
                f.write(json.dumps(rec) + "\n")


        def value_of(rec, body):
            if body is None or rec.get("status") != 200 or rec["truncated"]:
                return None
            try:
                # parse_int=str: python refuses int() on >4300 digits
                v = json.loads(body, parse_int=str).get("value")
            except (ValueError, AttributeError):
                return None
            return v if isinstance(v, str) else None


        def is_stuck(value):
            # avoid int() on huge strings, python refuses >4300 digits
            digits = value.lstrip("-")
            return not value.startswith("-") and (len(digits) > 19 or int(digits) >= STUCK)


        def main():
            os.chdir(os.environ["STATE_DIRECTORY"])
            delay = INTERVAL
            while True:
                rec, body = fetch(f"{BASE}/get/{KEY}")
                record(rec)
                value = value_of(rec, body)
                ok = value is not None
                if ok and is_stuck(value):
                    rec, body = fetch(f"{BASE}/set/{KEY}?value=0")
                    record(rec)
                    print(f"value can't be incremented, reset: {rec.get('status')} {rec.get('error', ''')}", flush=True)
                if ok:
                    delay = INTERVAL
                else:
                    print(f"get failed: {rec.get('status')} {rec.get('error', ''')}, waiting {delay}s", flush=True)
                time.sleep(delay)
                if not ok:
                    delay = min(delay * 2, MAX_INTERVAL)


        main()
      '';
in
{
  systemd.services.simpsons-counter = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = watcher;
      DynamicUser = true;
      StateDirectory = "simpsons-counter";
      Restart = "always";
      RestartSec = "30s";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
    };
  };
}
