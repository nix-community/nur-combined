# Pure vmalert/Prometheus groups. The caller supplies the expected independent
# scrape/HTTP-agent cohort (eihort, abhoth, azasos, nodens, yidhra, hastur).
# Assumes realm metrics are enabled under the current NixOS module on every node:
# observability is required and always supplies a caddy_loaded workload holder.
# Never use the duplicate identity-spiffe gateway scrape for exporter health.
# Eihort is the admin observer/server; central metric node != scrape instance.
{ nodes }:
let
  inherit (builtins) concatLists map;
  metric = name: ''${name}{job="realm-identity"}'';
  match = "on (instance, job, monitor)";
  up = ''up{job="realm-identity"} == 1'';
  fresh = collector: ''realm_identity:collector_fresh{collector="${collector}"}'';
  holderMatch = "on (instance, job, monitor, node, unit, identity, source)";
  holderNote = "Source {{ $labels.source }}: ghostunnel_status_watch checks a separate certificate watch. caddy_loaded uses the actual SDK source. envoy_loaded reads public admin /certs metadata.";
  alert = name: expr: duration: severity: description: {
    alert = name;
    inherit expr;
    for = duration;
    labels.severity = severity;
    annotations = {
      summary = "${name} on {{ $labels.instance }}";
      inherit description;
    };
  };
  expected = record: labels: {
    inherit record labels;
    expr = "vector(1)";
  };
  collectors =
    node:
    [
      "bundle"
      "bootstrap"
      "canary"
      "workloads"
    ]
    ++ (
      if node == "eihort" then
        [
          "agents"
          "aliases"
        ]
      else
        [ ]
    );
  # Inventory can detect a removed holder for 15 minutes. The function receives
  # hostnames only, so it cannot know a unit removed before that window.
  inventory = ''
    group without (__name__) (
      {job="realm-identity",__name__=~"realm_workload_svid_(observation_success|dormant|last_attempt_timestamp_seconds)"}
      or max_over_time(realm_workload_svid_last_attempt_timestamp_seconds{job="realm-identity"}[15m])
    )
  '';
