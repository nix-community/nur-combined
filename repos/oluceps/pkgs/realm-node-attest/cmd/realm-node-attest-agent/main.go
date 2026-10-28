package main

import (
	"github.com/spiffe/spire-plugin-sdk/pluginmain"
	agentv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/agent/nodeattestor/v1"
	configv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/service/common/config/v1"

	"nyaw.xyz/realm-node-attest"
)

func main() {
	plugin := new(nodeattest.AgentPlugin)
	defer plugin.Close()
	pluginmain.Serve(
		agentv1.NodeAttestorPluginServer(plugin),
		configv1.ConfigServiceServer(plugin),
	)
}
