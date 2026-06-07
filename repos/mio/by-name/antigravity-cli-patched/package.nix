{
  antigravity-cli,
  python3,
}:

antigravity-cli.overrideAttrs (oldAttrs: {
  pname = "antigravity-cli-patched";

  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [
    (python3.withPackages (ps: [ ps.pwntools ]))
  ];

  postInstall = (oldAttrs.postInstall or "") + ''
    python3 -c '
    from pwn import ELF, context
    import sys

    # Set architecture context for pwntools
    context.arch = "amd64"

    path = "'$out'/bin/agy"
    elf = ELF(path, checksec=False)

    def patch(name, pattern, new):
        matches = list(elf.search(pattern))
        if len(matches) != 1:
            print(f"Error: {name} found {len(matches)} times, expected 1", file=sys.stderr)
            sys.exit(1)
        elf.write(matches[0], new)
        print(f"Successfully patched {name} at {hex(matches[0])}")

    # Patch 1: "\n  %s\n\n" -> "\n%s\n\n\n\n"
    patch("Pattern 1", b"\x0a  %s\x0a\x0a", b"\x0a%s\x0a\x0a\x0a\x0a")

    # Patch 2: "  %s  " -> "%s    "
    patch("Pattern 2", b"  %s  ", b"%s    ")

    elf.save(path)
    '
  '';

})
