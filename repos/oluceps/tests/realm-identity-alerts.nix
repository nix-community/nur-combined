# Pure promtool fixtures; no NixOS/flake evaluation or deployment.
# From the repository root:
# nix-instantiate --eval --strict --json --expr '(import ./tests/realm-identity-alerts.nix {}).rules' > /tmp/realm-identity-alert-rules.json
# nix-instantiate --eval --strict --json --expr '(import ./tests/realm-identity-alerts.nix {}).tests' > /tmp/realm-identity-alert-tests.json
# promtool check rules /tmp/realm-identity-alert-rules.json
# promtool test rules /tmp/realm-identity-alert-tests.json
{
  rulesFile ? "/tmp/realm-identity-alert-rules.json",
}:
let
  inherit (builtins)
    attrNames
    concatLists
    filter
    head
    map
    replaceStrings
    toJSON
    ;
  nodes = [
    "eihort"
    "abhoth"
    "azasos"
    "nodens"
    "yidhra"
    "hastur"
  ];
  groups = import ../lib/realm/identity-alerts.nix { inherit nodes; };
  alerts = filter (r: r ? alert) (concatLists (map (g: g.rules) groups));
  rule = name: head (filter (r: r.alert == name) alerts);
  each = f: concatLists (map f nodes);
  observation = node: {
    instance = node;
    job = "realm-identity";
    monitor = "hastur";
    transport = "wireguard";
  };
  local = node: observation node // { inherit node; };
  native = node: job: {
    instance = node;
    inherit job;
    monitor = "hastur";
  };
  central = node: local "eihort" // { inherit node; };
  expected = node: {
    inherit node;
    instance = node;
    job = "realm-identity";
  };
  expectedAgent = node: expected node // { instance = "eihort"; };
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
  holder =
    node:
    local node
    // {
      unit = "realm-observability.service";
      identity = "spiffe://nyaw.xyz/service/observability";
      source = "caddy_loaded";
    };
  certificate =
    node: kind:
    (if kind == "agent" then central node else local node)
    // {
      inherit kind;
      identity = "spiffe://nyaw.xyz/${if kind == "agent" then "agent" else "observer/identity"}/${node}";
    };
  sample = metric: labels: values: { inherit metric labels values; };
  collector =
    node: name: metric: values:
    sample "realm_identity_collector_${metric}" (local node // { collector = name; }) values;
  holderSample =
    node: metric: values:
    sample "realm_workload_svid_${metric}" (holder node) values;
  # At t=0 the initial timestamp is zero; from t=30s on each cycle is current.
  now = "0+30x20";
  base =
    each (
      node:
      [
        (sample "up" (observation node) "1x20")
        (sample "up" (native node "spire-agent") "1x20")
        (sample "realm_bootstrap_bundle_server_trust_valid" (local node) "1x20")
        (sample "realm_identity_certificate_not_after_seconds" (certificate node "canary") "3600x20")
        (sample "realm_identity_certificate_not_after_seconds" (certificate node "agent") "3600x20")
        (sample "realm_spire_agent_metadata_valid" (central node) "1x20")
        (sample "realm_spire_alias_matches_expected" (central node) "1x20")
        (holderSample node "observation_success" "1x20")
        (holderSample node "dormant" "0x20")
        (holderSample node "last_attempt_timestamp_seconds" now)
        (holderSample node "last_observed_timestamp_seconds" now)
        (holderSample node "not_after_seconds" "3600x20")
      ]
      ++ concatLists (
        map (c: [
          (collector node c "success" "1x20")
          (collector node c "last_collection_timestamp_seconds" now)
        ]) (collectors node)
      )
    )
    ++ [
      (sample "up" (native "eihort" "spire-server") "1x20")
      (sample "spire_server_manager_x509_ca_rotate_expiration" (
        native "eihort" "spire-server"
        // {
          trust_domain_id = "nyaw_xyz";
        }
      ) "3600x20")
    ];
  is = metric: s: s.metric == metric;
  at = node: s: (s.labels.node or s.labels.instance) == node;
  onExporter = node: s: s.labels.instance == node && s.labels.job == "realm-identity";
  isCollector = s: builtins.match "realm_identity_collector_.*" s.metric != null;
  isHolder = s: builtins.match "realm_workload_svid_.*" s.metric != null;
  without = predicate: filter (s: !(predicate s)) base;
  change = predicate: values: map (s: if predicate s then s // { inherit values; } else s) base;
  # Expected annotations are rendered from the actual rule templates, but labels,
  # alert names, counts and firing delays are independently asserted below.
  firing = name: labels: { inherit name labels; };
  render =
    labels: template:
    replaceStrings (map (k: "{{ $labels.${k} }}") (attrNames labels)) (map (k: labels.${k}) (
      attrNames labels
    )) template;
  expectedAlert =
    f:
    let
      r = rule f.name;
      labels = f.labels // r.labels;
    in
    {
      exp_labels = labels;
      exp_annotations = builtins.mapAttrs (_: render labels) r.annotations;
    };
  test = testAt "6m";
  testAt = eval_time: name: series: fires: {
    inherit name;
    interval = "30s";
    input_series = map (s: {
      series = "${s.metric}{${
        builtins.concatStringsSep "," (map (k: "${k}=${toJSON s.labels.${k}}") (attrNames s.labels))
      }}";
      inherit (s) values;
    }) series;
    # Check every alert, not just the expected failures: this catches cascades and
    # silent false positives (especially dormant holders and central node joins).
    alert_rule_test = map (r: {
      inherit eval_time;
      alertname = r.alert;
      exp_alerts = map expectedAlert (filter (f: f.name == r.alert) fires);
    }) alerts;
  };
  collectorAlerts =
    name: node: map (c: firing name (local node // { collector = c; })) (collectors node);
  attestation = native "eihort" "attestation-server" // {
    component = "server";
  };
  attestationUp = sample "up" (native "eihort" "attestation-server") "1x20";
  proofCounter =
    reason:
    sample "realm_http_attestation_total" (
      attestation
      // {
        node = "azasos";
        outcome = "failure";
        stage = "fetch";
        inherit reason;
      }
    ) "0+1x20";
  capacity = [
    (sample "realm_http_attestation_pending" (attestation // { node = "azasos"; }) "15x20")
    (sample "realm_http_attestation_pending" (attestation // { node = "nodens"; }) "15x20")
    (sample "realm_http_attestation_capacity" attestation "32x20")
  ];
in
{
  rules = { inherit groups; };
  tests = {
    rule_files = [ rulesFile ];
    evaluation_interval = "30s";
    tests = [
      (test "healthy six-node cohort" base [ ])
      (testAt "1m30s" "down waits two minutes" (change (
        s: is "up" s && onExporter "nodens" s
      ) "0x20") [ ])
      (testAt "2m" "down fires at two minutes" (change (s: is "up" s && onExporter "nodens" s) "0x20") [
        (firing "RealmIdentityScrapeDown" (observation "nodens"))
      ])
      (testAt "2m30s" "absence waits three minutes" (without (s: is "up" s && onExporter "azasos" s)) [ ])
      (testAt "3m" "absence fires at three minutes" (without (s: is "up" s && onExporter "azasos" s)) [
        (firing "RealmIdentityScrapeMissing" (expected "azasos"))
      ])
      (test "whole mandatory workloads collector missing despite known holder inventory"
        (without (s: onExporter "nodens" s && (s.labels.collector or "") == "workloads"))
        [
          (firing "RealmIdentityCollectorSeriesMissing" (expected "nodens" // { collector = "workloads"; }))
          (firing "RealmIdentityWorkloadCollectorMissing" (local "nodens"))
        ]
      )
      (test "cold start all six mandatory workloads collectors and all holder metrics absent"
        (without (s: isHolder s || (s.labels.collector or "") == "workloads"))
        (
          map (
            n: firing "RealmIdentityCollectorSeriesMissing" (expected n // { collector = "workloads"; })
          ) nodes
        )
      )
      (test "central collectors stale suppress cached invalid agent and alias results"
        (map (
          s:
          if
            s.labels.instance == "eihort"
            && builtins.elem (s.labels.collector or "") [
              "agents"
              "aliases"
            ]
            && is "realm_identity_collector_last_collection_timestamp_seconds" s
          then
            s // { values = "30x20"; }
          else if is "realm_spire_agent_metadata_valid" s || is "realm_spire_alias_matches_expected" s then
            s // { values = "0x20"; }
          else
            s
        ) base)
        [
          (firing "RealmIdentityCollectorStale" (local "eihort" // { collector = "agents"; }))
          (firing "RealmIdentityCollectorStale" (local "eihort" // { collector = "aliases"; }))
        ]
      )
      (test "ghostunnel watch failure preserves source not business loaded claim"
        (map (
          s:
          if at "nodens" s && isHolder s then
            s
            // {
              labels = s.labels // {
                source = "ghostunnel_status_watch";
              };
              values = if is "realm_workload_svid_observation_success" s then "0x20" else s.values;
            }
          else
            s
        ) base)
        [
          (firing "RealmIdentityWorkloadFailed" (holder "nodens" // { source = "ghostunnel_status_watch"; }))
        ]
      )
      (test "envoy loaded metadata near expiry preserves source"
        (map (
          s:
          if at "nodens" s && isHolder s then
            s
            // {
              labels = s.labels // {
                source = "envoy_loaded";
              };
              values = if is "realm_workload_svid_not_after_seconds" s then "500x20" else s.values;
            }
          else
            s
        ) base)
        [ (firing "RealmIdentityWorkloadNearExpiry" (holder "nodens" // { source = "envoy_loaded"; })) ]
      )
      (test "one missing independent target cannot be hidden by gateway duplicate" (
        (without (s: is "up" s && onExporter "azasos" s))
        ++ [
          (sample "up" (native "azasos" "identity-spiffe") "1x20")
        ]
      ) [ (firing "RealmIdentityScrapeMissing" (expected "azasos")) ])
      (test "all targets absent" [ ] (
        map (n: firing "RealmIdentityScrapeMissing" (expected n)) nodes
        ++ map (
          n:
          firing "RealmSPIRETelemetryMissing" {
            node = n;
            instance = n;
            job = "spire-agent";
          }
        ) nodes
        ++ [
          (firing "RealmSPIRETelemetryMissing" {
            node = "eihort";
            instance = "eihort";
            job = "spire-server";
          })
        ]
      ))
      (test "scrape down gates collector and holder alerts" (map (
        s:
        if onExporter "nodens" s then
          s
          // {
            values = if s.metric == "up" || isCollector s || isHolder s then "0x20" else s.values;
          }
        else
          s
      ) base) [ (firing "RealmIdentityScrapeDown" (observation "nodens")) ])
      (test "all collector metrics absent is not healthy" (without (
        s: onExporter "nodens" s && isCollector s
      )) [ (firing "RealmIdentityCollectorMetricsMissing" (observation "nodens")) ])
      (test "one entire collector absent"
        (without (s: onExporter "nodens" s && (s.labels.collector or "") == "canary"))
        [ (firing "RealmIdentityCollectorSeriesMissing" (expected "nodens" // { collector = "canary"; })) ]
      )
      (test "no collector completion freshness" (without (
        s: onExporter "nodens" s && is "realm_identity_collector_last_collection_timestamp_seconds" s
      )) (collectorAlerts "RealmIdentityCollectorSeriesMissing" "nodens"))
      (test "mandatory workloads collector status absent but timestamp present"
        (without (
          s:
          onExporter "nodens" s
          && is "realm_identity_collector_success" s
          && (s.labels.collector or "") == "workloads"
        ))
        [
          (firing "RealmIdentityCollectorSeriesMissing" (expected "nodens" // { collector = "workloads"; }))
          (firing "RealmIdentityCollectorSeriesMissing" (local "nodens" // { collector = "workloads"; }))
        ]
      )
      (test "stale collection cannot sustain success" (change (
        s: onExporter "nodens" s && is "realm_identity_collector_last_collection_timestamp_seconds" s
      ) "30x20") (collectorAlerts "RealmIdentityCollectorStale" "nodens"))
      (test "zero completion is no cycle" (change (
        s: onExporter "nodens" s && is "realm_identity_collector_last_collection_timestamp_seconds" s
      ) "0x20") (collectorAlerts "RealmIdentityCollectorStale" "nodens"))
      (test "future completion is not fresh" (change (
        s: onExporter "nodens" s && is "realm_identity_collector_last_collection_timestamp_seconds" s
      ) "10000x20") (collectorAlerts "RealmIdentityCollectorStale" "nodens"))
      (test "current collector failed" (change (
        s:
        onExporter "nodens" s
        && is "realm_identity_collector_success" s
        && (s.labels.collector or "") == "canary"
      ) "0x20") [ (firing "RealmIdentityCollectorFailed" (local "nodens" // { collector = "canary"; })) ])
      (test "partial central agent absence is per node not per instance" (without (
        s: is "realm_spire_agent_metadata_valid" s && at "azasos" s
      )) [ (firing "RealmIdentityAgentMetadataMissing" (expectedAgent "azasos")) ])
      (test "partial central alias absence is per node not per instance" (without (
        s: is "realm_spire_alias_matches_expected" s && at "azasos" s
      )) [ (firing "RealmIdentityAliasMetadataMissing" (expectedAgent "azasos")) ])
      (test "all central agent indicators absent" (without (is "realm_spire_agent_metadata_valid")) (
        map (n: firing "RealmIdentityAgentMetadataMissing" (expectedAgent n)) nodes
      ))
      (test "all central alias indicators absent" (without (is "realm_spire_alias_matches_expected")) (
        map (n: firing "RealmIdentityAliasMetadataMissing" (expectedAgent n)) nodes
      ))
      (test "central invalid remote agent and alias retain node azasos instance eihort"
        (change (
          s:
          at "azasos" s
          && (is "realm_spire_agent_metadata_valid" s || is "realm_spire_alias_matches_expected" s)
        ) "0x20")
        [
          (firing "RealmIdentityAgentMetadataInvalid" (central "azasos"))
          (firing "RealmIdentityAliasInvalid" (central "azasos"))
        ]
      )
      (test "missing central agent expiry" (without (
        s:
        is "realm_identity_certificate_not_after_seconds" s
        && at "azasos" s
        && (s.labels.kind or "") == "agent"
      )) [ (firing "RealmIdentityCertificateMissing" (central "azasos")) ])
      (test "missing canary expiry" (without (
        s:
        is "realm_identity_certificate_not_after_seconds" s
        && at "nodens" s
        && (s.labels.kind or "") == "canary"
      )) [ (firing "RealmIdentityCertificateMissing" (local "nodens" // { collector = "canary"; })) ])
      (test "central agent near expiry uses node not instance" (change (
        s:
        is "realm_identity_certificate_not_after_seconds" s
        && at "azasos" s
        && (s.labels.kind or "") == "agent"
      ) "500x20") [ (firing "RealmIdentityCertificateNearExpiry" (certificate "azasos" "agent")) ])
      (test "bootstrap trust invalid" (change (
        s: is "realm_bootstrap_bundle_server_trust_valid" s && at "nodens" s
      ) "0x20") [ (firing "RealmIdentityBootstrapTrustInvalid" (local "nodens")) ])
      (test "bootstrap trust indicator absent"
        (without (s: is "realm_bootstrap_bundle_server_trust_valid" s && at "nodens" s))
        [ (firing "RealmIdentityBootstrapTrustMissing" (local "nodens" // { collector = "bootstrap"; })) ]
      )
      (test "inactive dormant holder is not a failure" (map (
        s:
        if at "nodens" s && isHolder s then
          s
          // {
            values =
              if is "realm_workload_svid_dormant" s then
                "1x20"
              else if
                is "realm_workload_svid_observation_success" s
                || is "realm_workload_svid_last_observed_timestamp_seconds" s
              then
                "0x20"
              else
                s.values;
          }
        else
          s
      ) (without (s: at "nodens" s && is "realm_workload_svid_not_after_seconds" s))) [ ])
      (test "failed holder is not dormant"
        (map (
          s:
          if
            at "nodens" s
            && (
              is "realm_workload_svid_observation_success" s
              || (is "realm_identity_collector_success" s && (s.labels.collector or "") == "workloads")
            )
          then
            s // { values = "0x20"; }
          else
            s
        ) (without (s: at "nodens" s && is "realm_workload_svid_not_after_seconds" s)))
        [
          (firing "RealmIdentityCollectorFailed" (local "nodens" // { collector = "workloads"; }))
          (firing "RealmIdentityWorkloadFailed" (holder "nodens"))
        ]
      )
      (test "no holder inventory is not healthy" (without (s: at "nodens" s && isHolder s)) [
        (firing "RealmIdentityWorkloadInventoryMissing" (local "nodens" // { collector = "workloads"; }))
      ])
      (test "partial holder attempt series absent" (without (
        s: at "nodens" s && is "realm_workload_svid_last_attempt_timestamp_seconds" s
      )) [ (firing "RealmIdentityWorkloadSeriesMissing" (holder "nodens")) ])
      (test "dormancy cannot hide missing holder status" (map
        (s: if at "nodens" s && is "realm_workload_svid_dormant" s then s // { values = "1x20"; } else s)
        (without (s: at "nodens" s && is "realm_workload_svid_observation_success" s))
      ) [ (firing "RealmIdentityWorkloadSeriesMissing" (holder "nodens")) ])
      (test "stale attempt cannot establish holder health" (change (
        s: at "nodens" s && is "realm_workload_svid_last_attempt_timestamp_seconds" s
      ) "30x20") [ (firing "RealmIdentityWorkloadStale" (holder "nodens")) ])
      (test "stale dormant cache cannot establish holder health" (map (
        s:
        if at "nodens" s && isHolder s then
          s
          // {
            values =
              if is "realm_workload_svid_dormant" s then
                "1x20"
              else if is "realm_workload_svid_observation_success" s then
                "0x20"
              else if is "realm_workload_svid_last_attempt_timestamp_seconds" s then
                "30x20"
              else
                s.values;
          }
        else
          s
      ) base) [ (firing "RealmIdentityWorkloadStale" (holder "nodens")) ])
      (test "stale observed time despite fresh attempt" (change (
        s: at "nodens" s && is "realm_workload_svid_last_observed_timestamp_seconds" s
      ) "30x20") [ (firing "RealmIdentityWorkloadStale" (holder "nodens")) ])
      (test "success with missing expiry" (without (
        s: at "nodens" s && is "realm_workload_svid_not_after_seconds" s
      )) [ (firing "RealmIdentityWorkloadCertificateMissing" (holder "nodens")) ])
      (test "success with missing last observation" (without (
        s: at "nodens" s && is "realm_workload_svid_last_observed_timestamp_seconds" s
      )) [ (firing "RealmIdentityWorkloadCertificateMissing" (holder "nodens")) ])
      (test "holder near expiry" (change (
        s: at "nodens" s && is "realm_workload_svid_not_after_seconds" s
      ) "500x20") [ (firing "RealmIdentityWorkloadNearExpiry" (holder "nodens")) ])
      (test "removed holder retained by fifteen minute inventory" (map (
        s: if at "nodens" s && isHolder s then s // { values = "30x2 stale _x18"; } else s
      ) base) [ (firing "RealmIdentityWorkloadSeriesMissing" (holder "nodens")) ])
      (test "native agent telemetry down is explicit" (change (
        s: is "up" s && s.labels == native "nodens" "spire-agent"
      ) "0x20") [ (firing "RealmSPIRETelemetryDown" (native "nodens" "spire-agent")) ])
      (test "one native target absent is explicit"
        (without (s: is "up" s && s.labels == native "azasos" "spire-agent"))
        [
          (firing "RealmSPIRETelemetryMissing" {
            node = "azasos";
            instance = "azasos";
            job = "spire-agent";
          })
        ]
      )
      (test "native active CA gauge missing is not healthy" (without (
        is "spire_server_manager_x509_ca_rotate_expiration"
      )) [ (firing "RealmSPIREActiveCAMetricsMissing" (native "eihort" "spire-server")) ])
      (test "live native CA absolute epoch with no issuance or attempt events"
        (change (is "spire_server_manager_x509_ca_rotate_expiration") "1793233209x20")
        [ ]
      )
      (test "native activated CA near expiry"
        (change (is "spire_server_manager_x509_ca_rotate_expiration") "500x20")
        [
          (firing "RealmSPIREActiveCANearExpiry" (
            native "eihort" "spire-server"
            // {
              trust_domain_id = "nyaw_xyz";
            }
          ))
        ]
      )
      (test "server proof fetch failures are per node" (
        base
        ++ [
          attestationUp
          (proofCounter "endpoint_failed")
        ]
      ) [ (firing "RealmAttestationProofFailures" (attestation // { node = "azasos"; })) ])
      (test "normal cancellations and agent submission absence do not imply failed issuance" (
        base
        ++ [
          attestationUp
          (proofCounter "canceled")
          (sample "realm_http_attestation_last_success_timestamp_seconds" (
            native "azasos" "attestation-agent"
            // {
              component = "agent";
              node = "azasos";
            }
          ) "0x20")
        ]
      ) [ ])
      (test "server capacity sums nodes but not scrape instances" (
        base ++ [ attestationUp ] ++ capacity
      ) [ (firing "RealmAttestationCapacityPressure" attestation) ])
      (test "verified proof quota rejection is not issued credentials" (
        base
        ++ [
          attestationUp
          (sample "realm_http_attestation_rejections_total" (
            attestation
            // {
              node = "azasos";
              stage = "quota";
              reason = "rate_limit";
            }
          ) "0+1x20")
        ]
      ) [ (firing "RealmAttestationCapacityRejected" attestation) ])
      (test "server scrape down gates attestation signals" (
        base
        ++ [
          (attestationUp // { values = "0x20"; })
          (proofCounter "endpoint_failed")
        ]
        ++ capacity
      ) [ ])
    ];
  };
}
