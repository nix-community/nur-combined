function npmlock2nix_add_node_path() {
	addToSearchPath "NODE_PATH" "$1/node_modules"
}


addEnvHooks "$targetOffset" npmlock2nix_add_node_path
