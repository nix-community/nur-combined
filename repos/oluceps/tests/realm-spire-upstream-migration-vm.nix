# Existing-state migration, using only disposable PKI generated inside the VM.
# nix build -L --impure --no-link --option sandbox true --expr \
#   'import ./tests/realm-spire-upstream-migration-vm.nix {}'
{
  nixpkgs ?
    let
      lock = builtins.fromJSON (builtins.readFile ../flake.lock);
    in
    (builtins.fetchTree lock.nodes.${lock.nodes.root.inputs.nixpkgs}.locked).outPath,
}:
let
  # Use the locked package set for CLIs, services and the shared realm VM.
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  base = import ./realm-spire-fixture.nix { inherit pkgs; };
in
import ./realm-vm.nix {
  inherit nixpkgs;
  testName = "realm-spire-upstream-migration";
  internetTests = true;
  fixture = {
    inherit (base) module startAgent;
  };
  extraModule =
    { config, lib, ... }:
    let
      format = pkgs.formats.hcl1 { };
      settings = lib.filterAttrsRecursive (_: value: value != null) config.services.spire.server.settings;
      oldConfig = format.generate "migration-self-signed.conf" settings;
      upstreamConfig = format.generate "migration-upstream.conf" (
        lib.recursiveUpdate settings {
          plugins.UpstreamAuthority.disk.plugin_data = {
            cert_file_path = "/run/migration-pki/inter.pem";
            key_file_path = "$CREDENTIALS_DIRECTORY/upstream.key";
            bundle_file_path = "/run/migration-pki/anchor.pem";
          };
        }
      );
    in
    {
      environment.systemPackages = [ (lib.hiPrio pkgs.spire) ];
      services.spire.agent.package = pkgs.spire;
      services.spire.server.package = pkgs.spire;
      assertions = [
        {
          assertion = pkgs.spire.version == "1.15.3";
          message = "Migration validates SPIRE 1.15.3";
        }
      ];
      environment.etc = {
        "migration-self-signed.conf".source = oldConfig;
        "migration-upstream.conf".source = upstreamConfig;
      };
      realm.spire.registrations.vm-chain = {
        spiffeID = "spiffe://nyaw.xyz/test/chain";
        selectors = [ "unix:uid:0" ];
      };
      services.spire.agent.settings.agent = {
        workload_x509_svid_key_type = "ec-p384";
        # Native recovery path, accelerated from SPIRE's default 10-minute delay.
        rebootstrap_delay = "5s";
      };
      services.spire.server = {
        # A mutable *test-only* config lets the same daemon/state change upstream
        # after it has already issued self-signed credentials.
        configFile = "/run/migration-server.conf";
        settings.server = {
          ca_key_type = "ec-p384";
          ca_ttl = "30m";
          agent_ttl = "90s";
          default_x509_svid_ttl = lib.mkForce "30s";
        };
      };
      systemd.services.spire-server = {
        requires = [ "migration-pki.service" ];
        after = [ "migration-pki.service" ];
        serviceConfig.LoadCredential = [ "upstream.key:/run/migration-pki/inter.key" ];
      };
      systemd.services.realm-spire-register.postStart = lib.mkAfter ''
        entry_id=$(${pkgs.spire}/bin/spire-server entry show -socketPath /run/spire/server/private/api.sock -spiffeID spiffe://nyaw.xyz/test/chain -output json | ${pkgs.jq}/bin/jq -er '.entries[0].id')
        ${pkgs.spire}/bin/spire-server entry update -socketPath /run/spire/server/private/api.sock -entryID "$entry_id" -parentID spiffe://nyaw.xyz/agent/machine -spiffeID spiffe://nyaw.xyz/test/chain -selector unix:uid:0 -x509SVIDTTL 30
      '';
      systemd.services.migration-pki = {
        wantedBy = [ "multi-user.target" ];
        before = [ "spire-server.service" ];
        path = [
          pkgs.openssl
          pkgs.coreutils
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          UMask = "0077";
        };
        script = ''
          mkdir -p /run/migration-pki
          cd /run/migration-pki
          openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out root.key
          openssl req -new -x509 -key root.key -out root.pem -days 3650 -subj /CN=dummy-Milieuim-root -addext basicConstraints=critical,CA:TRUE,pathlen:1 -addext keyUsage=critical,keyCertSign,cRLSign
          openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out inter.key
          openssl req -new -key inter.key -out inter.csr -subj /CN=dummy-Realm-intermediate
          printf 'basicConstraints=critical,CA:TRUE,pathlen:1\nkeyUsage=critical,keyCertSign,cRLSign\nsubjectKeyIdentifier=hash\nauthorityKeyIdentifier=keyid\n' > inter.ext
          openssl x509 -req -in inter.csr -CA root.pem -CAkey root.key -CAcreateserial -out inter.pem -days 3650 -extfile inter.ext
          cp inter.pem anchor.pem
          chmod 0755 /run/migration-pki
          chmod 0644 inter.pem anchor.pem
          cp /etc/migration-self-signed.conf /run/migration-server.conf
          chmod 0644 /run/migration-server.conf
        '';
      };
    };
  extraTestScript = ''
    import base64
    import datetime
    import hashlib
    import json
    import re
    import shlex
    import time

    server = "${pkgs.spire}/bin/spire-server"
    admin = " -socketPath /run/spire/server/private/api.sock"
    agent = "${pkgs.spire}/bin/spire-agent"
    fetch = agent + " api fetch x509 -socketPath /run/spire/agent/public/api.sock -silent"
    fetch_chain_command = (
        "install -d -m 0700 /run/migration-chain && rm -f /run/migration-chain/* && "
        + fetch + " -write /run/migration-chain && "
        + "(for cert in /run/migration-chain/svid.*.pem; do if openssl x509 -in \"$cert\" -noout -ext subjectAltName | grep -q 'URI:spiffe://nyaw.xyz/test/chain'; then cp \"$cert\" /run/migration-chain/chain.pem; fi; done; test -s /run/migration-chain/chain.pem)"
    )
    started = time.monotonic()
    evidence = {
        "nixpkgs": "${toString nixpkgs}",
        "spire_version": machine.succeed(server + " -version 2>&1").strip(),
        "test_agent_ttl": "90s",
        "test_rebootstrap_delay": "5s (SPIRE default: 10m)",
    }
    assert evidence["spire_version"] == "1.15.3", evidence

    def state(label):
        command = server + " localauthority x509 show" + admin + " -output json"
        machine.wait_until_succeeds(command + " >/dev/null", timeout=60)
        value = json.loads(machine.succeed(command))
        evidence[label] = value
        print(label, json.dumps(value, sort_keys=True))
        return value

    def prepare():
        return json.loads(machine.succeed(server + " localauthority x509 prepare" + admin + " -output json"))["prepared_authority"]["authority_id"]

    def certs(path):
        pem = machine.succeed("cat " + shlex.quote(path))
        return {hashlib.sha256(base64.b64decode(body)).hexdigest() for body in re.findall(r"-----BEGIN CERTIFICATE-----\s*(.*?)\s*-----END CERTIFICATE-----", pem, re.S)}

    def fetch_chain():
        machine.succeed(fetch_chain_command)

    def tls():
        machine.wait_until_succeeds(probe("sender"), timeout=90)
        machine.wait_until_succeeds(business("/index", "-f"), timeout=90)
        machine.wait_until_succeeds(internet("https://public.test/", flags="--cacert /etc/public-fixture.crt -f"), timeout=90)
        machine.fail(probe("imposter"))
        machine.fail(probe("wrong-server"))

    def start_agent():
        machine.succeed("systemctl reset-failed spire-agent.service; systemctl start --no-block spire-agent.service")
        machine.wait_for_unit("spire-agent.service", timeout=90)
        machine.wait_until_succeeds(fetch, timeout=90)

    def stop_agent():
        machine.succeed("systemctl stop spire-agent.service")

    def use_config(upstream):
        name = "upstream" if upstream else "self-signed"
        machine.succeed(f"cp /etc/migration-{name}.conf /run/migration-server.conf; chmod 0644 /run/migration-server.conf; systemctl restart spire-server.service")
        machine.wait_for_unit("spire-server.service", timeout=60)

    def verify_new_chain():
        # The workload must actually refresh; an old still-valid SVID is not proof.
        machine.wait_until_succeeds(fetch_chain_command + " && openssl verify -partial_chain -trusted /run/migration-pki/anchor.pem -untrusted /run/migration-chain/chain.pem /run/migration-chain/chain.pem", timeout=90)
        status, output = machine.execute("openssl verify -trusted /run/migration-pki/root.pem -untrusted /run/migration-chain/chain.pem /run/migration-chain/chain.pem 2>&1")
        assert status != 0 and "path length constraint exceeded" in output, output
        evidence["root_pathlen_rejection"] = output

    with subtest("existing self-signed server, authenticated Agent and real workloads"):
        initial = state("initial")
        old_id = initial["active"]["authority_id"]
        assert not initial["active"].get("upstream_authority_subject_key_id"), initial
        # Intentionally leave an OLD-PKI PREPARED slot, including on restart.
        old_prepared_id = prepare()
        before = state("old-prepared")
        assert before["prepared"]["authority_id"] == old_prepared_id
        machine.succeed(server + " bundle show" + admin + " > /run/old-bootstrap.pem")
        fetch_chain()
        machine.succeed("cp /run/migration-chain/chain.pem /run/old-workload.pem")
        old_certs = certs("/run/old-bootstrap.pem")
        tls()
        # Quiescent snapshot includes SQLite, CA journal, KeyManager and Agent
        # cache/keys. This is test-local rollback evidence, never exported keys.
        stop_agent()
        machine.succeed("systemctl stop spire-server.service; install -d -m 0700 /run/migration-snapshot /run/migration-snapshot/server /run/migration-snapshot/agent; cp -a /var/lib/spire/server/. /run/migration-snapshot/server/; cp -a /var/lib/spire/agent/. /run/migration-snapshot/agent/")
        machine.succeed("systemctl start spire-server.service")
        start_agent()
        db_inode = machine.succeed("stat -c %i /var/lib/spire/server/datastore.sqlite3").strip()

    with subtest("adding upstream preserves both existing authority slots"):
        use_config(True)
        loaded = state("upstream-loaded")
        assert loaded["active"]["authority_id"] == old_id, loaded
        assert loaded["prepared"]["authority_id"] == old_prepared_id, loaded
        assert machine.succeed("stat -c %i /var/lib/spire/server/datastore.sqlite3").strip() == db_inode
        # KeyManager writes atomically; CA IDs plus the existing key file prove
        # recovery, whereas a keys.json inode cannot be stable across prepares.
        machine.succeed("test -s /var/lib/spire/server/keys.json")
        anchor = certs("/run/migration-pki/anchor.pem")
        assert len(anchor) == 1 and anchor.isdisjoint(old_certs)
        machine.succeed(server + " bundle show" + admin + " > /run/bundle-before-prepare.pem")
        evidence["bundle_sha256_before_prepare"] = sorted(certs("/run/bundle-before-prepare.pem"))
        anchor_ski = machine.succeed("openssl x509 -in /run/migration-pki/anchor.pem -noout -ext subjectKeyIdentifier").splitlines()[-1].strip().replace(":", "").lower()
        prepared_id = prepare()
        prepared = state("upstream-prepared")
        assert prepared["active"]["authority_id"] == old_id, prepared
        assert prepared["prepared"]["authority_id"] == prepared_id != old_prepared_id, prepared
        assert prepared["prepared"]["upstream_authority_subject_key_id"].replace(":", "").lower() == anchor_ski, prepared
        machine.succeed(server + " bundle show" + admin + " > /run/dual-bundle.pem")
        dual = certs("/run/dual-bundle.pem")
        assert old_certs <= dual and anchor <= dual, (old_certs, anchor, dual)
        evidence["bundle_sha256"] = {"old": sorted(old_certs), "anchor": sorted(anchor), "dual": sorted(dual)}
        # CLI bundle set explicitly rejects replacing this server's own bundle.
        status, output = machine.execute(server + " bundle set" + admin + " -id spiffe://nyaw.xyz -path /run/migration-pki/anchor.pem 2>&1")
        assert status != 0 and "own trust domain" in output, output
        evidence["own-bundle-set-rejection"] = output
        # Workload API bundle must propagate BEFORE activation. Agent stays live.
        def propagated(_):
            fetch_chain()
            return dual <= certs("/run/migration-chain/bundle.0.pem")
        retry(propagated, timeout=datetime.timedelta(seconds=90))
        evidence["agent_bundle_sha256_before_activation"] = sorted(certs("/run/migration-chain/bundle.0.pem"))
        tls()
        machine.succeed("cp /run/migration-pki/anchor.pem /run/bootstrap.pem; sha256sum /run/bootstrap.pem > /run/long-bootstrap.sha256")
        machine.succeed(server + " localauthority x509 activate" + admin + " -authorityID " + shlex.quote(prepared_id))
        activated = state("activated")
        assert activated["active"]["authority_id"] == prepared_id
        assert activated["old"]["authority_id"] == old_id
        verify_new_chain()
        tls()

    with subtest("fixed long-lived bootstrap supports cold HTTP attestation"):
        stop_agent()
        machine.succeed("rm -rf /var/lib/spire/agent/*; sha256sum -c /run/long-bootstrap.sha256")
        start_agent()
        verify_new_chain()
        tls()
        machine.succeed("systemctl restart spire-server.service")
        machine.wait_for_unit("spire-server.service")
        recovered = state("server-restarted")
        assert recovered["active"]["authority_id"] == prepared_id, recovered
        verify_new_chain()
        tls()

    with subtest("retained old Agent cache expires and automatically rebootstraps"):
        stop_agent()
        machine.succeed("rm -rf /var/lib/spire/agent/*; cp -a /run/migration-snapshot/agent/. /var/lib/spire/agent/; sha256sum /var/lib/spire/agent/agent-data.json > /run/cache.sha256")
        # Real expiry, no cache deletion, fabricated certificate, or clock jump.
        expiry_check = "python3 -c " + shlex.quote("import base64,json,subprocess; d=json.load(open('/var/lib/spire/agent/agent-data.json')); p=subprocess.run(['openssl','x509','-checkend','0','-noout'],input=base64.b64decode(d['svid'][0]),capture_output=True); exit(0 if p.returncode else 1)")
        machine.wait_until_succeeds(expiry_check, timeout=120)
        machine.succeed("sha256sum -c /run/cache.sha256; sha256sum -c /run/long-bootstrap.sha256")
        cursor = machine.succeed("journalctl -u spire-agent -n 0 --show-cursor").split("-- cursor: ")[-1].strip()
        start_agent()
        logs = machine.succeed("journalctl -u spire-agent --after-cursor=" + shlex.quote(cursor) + " -o cat")
        assert "SVID is expired" in logs, logs
        assert "Starting node attestation" in logs, logs
        assert "Trust Bundle and Server don't agree, rebootstrapping" in logs, logs
        assert "Node attestation was successful" in logs, logs
        evidence["expired-cache-reattest"] = logs
        verify_new_chain()
        tls()

    with subtest("old bootstrap fails cold; managed bootstrap update repairs enrollment"):
        stop_agent()
        machine.succeed("rm -rf /var/lib/spire/agent/*; cp /run/old-bootstrap.pem /run/bootstrap.pem")
        cursor = machine.succeed("journalctl -u spire-agent -n 0 --show-cursor").split("-- cursor: ")[-1].strip()
        machine.succeed("systemctl start --no-block spire-agent.service")
        machine.wait_until_succeeds("journalctl -u spire-agent --after-cursor=" + shlex.quote(cursor) + " -o cat | grep -Ei 'unknown authority|certificate verify failed'", timeout=45)
        machine.fail(fetch + " -timeout 2s")
        evidence["old_bootstrap_rejection"] = machine.succeed("journalctl -u spire-agent --after-cursor=" + shlex.quote(cursor) + " -o cat")
        stop_agent()
        machine.succeed("cp /run/migration-pki/anchor.pem /run/bootstrap.pem; sha256sum -c /run/long-bootstrap.sha256")
        start_agent()
        verify_new_chain()
        tls()

    with subtest("configuration rollback creates another self-signed CA; full state rollback restores old PKI"):
        use_config(False)
        rollback = state("configuration-only-rollback")
        # Without an upstream plugin, SPIRE only recovers local CA certificates
        # that are themselves in the bundle. The upstream-signed ACTIVE is not
        # a bundle anchor, and the former self-signed ACTIVE is now OLD. With
        # no recoverable ACTIVE it prepares and activates a NEW self-signed CA.
        assert rollback["active"]["authority_id"] not in [old_id, old_prepared_id, prepared_id], rollback
        assert not rollback["active"].get("upstream_authority_subject_key_id"), rollback
        stop_agent()
        machine.succeed("rm -rf /var/lib/spire/agent/*; sha256sum -c /run/long-bootstrap.sha256")
        cursor = machine.succeed("journalctl -u spire-agent -n 0 --show-cursor").split("-- cursor: ")[-1].strip()
        machine.succeed("systemctl start --no-block spire-agent.service")
        machine.wait_until_succeeds("journalctl -u spire-agent --after-cursor=" + shlex.quote(cursor) + " -o cat | grep -Ei 'unknown authority|certificate verify failed'", timeout=45)
        machine.fail(fetch + " -timeout 2s")
        evidence["configuration_rollback_bootstrap_rejection"] = machine.succeed("journalctl -u spire-agent --after-cursor=" + shlex.quote(cursor) + " -o cat")
        stop_agent()
        machine.succeed("systemctl stop spire-server.service; rm -rf /var/lib/spire/server/* /var/lib/spire/agent/*; cp -a /run/migration-snapshot/server/. /var/lib/spire/server/; cp -a /run/migration-snapshot/agent/. /var/lib/spire/agent/; cp /run/old-bootstrap.pem /run/bootstrap.pem; systemctl start spire-server.service")
        machine.wait_for_unit("spire-server.service")
        restored = state("full-state-rollback")
        assert restored["active"]["authority_id"] == old_id, restored
        assert restored["prepared"]["authority_id"] == old_prepared_id, restored
        start_agent()
        fetch_chain()
        machine.succeed("openssl verify -trusted /run/old-bootstrap.pem -untrusted /run/migration-chain/chain.pem /run/migration-chain/chain.pem")
        tls()

    evidence["migration_seconds"] = round(time.monotonic() - started, 2)
    machine.succeed("journalctl -u spire-server -u spire-agent --no-pager > /run/migration-validation.log")
    machine.succeed("cat > /run/migration-evidence.json <<'MIGRATION_EOF'\n" + json.dumps(evidence, indent=2) + "\nMIGRATION_EOF")
    machine.copy_from_machine("/run/migration-evidence.json")
    machine.copy_from_machine("/run/migration-validation.log")
    print("MIGRATION PASSED", evidence["migration_seconds"], "seconds")
  '';
}
