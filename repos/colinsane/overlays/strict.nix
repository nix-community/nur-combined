final: prev:
with final;
{
  # XXX(2026-01-16): shishi needs gcrypt.m4, which comes from libgcrypt.dev.
  # placing libgcrypt.dev in nativeBuildInputs seems to be OK,
  # but the long-term fix is probably to get the autoconf hooks reading .m4 files out of buildInputs
  # (same as pkgConfig hook does with .pc files)
  shishi = prev.shishi.overrideAttrs (upstream: {
    nativeBuildInputs = upstream.nativeBuildInputs ++ [
      libgcrypt.dev
    ];
  });
}

