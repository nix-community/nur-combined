append_host_xdg_data_dirs() {
  addToSearchPath "HOST_XDG_DATA_DIRS" "$1/share"
}

# because the hook goes in some drv's nativeBuildInputs, our "target" is that drv's "host"
addEnvHooks "$targetOffset" append_host_xdg_data_dirs
