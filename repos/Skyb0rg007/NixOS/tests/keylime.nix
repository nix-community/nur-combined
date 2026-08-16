let
  # The default UUID shipped in the agent configuration template.
  agentUuid = "d432fbb3-d2f1-4a97-9ef7-75bd81c00000";
in
{
  name = "keylime";
  meta.timeout = 1800; # 30 min

  nodes.machine =
    {
      config,
      lib,
      pkgs,
      rust-keylime,
      ...
    }:
    let
      keylime = config.services.keylime.package;

      # The keylime components refuse to start without a configuration file in
      # /etc/keylime. Upstream generates one from the shipped templates.
      defaultConfig =
        pkgs.runCommand "keylime-default-config"
          {
            nativeBuildInputs = [ keylime ];
          }
          ''
            mkdir -p $out
            keylime_upgrade_config --defaults --out $out
          '';

      configFile = component: {
        "keylime/${component}.conf".source = "${defaultConfig}/${component}.conf";
      };
    in
    {
      virtualisation = {
        memorySize = 2048;
        cores = 2;
        # swtpm, exposed to the guest as /dev/tpm0 and /dev/tpmrm0
        tpm.enable = true;
      };

      # Creates the tss group and the udev rules granting it access to the
      # kernel resource manager device, which the agent drops privileges to.
      security.tpm2.enable = true;

      services.keylime.enable = true;

      environment.systemPackages = [
        keylime
        keylime.info
        rust-keylime
        pkgs.tpm2-tools
      ];

      environment.etc =
        lib.mergeAttrsList (
          map configFile [
            "agent"
            "ca"
            "logging"
            "registrar"
            "tenant"
            "verifier"
          ]
        )
        // {
          # The swtpm instance has no endorsement key certificate, so the
          # tenant cannot check it against the shipped certificate store.
          "keylime/tenant.conf.d/10-test.conf".text = ''
            [tenant]
            require_ek_cert = False
            tpm_cert_store = ${keylime}/share/keylime/tpm_cert_store
          '';

          # Revocation notifications go over ZeroMQ, which the Rust agent does
          # not implement.
          "keylime/agent.conf.d/10-test.conf".text = ''
            [agent]
            uuid = "${agentUuid}"
            enable_revocation_notifications = false
            run_as = "keylime:tss"
          '';
        };

      # The registrar shares the CA that the verifier generates in
      # /var/lib/keylime/cv_ca on first start, and exits if it is not there
      # yet. Ordering the units is not enough since neither notifies systemd
      # about its readiness.
      systemd.services.keylime_registrar.serviceConfig.ExecStartPre = [
        "${pkgs.coreutils}/bin/timeout 120 ${pkgs.bash}/bin/sh -c 'until [ -e /var/lib/keylime/cv_ca/cacert.crt ]; do sleep 1; done'"
      ];

      systemd.services.keylime_agent = {
        description = "The Keylime compute agent";
        after = [
          "network.target"
          "keylime_registrar.service"
        ];
        wants = [ "keylime_registrar.service" ];
        wantedBy = [ "multi-user.target" ];
        # The agent shells out to mount(8) for its tmpfs.
        path = [ pkgs.util-linux ];
        # Started as root to mount the tmpfs holding the agent secrets, then
        # drops privileges to the user configured in 'run_as'.
        serviceConfig = {
          ExecStart = lib.getExe rust-keylime;
          TimeoutSec = "60s";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        environment.RUST_LOG = "keylime_agent=info,keylime=info";
      };
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    with subtest("software TPM is usable"):
      machine.succeed("test -c /dev/tpmrm0")
      machine.succeed("tpm2_getcap properties-fixed")

    with subtest("packaged binaries run"):
      machine.succeed("keylime_tenant --help")
      machine.succeed("keylime-policy --help")
      machine.succeed("keylime_agent --help")

    with subtest("documentation outputs are installed"):
      machine.succeed("man -w keylime_tenant")
      machine.succeed("test -e /run/current-system/sw/share/info/KeylimeDocumentation.info")

    with subtest("verifier and registrar are listening"):
      machine.wait_for_unit("keylime_verifier.service")
      machine.wait_for_unit("keylime_registrar.service")
      machine.wait_for_open_port(8881)
      machine.wait_for_open_port(8890)
      machine.wait_for_open_port(8891)
      machine.succeed("keylime_tenant -c cvlist")

    with subtest("agent registers with the registrar"):
      machine.wait_for_unit("keylime_agent.service")
      machine.wait_for_open_port(9002)
      # The tenant is piped into a file rather than straight into grep: 'grep
      # -q' exits at the first match and the tenant dies of the broken pipe
      # before it can exit 0.
      machine.wait_until_succeeds(
          "keylime_tenant -c reglist > /tmp/reglist && grep -q ${agentUuid} /tmp/reglist",
          timeout=60,
      )
      machine.succeed("keylime_tenant -c regstatus -u ${agentUuid}")

    with subtest("tenant enrolls the agent with the verifier"):
      machine.succeed("keylime_tenant -c add -t 127.0.0.1 -u ${agentUuid}")
      machine.wait_until_succeeds(
          "keylime_tenant -c cvstatus -u ${agentUuid} > /tmp/cvstatus"
          " && grep -q 'Get Quote' /tmp/cvstatus",
          timeout=120,
      )

    with subtest("attestation keeps succeeding"):
      machine.sleep(15)
      machine.succeed("keylime_tenant -c cvstatus -u ${agentUuid} > /tmp/cvstatus")
      machine.succeed("grep -q 'Get Quote' /tmp/cvstatus")

    with subtest("tenant removes the agent"):
      machine.succeed("keylime_tenant -c delete -u ${agentUuid}")
      # Once the verifier answers 404 for the agent the tenant raises UserError
      # and exits non-zero. Grepping the agent list for the absence of the UUID
      # does not work: the tenant prints it in its own progress messages
      # whether or not the agent is still enrolled.
      machine.wait_until_fails("keylime_tenant -c cvstatus -u ${agentUuid}")
      machine.succeed("keylime_tenant -c regdelete -u ${agentUuid}")
  '';
}
