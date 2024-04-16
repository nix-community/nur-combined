{
  lib, pkgs, stdenv, rustPlatform
}:
let
	version = "2.46.1";

	opsAgentSrc = pkgs.fetchFromGitHub {
		owner = "GoogleCloudPlatform";
		repo = "ops-agent";
		rev = "tags/${version}";
		hash = "sha256-yJerH48T7hj03wekodqYI/LMMZBtR9fKT8keK/hATkM=";
	};
in rec {
	ops-agent-go = pkgs.buildGoModule {
		pname = "google-ops-agent";
		inherit version;
		src = opsAgentSrc;
		vendorHash = "sha256-dsDyMNduxQq+mIWLz2WuExwvVLlsBRLoS2snzJIJXus=";
		subPackages = ["cmd/agent_wrapper" "cmd/google_cloud_ops_agent_diagnostics" "cmd/google_cloud_ops_agent_engine"];

		meta = {
			description = "(Packaging WIP) Ops Agent is the primary agent for collecting telemetry from your Compute Engine instances";
			longDescription = "(Packaging WIP) The Ops Agent is the primary agent for collecting telemetry from your Compute Engine instances. Combining the collection of logs, metrics, and traces into a single process, the Ops Agent uses Fluent Bit for logs, which supports high-throughput logging, and the OpenTelemetry Collector for metrics and traces.";
			homepage = "https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/";
			license = lib.licenses.asl20;
			mainProgram = "google_cloud_ops_agent_engine";
			platforms = lib.platforms.linux;
			sourceProvenance = [ lib.sourceTypes.fromSource ];
		};
	};
}
