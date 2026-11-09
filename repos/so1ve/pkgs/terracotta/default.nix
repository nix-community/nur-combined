{
  pkg-config,
  terracotta,
  zstd,
}:

terracotta.overrideAttrs (old: {
  # zstd-sys links to the system library through pkg-config.
  nativeBuildInputs = old.nativeBuildInputs ++ [ pkg-config ];
  buildInputs = (old.buildInputs or [ ]) ++ [ zstd ];
})