in
[
  {
    name = "realm_identity";
    interval = "30s";
    rules =
      map (
        node:
        expected "realm_identity:expected_node" {
          inherit node;
          instance = node;
          job = "realm-identity";
        }
      ) nodes
      ++ map (
        node:
        expected "realm_identity:expected_agent" {
          inherit node;
          instance = "eihort";
          job = "realm-identity";
        }
      ) nodes
      ++ concatLists (
        map (
          node:
          map (
            job:
            expected "realm_identity:expected_native_target" {
              inherit node job;
              instance = node;
            }
          ) ([ "spire-agent" ] ++ (if node == "eihort" then [ "spire-server" ] else [ ]))
        ) nodes
      )
      ++ concatLists (
        map (
          node:
          map (
            collector:
            expected "realm_identity:expected_collector" {
              inherit node collector;
              instance = node;
              job = "realm-identity";
            }
          ) (collectors node)
        ) nodes
      )
      ++ [
        {
          record = "realm_identity:collector_fresh";
          expr = ''
            (${metric "realm_identity_collector_last_collection_timestamp_seconds"} > time() - 65)
            and (${metric "realm_identity_collector_last_collection_timestamp_seconds"} > 0)
            and (${metric "realm_identity_collector_last_collection_timestamp_seconds"} <= time())
            and ${match} (${up})
          '';
        }
        {
          record = "realm_identity:holder_inventory";
          expr = inventory;
        }
        {
          record = "realm_identity:holder_fresh";
          expr = ''
            (${metric "realm_workload_svid_last_attempt_timestamp_seconds"} > time() - 65)
            and (${metric "realm_workload_svid_last_attempt_timestamp_seconds"} > 0)
            and (${metric "realm_workload_svid_last_attempt_timestamp_seconds"} <= time())
            and ${match} (${fresh "workloads"})
          '';
        }
        (alert "RealmIdentityScrapeDown" ''up{job="realm-identity"} == 0'' "2m" "critical"
          "Check the independent WireGuard listener and exporter on {{ $labels.instance }}. This scrape does not require the SPIFFE gateway."
        )
        (alert "RealmIdentityScrapeMissing"
          ''
            realm_identity:expected_node unless on (instance) up{job="realm-identity"}
          ''
          "3m"
          "critical"
          "Restore the realm-identity scrape target for {{ $labels.node }}. No up series exists. The static cohort cannot retain absent scrape labels."
        )
        (alert "RealmIdentityCollectorMetricsMissing"
          ''
            (${up}) unless ${match} ${metric "realm_identity_collector_success"}
          ''
          "3m"
          "critical"
          "Check the exporter response and metric filters. The independent scrape works but all collector status series are absent."
        )
        (alert "RealmIdentityCollectorSeriesMissing"
          ''
            (
              (realm_identity:expected_collector unless on (instance, collector)
                ${metric "realm_identity_collector_success"})
              and on (instance) (${up})
              and on (instance) ${metric "realm_identity_collector_success"}
            )
            or (
              (${metric "realm_identity_collector_success"}
                unless on (instance, job, monitor, collector) ${metric "realm_identity_collector_last_collection_timestamp_seconds"})
              and ${match} (${up})
            )
            or (
              (${metric "realm_identity_collector_last_collection_timestamp_seconds"}
                unless on (instance, job, monitor, collector) ${metric "realm_identity_collector_success"})
              and ${match} (${up})
            )
          ''
          "3m"
          "warning"
          "Restore status and completion timestamps for collector {{ $labels.collector }}. Partial metrics cannot establish collection health."
        )
        (alert "RealmIdentityCollectorStale"
          ''
            ((${metric "realm_identity_collector_last_collection_timestamp_seconds"} <= time() - 65)
              or (${metric "realm_identity_collector_last_collection_timestamp_seconds"} == 0)
              or (${metric "realm_identity_collector_last_collection_timestamp_seconds"} > time()))
            and ${match} (${up})
          ''
          "3m"
          "warning"
          "Check the exporter cycle and clock for collector {{ $labels.collector }}. Zero means no completed cycle. Old success counters do not establish freshness."
        )
        (alert "RealmIdentityCollectorFailed"
          ''
            (${metric "realm_identity_collector_success"} == 0)
            and on (instance, job, monitor, collector) realm_identity:collector_fresh
          ''
          "3m"
          "warning"
          "Check exporter logs for collector {{ $labels.collector }}. Collection is current but failed. Workload details identify failed holders and exclude dormant units."
        )
        (alert "RealmIdentityBootstrapTrustInvalid"
          ''
            (${metric "realm_bootstrap_bundle_server_trust_valid"} == 0)
            and ${match} (${fresh "bootstrap"})
          ''
          "3m"
          "critical"
          "Check the pinned bundle and SPIRE Server TLS identity. This probe checks server trust. Bundle certificate counts alone do not establish trust."
        )
        (alert "RealmIdentityBootstrapTrustMissing"
          ''
            (${fresh "bootstrap"}) unless ${match} ${metric "realm_bootstrap_bundle_server_trust_valid"}
          ''
          "3m"
          "warning"
          "Restore the pinned TLS trust indicator. A current bootstrap collector timestamp cannot replace the missing trust result."
        )
        (alert "RealmIdentityAgentMetadataInvalid"
          ''
            (${metric "realm_spire_agent_metadata_valid"} == 0)
            and ${match} (${fresh "agents"})
          ''
          "3m"
          "critical"
          "Check the http_fqdn agent for {{ $labels.node }} in Eihort admin metadata, including expiry, ban state, and reattestation permission. Metadata does not establish live chain trust."
        )
        (alert "RealmIdentityAliasInvalid"
          ''
            (${metric "realm_spire_alias_matches_expected"} == 0)
            and ${match} (${fresh "aliases"})
          ''
          "3m"
          "critical"
          "Repair the stable alias for {{ $labels.node }}. Check its parent, exact SPIFFE selector, and expiry in Eihort admin metadata."
        )
        (alert "RealmIdentityAgentMetadataMissing"
          ''
            (realm_identity:expected_agent unless on (instance, node) ${metric "realm_spire_agent_metadata_valid"})
            and on (instance) (${fresh "agents"})
          ''
          "3m"
          "warning"
          "Restore agent metadata for {{ $labels.node }} in the configured Eihort cohort. A current collector timestamp cannot establish health for an absent node."
        )
        (alert "RealmIdentityAliasMetadataMissing"
          ''
            (realm_identity:expected_agent unless on (instance, node) ${metric "realm_spire_alias_matches_expected"})
            and on (instance) (${fresh "aliases"})
          ''
          "3m"
          "warning"
          "Restore alias metadata for {{ $labels.node }} in the configured Eihort cohort. An absent series is not a valid alias."
        )
        (alert "RealmIdentityCertificateNearExpiry"
          ''
            (
              (realm_identity_certificate_not_after_seconds{job="realm-identity",kind="agent"} - time() < 600)
              and ${match} (${fresh "agents"})
            ) or (
              (realm_identity_certificate_not_after_seconds{job="realm-identity",kind="canary"} - time() < 600)
              and ${match} (${fresh "canary"})
            )
          ''
          "2m"
          "critical"
          "Check renewal for {{ $labels.kind }} {{ $labels.identity }}. Fewer than ten minutes remain. Agent times are admin metadata. Canary times describe only this observer."
        )
        (alert "RealmIdentityCertificateMissing"
          ''
            (
              (${metric "realm_spire_agent_metadata_valid"} == 1)
              unless on (instance, job, monitor, node) realm_identity_certificate_not_after_seconds{job="realm-identity",kind="agent"}
            ) and ${match} (${fresh "agents"})
            or (
              (realm_identity_collector_success{job="realm-identity",collector="canary"} == 1)
              unless ${match} realm_identity_certificate_not_after_seconds{job="realm-identity",kind="canary"}
            ) and ${match} (${fresh "canary"})
          ''
          "3m"
          "warning"
          "Restore the certificate expiry series. A successful metadata indicator without an expiry cannot establish renewal health. Agent data comes from admin metadata."
        )
        (alert "RealmIdentityWorkloadCollectorMissing"
          ''
            (
              group without (unit, identity, source) (realm_identity:holder_inventory)
              unless ${match} realm_identity_collector_success{job="realm-identity",collector="workloads"}
              unless ${match} realm_identity_collector_last_collection_timestamp_seconds{job="realm-identity",collector="workloads"}
            ) and ${match} (${up})
              and ${match} ${metric "realm_identity_collector_success"}
          ''
          "3m"
          "warning"
          "Restore the mandatory workloads collector for known holder inventory. Both status and completion metrics are absent. Static expected-collector alerts also cover cold start before any holder inventory has been observed."
        )
        (alert "RealmIdentityWorkloadInventoryMissing"
          ''
            ${metric "realm_identity_collector_success"}
              and on (instance, job, monitor, collector) (${fresh "workloads"})
              unless ${match} realm_identity:holder_inventory
          ''
          "3m"
          "warning"
          "Restore holder inventory on this exporter. A configured workloads collector must emit holder status even before its first attempt."
        )
        (alert "RealmIdentityWorkloadSeriesMissing"
          ''
            (
              (realm_identity:holder_inventory unless ${holderMatch} ${metric "realm_workload_svid_observation_success"})
              or (realm_identity:holder_inventory unless ${holderMatch} ${metric "realm_workload_svid_dormant"})
              or (realm_identity:holder_inventory unless ${holderMatch} ${metric "realm_workload_svid_last_attempt_timestamp_seconds"})
            )
            and ${match} (${fresh "workloads"})
          ''
          "3m"
          "warning"
          "Restore inventory fields for {{ $labels.unit }}. Removed units remain detectable for fifteen minutes after their last attempt sample. ${holderNote}"
        )
        (alert "RealmIdentityWorkloadFailed"
          ''
            (${metric "realm_workload_svid_observation_success"} == 0)
            and ${holderMatch} (${metric "realm_workload_svid_dormant"} == 0)
            and ${holderMatch} realm_identity:holder_fresh
          ''
          "3m"
          "warning"
          "Check unit state and the observation endpoint for {{ $labels.unit }}. A current attempt failed. ${holderNote}"
        )
        (alert "RealmIdentityWorkloadStale"
          ''
            ((${metric "realm_workload_svid_last_attempt_timestamp_seconds"} <= time() - 65)
              or (${metric "realm_workload_svid_last_attempt_timestamp_seconds"} == 0)
              or (${metric "realm_workload_svid_last_attempt_timestamp_seconds"} > time())
              or (
                ((${metric "realm_workload_svid_last_observed_timestamp_seconds"} <= time() - 65)
                  or (${metric "realm_workload_svid_last_observed_timestamp_seconds"} == 0)
                  or (${metric "realm_workload_svid_last_observed_timestamp_seconds"} > time()))
                and ${holderMatch} (${metric "realm_workload_svid_observation_success"} == 1)
              ))
            and ${match} (${fresh "workloads"})
            unless ${holderMatch} (
              (${metric "realm_workload_svid_dormant"} == 1)
              and ${holderMatch} realm_identity:holder_fresh
            )
          ''
          "3m"
          "warning"
          "Check the holder cycle and clock for {{ $labels.unit }}. Zero means no attempt. Allow three minutes for the first cycle. ${holderNote}"
        )
        (alert "RealmIdentityWorkloadCertificateMissing"
          ''
            (${metric "realm_workload_svid_observation_success"} == 1)
            and ${holderMatch} realm_identity:holder_fresh
            unless ${holderMatch} (${metric "realm_workload_svid_dormant"} == 1)
            unless ${holderMatch} (
              ${metric "realm_workload_svid_not_after_seconds"}
              and ${holderMatch} ${metric "realm_workload_svid_last_observed_timestamp_seconds"}
            )
          ''
          "3m"
          "warning"
          "Restore the expiry metric for {{ $labels.unit }}. Observation success without certificate metadata cannot establish renewal health. ${holderNote}"
        )
        (alert "RealmIdentityWorkloadNearExpiry"
          ''
            (${metric "realm_workload_svid_not_after_seconds"} - time() < 600)
            and ${holderMatch} (${metric "realm_workload_svid_observation_success"} == 1)
            and ${holderMatch} realm_identity:holder_fresh
            and ${holderMatch} (${metric "realm_workload_svid_last_observed_timestamp_seconds"} > time() - 65)
            and ${holderMatch} (${metric "realm_workload_svid_last_observed_timestamp_seconds"} <= time())
            unless ${holderMatch} (${metric "realm_workload_svid_dormant"} == 1)
          ''
          "2m"
          "critical"
          "Check renewal for {{ $labels.unit }}. Fewer than ten minutes remain. ${holderNote}"
        )
        (alert "RealmSPIRETelemetryDown" ''up{job=~"spire-agent|spire-server"} == 0'' "3m" "warning"
          "Check the native {{ $labels.job }} telemetry listener and the SPIFFE observation route. This scrape can fail when the gateway lacks its own identity."
        )
        (alert "RealmSPIRETelemetryMissing"
          ''
            realm_identity:expected_native_target unless on (instance, job) up{job=~"spire-agent|spire-server"}
          ''
          "3m"
          "warning"
          "Restore the native {{ $labels.job }} telemetry target for {{ $labels.node }}. Absence is not evidence of health. The gateway-dependent scrape is separate from realm-identity."
        )
        # These counters reset on restart and create outcome series only after
        # events. Do not infer failure from an absent or zero success outcome.
        (alert "RealmAttestationProofFailures"
          ''
            sum without (outcome, stage, reason) (
              increase(realm_http_attestation_total{job="attestation-server",component="server",outcome="failure",stage=~"fetch|verify",reason!~"canceled|deadline|stream_error|session_ended"}[10m])
            ) >= 3
            and ${match} (up{job="attestation-server"} == 1)
          ''
          "2m"
          "warning"
          "Check repeated proof fetch or verification failures for {{ $labels.node }}. Agent success means local proof submission only. Core can cancel normally after the response. Server success means proof verification and attributes sent, not certificate issuance."
        )
        (alert "RealmAttestationCapacityPressure"
          ''
            (
              sum without (node) (realm_http_attestation_pending{job="attestation-server",component="server"})
              / (realm_http_attestation_capacity{job="attestation-server",component="server"} > 0) >= 0.8
            )
            and ${match} (up{job="attestation-server"} == 1)
          ''
          "3m"
          "warning"
          "Check pending server attempts and generation changes. Capacity applies per generation, while pending can span generations. This pressure does not measure certificate issuance."
        )
        (alert "RealmAttestationCapacityRejected"
          ''
            sum without (node, stage, reason) (
              increase(realm_http_attestation_rejections_total{job="attestation-server",component="server",reason=~"capacity|rate_limit"}[10m])
            ) >= 3
            and ${match} (up{job="attestation-server"} == 1)
          ''
          "2m"
          "warning"
          "Check repeated capacity or verified proof quota rejections. Quota counts verified proofs before attributes send. It does not count issued credentials."
        )
        # SPIRE source: pkg/common/telemetry/server/ca_manager.go and
        # pkg/server/ca/manager/manager.go activateX509CA. The default prefix is
        # telemetry.SpireServer (spire_server), with no type prefix in Prometheus.
        # Live Eihort confirms this is an absolute Unix epoch (not a TTL), with
        # trust_domain_id="nyaw_xyz". Do not filter on an unsanitized domain.
        # Use the active CA expiry, not the pinned bootstrap bundle inventory.
        # Native sign/activation counters have no _total suffix; no demand or
        # missing event series must not be interpreted as an issuance failure.
        (alert "RealmSPIREActiveCAMetricsMissing"
          ''
            (up{job="spire-server"} == 1)
            unless ${match} spire_server_manager_x509_ca_rotate_expiration{job="spire-server"}
          ''
          "3m"
          "warning"
          "Restore the native active X.509 CA expiry gauge. A successful scrape without authority telemetry cannot establish CA renewal health. Check SPIRE startup and telemetry filters."
        )
        (alert "RealmSPIREActiveCANearExpiry"
          ''
            (spire_server_manager_x509_ca_rotate_expiration{job="spire-server"} - time() < 600)
            and ${match} (up{job="spire-server"} == 1)
          ''
          "2m"
          "critical"
          "Check active SPIRE X.509 CA rotation. Fewer than ten minutes remain. The native gauge uses the default spire_server prefix and describes the activated CA, not the bootstrap bundle."
        )
      ];
  }
]
