{ pkgs }:
{
	readsb = pkgs.callPackage ./readsb/package.nix {};
	crisp-status-local = pkgs.callPackage ./crisp-status-local/package.nix {};
	google-ops-agent = (pkgs.callPackage ./google-ops-agent/package.nix {}).ops-agent-go;

	modules = import ./modules.nix;
}
