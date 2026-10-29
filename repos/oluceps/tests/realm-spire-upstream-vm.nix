# Isolated dummy PKI only. No host credentials or production connectivity.
# nix build --impure --no-link --expr '(import ./tests/realm-spire-upstream-vm.nix { nixpkgs = /nix/store/...-source; }).case4'
{ nixpkgs }:
let
  pkgs = import nixpkgs { system = "x86_64-linux"; };
  base = import ./realm-spire-fixture.nix { inherit pkgs; };
  makeCase =
    number:
    import ./realm-vm.nix {
      inherit nixpkgs;
      internetTests = true;
      testName = "realm-spire-upstream-case${toString number}";
      fixture = {
        inherit (base) module;
        startAgent = ''
          machine.succeed("ip address replace fdcc::91/128 dev lo")
          machine.wait_for_unit("realm-test-ca.service")
          machine.wait_for_unit("spire-server.service", timeout=60)
          machine.wait_for_unit("realm-spire-register.service")
          machine.succeed("cmp /run/bootstrap.pem /run/realm-test-ca/anchor.pem; sha256sum /run/bootstrap.pem > /run/bootstrap.sha256")
          machine.succeed("systemctl start --no-block spire-agent.service")
          machine.wait_for_unit("spire-agent.service", timeout=90)
        '';
      };
      extraModule = { lib, ... }: {
        assertions = [
          {
            assertion = pkgs.spire.version == "1.15.3";
            message = "This test validates SPIRE 1.15.3";
          }
        ];
        realm.spire.registrations.vm-chain = {
          spiffeID = "spiffe://nyaw.xyz/test/chain";
          selectors = [ "unix:uid:0" ];
        };
        services.spire.agent.settings.agent.workload_x509_svid_key_type = "ec-p384";
        services.spire.server.settings = {
          server = {
            ca_key_type = "ec-p384";
            # Accelerated native lifecycle; do not move the VM clock.
            ca_ttl = "3m";
            default_x509_svid_ttl = lib.mkForce "30s";
          };
          plugins.UpstreamAuthority.disk.plugin_data = {
            cert_file_path = "/run/realm-test-ca/upstream.pem";
            key_file_path = "$CREDENTIALS_DIRECTORY/upstream.key";
            bundle_file_path = "/run/realm-test-ca/anchor.pem";
          };
        };
        systemd.services.spire-server = {
          requires = [ "realm-test-ca.service" ];
          after = [ "realm-test-ca.service" ];
          # Dummy key access for the existing dynamic user, scoped to this unit.
          serviceConfig.LoadCredential = [ "upstream.key:/run/realm-test-ca/upstream.key" ];
        };
        systemd.services.realm-test-ca = {
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
            mkdir -p /run/realm-test-ca
            cd /run/realm-test-ca
            openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out upstream.key
            ${
              if number == 3 then
                ''
                  openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out dummy-root.key
                  openssl req -new -x509 -key dummy-root.key -out dummy-root.pem -days 3650 -subj /CN=dummy-P256-root -addext basicConstraints=critical,CA:TRUE,pathlen:1 -addext keyUsage=critical,keyCertSign,cRLSign
                  openssl req -new -key upstream.key -out upstream.csr -subj /CN=dummy-P384-intermediate
                  printf 'basicConstraints=critical,CA:TRUE,pathlen:1\nkeyUsage=critical,keyCertSign,cRLSign\nsubjectKeyIdentifier=hash\nauthorityKeyIdentifier=keyid\n' > upstream.ext
                  openssl x509 -req -in upstream.csr -CA dummy-root.pem -CAkey dummy-root.key -CAcreateserial -out upstream.pem -days 3650 -extfile upstream.ext
                ''
              else
                ''
                  openssl req -new -x509 -key upstream.key -out upstream.pem -days 3650 -subj /CN=dummy-P384-root -addext basicConstraints=critical,CA:TRUE,pathlen:1 -addext keyUsage=critical,keyCertSign,cRLSign
                ''
            }
            cp upstream.pem anchor.pem
            cp anchor.pem /run/bootstrap.pem
            chmod 0755 /run/realm-test-ca
            chmod 0644 upstream.pem anchor.pem /run/bootstrap.pem
          '';
        };
      };
      extraTestScript = ''
        import json
        import re
        import shlex

        server = "${pkgs.spire}/bin/spire-server"
        admin = " -socketPath /run/spire/server/private/api.sock"
        agent = "${pkgs.spire}/bin/spire-agent"

        def authorities():
            return json.loads(machine.succeed(server + " localauthority x509 show" + admin + " -output json"))

        def chain():
            machine.succeed("rm -rf /run/test-chain; mkdir /run/test-chain")
            machine.succeed(agent + " api fetch x509 -socketPath /run/spire/agent/public/api.sock -write /run/test-chain")
            # Several test-only root identities share this selector. Select the
            # requested URI rather than depending on the Workload API order.
            machine.succeed("for cert in /run/test-chain/svid.*.pem; do if openssl x509 -in \"$cert\" -noout -ext subjectAltName | grep -q 'URI:spiffe://nyaw.xyz/test/chain'; then cp \"$cert\" /run/test-chain/chain.pem; fi; done; test -s /run/test-chain/chain.pem")
            machine.succeed("openssl verify -partial_chain -trusted /run/bootstrap.pem -untrusted /run/test-chain/chain.pem /run/test-chain/chain.pem")
            if ${toString number} == 4:
                machine.succeed("openssl verify -trusted /run/bootstrap.pem -untrusted /run/test-chain/chain.pem /run/test-chain/chain.pem")
            machine.succeed("openssl x509 -in /run/test-chain/chain.pem -noout -text | grep -F spiffe://nyaw.xyz/test/chain")
            certificates = machine.succeed("openssl crl2pkcs7 -nocrl -certfile /run/test-chain/chain.pem | openssl pkcs7 -print_certs -text")
            curves = re.findall(r"ASN1 OID: (\S+)", certificates)
            assert len(curves) >= 2 and all(curve == "secp384r1" for curve in curves), curves
            print("Workload chain curves:", curves)
            machine.succeed("sha256sum -c /run/bootstrap.sha256")

        def tls():
            machine.wait_until_succeeds(probe("sender"), timeout=90)
            machine.wait_until_succeeds(business("/index", "-f"), timeout=90)
            machine.wait_until_succeeds(internet("https://public.test/", flags="--cacert /etc/public-fixture.crt -f"), timeout=90)
            machine.fail(probe("imposter"))
            machine.fail(probe("wrong-server"))

        def cold_enroll():
            machine.succeed("systemctl stop spire-agent.service; rm -rf /var/lib/spire/agent/*")
            machine.succeed("sha256sum -c /run/bootstrap.sha256; systemctl start --no-block spire-agent.service")
            machine.wait_for_unit("spire-agent.service", timeout=90)
            chain()
            tls()
            machine.succeed("systemctl restart spire-agent.service")
            chain()
            tls()

        with subtest("HTTP enrolled workload chain and stable anchor"):
            chain()
            machine.succeed("openssl x509 -in /run/realm-test-ca/upstream.pem -noout -text | grep -F secp384r1")
            if ${toString number} == 3:
                # The P256 root pathlen1 disallows the second subordinate CA.
                status, error = machine.execute("openssl verify -trusted /run/realm-test-ca/dummy-root.pem -untrusted /run/test-chain/chain.pem /run/test-chain/chain.pem 2>&1")
                assert status != 0 and "path length constraint exceeded" in error, error
                machine.succeed("test $(grep -c 'BEGIN CERTIFICATE' /run/bootstrap.pem) = 1")
            print("Initial authorities:", authorities())
            tls()

        with subtest("native timed CA preparation and activation"):
            # Initial activation plus one native activation, with no admin mutation.
            machine.wait_until_succeeds("test $(journalctl -u spire-server -o cat | grep -c 'X509 CA activated') -ge 2", timeout=480)
            machine.succeed("journalctl -u spire-server -o cat | grep 'X509 CA prepared'")
            print("After native rollover:", authorities())
            cold_enroll()

        with subtest("forced local authority rollover"):
            prepared = json.loads(machine.succeed(server + " localauthority x509 prepare" + admin + " -output json"))
            print("Prepared authority:", prepared)
            authority_id = prepared["prepared_authority"]["authority_id"]
            machine.succeed(server + " localauthority x509 activate" + admin + " -authorityID " + shlex.quote(authority_id))
            cold_enroll()
            machine.succeed("systemctl restart spire-server.service")
            machine.wait_for_unit("spire-server.service")
            chain()
            tls()
            machine.succeed("journalctl -u spire-server -u spire-agent --no-pager > /run/upstream-validation.log")
      '';
    };
in
{
  case3 = makeCase 3;
  case4 = makeCase 4;
}
