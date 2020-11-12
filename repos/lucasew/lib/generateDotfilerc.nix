globalConfig: with globalConfig; ''
  export DOTFILES=${dotfileRootPath}
  export NIXPKGS_ALLOW_UNFREE=1
  export NIXOS_CONFIG=${dotfileRootPath}/nodes/${machine_name}
  NIX_PATH=nixpkgs=${repos.nixpkgs}:nixos-config=$NIXOS_CONFIG:dotfiles=${dotfileRootPath}:nixpkgs-overlays=${dotfileRootPath}/lib/overlays

  alias nixos-rebuild="sudo -E nixos-rebuild"
  alias nixos-install="sudo -E nixos-install --system $NIXOS_CONFIG"
''
