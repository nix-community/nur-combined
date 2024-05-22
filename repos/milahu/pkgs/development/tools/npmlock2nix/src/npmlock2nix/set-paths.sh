function npmlock2nix_add_path() {
	addToSearchPath "NODE_PATH" "$1/node_modules"
	addToSearchPath "PATH" "$1/node_modules/.bin"
}


addEnvHooks "$targetOffset" npmlock2nix_add_path
