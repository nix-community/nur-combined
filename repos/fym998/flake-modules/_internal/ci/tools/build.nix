{ writeShellScriptBin, nix-fast-build }:
writeShellScriptBin "build" ''
  args=(
    --flake ".#ciPackages.$(nix eval --raw --impure --expr builtins.currentSystem)"
    --no-nom
    --skip-cached
  )

  # 只有当 CACHIX_AUTH_TOKEN 存在且非空时，才添加 --cachix-cache 参数
  if [ -n "''${CACHIX_AUTH_TOKEN:-}" ]; then
    args+=(--cachix-cache "''${CACHIX_CACHE}")
  fi

  ${nix-fast-build}/bin/nix-fast-build "''${args[@]}"
''
