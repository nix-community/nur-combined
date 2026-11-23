{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  nix,
  nix-update-script,
  python3,
  writeShellApplication,
  zfs,
}:

rustPlatform.buildRustPackage {
  pname = "zfs-dedup";
  version = "0.1.0-unstable-2026-11-22";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "zfs-dedup";
    rev = "346158305149f6fb1f8d6204c80c490529079b0e";
    hash = "sha256-4Gm7qFq11VTMetlxfPnsBEClviq1YmsjuQvheTYoJh0=";
  };

  cargoHash = "sha256-NJMpi1a7eYZw810INf9pcitnZXJdQ7zxaAAGhLyNyOg=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram "$out/bin/zfs-dedup" \
      --suffix PATH : ${lib.makeBinPath [ zfs ]}
  '';

  passthru.updateScript = writeShellApplication {
    name = "update-zfs-dedup";
    runtimeInputs = [
      nix
      python3
    ];
    text = ''
      export UPDATE_NIX_ATTR_PATH="zfs-dedup"
      ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [ "--version=branch" ];
        })
      } "$@"
      # Without release tags, nix-update uses 0 as the base version. Use the
      # newly pinned source's Cargo.toml version instead.
      source_path=$(nix-build . -A zfs-dedup.src --no-out-link)
      python3 - "$source_path" <<'PY'
      import pathlib
      import re
      import sys
      import tomllib

      source = pathlib.Path(sys.argv[1])
      base = tomllib.loads((source / "Cargo.toml").read_text())["package"]["version"]
      package = pathlib.Path("by-name/zf/zfs-dedup/package.nix")
      text = package.read_text()
      text = re.sub(r'(?m)^  version = "0-unstable-', lambda _: f'  version = "{base}-unstable-', text)
      package.write_text(text)
      PY
    '';
  };

  meta = {
    description = "Offline block-level deduplication for ZFS using block cloning";
    homepage = "https://github.com/Mic92/zfs-dedup";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "zfs-dedup";
  };
}
