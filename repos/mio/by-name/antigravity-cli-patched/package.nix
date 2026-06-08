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
    import sys
    path = "'$out'/bin/agy"
    with open(path, "rb") as f:
        data = bytearray(f.read())

    # Patch: replace problematic jump instruction with NOPs
    # Pattern: 0f 84 fa 05 00 00 (je ...), followed by a mov instruction
    # Using hex pattern is safer than pwntools for static binary patches of this type.
    pattern = b"\x0f\x84\xfa\x05\x00\x00\x4c\x89\x94\x24\xe0\xb8\x00\x00"
    new = b"\x90\x90\x90\x90\x90\x90\x4c\x89\x94\x24\xe0\xb8\x00\x00"

    c = data.count(pattern)
    if c != 1:
        print(f"Error: Unique pattern found {c} times, expected 1", file=sys.stderr)
        sys.exit(1)

    data = data.replace(pattern, new, 1)

    with open(path, "wb") as f:
        f.write(data)
    '
  '';
})
