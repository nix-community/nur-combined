package main

import (
	"github.com/spiffe/spire-plugin-sdk/pluginmain"
	serverv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/plugin/server/nodeattestor/v1"
	configv1 "github.com/spiffe/spire-plugin-sdk/proto/spire/service/common/config/v1"

	"nyaw.xyz/realm-node-attest"
)

func main() {
	plugin := new(nodeattest.ServerPlugin)
	defer plugin.Close()
	pluginmain.Serve(
		serverv1.NodeAttestorPluginServer(plugin),
		configv1.ConfigServiceServer(plugin),
	)
}
