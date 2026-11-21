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
  version = "0.1.0-unstable-2026-11-01";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "zfs-dedup";
    rev = "1a82ddee296d7b3d7e2eed4994334bf2caae1823";
    hash = "sha256-B4gC7f1GllpMztU2KzsVKgyOYTVTuA/RFR6ZCPvgy7s=";
  };

  cargoHash = "sha256-Ag6KumRtbQBFFeyDDtEGQtEJ9Fs8rJLa+tkq2LT/7gE=";

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
