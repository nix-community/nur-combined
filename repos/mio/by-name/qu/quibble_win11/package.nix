{
  lib,
  quibble,
  fetchgit,
  curl,
  git,
  nix,
  python3,
  writeShellApplication,
}:

# Windows 11 support lives on openzfsonwindows' `win11` branch, which is still
# open as PR #144 against maharmstone/quibble, and zfs-efi's README says Windows
# 11 needs exactly those loader changes.  That is why this is its own package
# instead of a replacement for `quibble`: the loader source differs, everything
# else (cross toolchain patch, freestanding stubs archive, CMake flags) is
# inherited.
let
  version = "20230328-unstable-2026-11-04";
  rev = "c830ce7c5cea88c174f95a9d9758d68cbd570873";
  src = fetchgit {
    url = "https://github.com/openzfsonwindows/quibble";
    inherit rev;
    fetchSubmodules = true;
    hash = "sha256-bPlbdvM3CQgBqsScTJhTOm1FG2e86TwihVDMw3hQKQA=";
  };
in
quibble.overrideAttrs (old: {
  pname = "quibble_win11";
  inherit version src;

  # The inherited installPhase interpolates the *base* package's source path for
  # README.md, LICENCE and font.ttf, which would ship the wrong tree's files, so
  # it is repeated here against this one.
  installPhase = ''
    runHook preInstall

    install -Dm644 quibble.efi $out/share/quibble/quibble.efi
    install -Dm644 btrfs/btrfs.efi $out/share/quibble/drivers/btrfs.efi
    install -Dm644 ntfs/ntfs.efi $out/share/quibble/drivers/ntfs.efi
    install -Dm644 "$src/README.md" $out/share/quibble/README.md
    install -Dm644 "$src/LICENCE" $out/share/quibble/LICENCE
    install -Dm644 "$src/font.ttf" $out/share/quibble/font.ttf

    runHook postInstall
  '';

  # The tracked branch is not the repository default, and nix-update has no way
  # to pin anything but the default (there is no --rev), so this reads the win11
  # head itself and rewrites all three coupled pins: rev, the tree hash of that
  # rev, and the commit date in the version.
  passthru = (old.passthru or { }) // {
    updateScript = writeShellApplication {
      name = "update-quibble_win11";
      runtimeInputs = [
        curl
        git
        nix
        python3
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="quibble_win11"
        package=by-name/qu/quibble_win11/package.nix
        repo=https://github.com/openzfsonwindows/quibble

        rev=$(git ls-remote "$repo" refs/heads/win11 | cut -f1)
        if [ -z "''${rev:-}" ]; then
          echo "could not read the win11 branch head" >&2
          exit 1
        fi

        # Pin the revision with a placeholder hash; the failing fetch is what
        # reports the hash of that tree.
        python3 - "$package" "$rev" <<'PY'
        import pathlib
        import re
        import sys

        package, rev = pathlib.Path(sys.argv[1]), sys.argv[2]
        text = package.read_text()
        text = re.sub(r'(?m)^  rev = "[0-9a-f]+";', f'  rev = "{rev}";', text)
        text = re.sub(r'(?m)^    hash = "sha256-[^"]+";', "    hash = lib.fakeHash;", text)
        package.write_text(text)
        PY

        # The fetch is expected to fail, which is why the pipeline cannot be
        # allowed to trip errexit before the hash is read out of its error.
        hash=$(nix build --no-link .#quibble_win11.src 2>&1 \
          | sed -n 's/.*got: *\(sha256-[A-Za-z0-9+/=]*\)/\1/p' \
          | head -1 || true)
        if [ -z "$hash" ]; then
          echo "could not read the source hash" >&2
          exit 1
        fi

        python3 - "$package" "$hash" <<'PY'
        import pathlib
        import re
        import sys

        package, hash_ = pathlib.Path(sys.argv[1]), sys.argv[2]
        text = package.read_text()
        text = re.sub(r'(?m)^    hash = lib\.fakeHash;', f'    hash = "{hash_}";', text)
        package.write_text(text)
        PY

        # Quibble has no release tags: the CMake project version is the stable
        # prefix and the commit date keeps the version ordering meaningful.
        source=$(nix build --no-link --print-out-paths .#quibble_win11.src)
        base=$(sed -n 's/^project(quibble VERSION \([0-9.]*\)).*/\1/p' "$source/CMakeLists.txt")
        date=$(curl -fsSL "https://api.github.com/repos/openzfsonwindows/quibble/commits/$rev" 2>/dev/null \
          | python3 -c 'import json,sys; print(json.load(sys.stdin)["commit"]["committer"]["date"][:10])' 2>/dev/null || true)
        if [ -z "$base" ] || [ -z "$date" ]; then
          echo "version left unchanged: CMake version '$base', commit date '$date'" >&2
          exit 0
        fi

        python3 - "$package" "$base" "$date" <<'PY'
        import pathlib
        import re
        import sys

        package, base, date = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
        text = package.read_text()
        text = re.sub(
            r'(?m)^  version = "[^"]*";',
            f'  version = "{base}-unstable-{date}";',
            text,
        )
        package.write_text(text)
        PY

        if command -v nixfmt > /dev/null; then
          nixfmt "$package"
        fi
      '';
    };
  };

  meta = (old.meta or { }) // {
    description = "Open-source UEFI bootloader for Windows, win11 branch";
    longDescription = ''
      The openzfsonwindows `win11` branch of Quibble (PR #144): the loader
      changes Windows 11 needs on top of the revision `quibble` packages.
      `zfs-efi` requires them for Windows 11, which is why this variant exists
      next to `quibble` and `quibble_patched`.  It ships no ZFS driver: Windows
      11 booted from a ZFS pool needs `quibble_win11_patched`, which adds that
      driver and `quibble_patched`'s real runtime to this branch.

      Install layout is the same as `quibble`: `quibble.efi`, `freeldr.ini` and
      `font.ttf` in the directory the image is loaded from, with `drivers/`
      next to them.
    '';
    homepage = "https://github.com/openzfsonwindows/quibble";
  };
})
