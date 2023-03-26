{nvfetcher}:
nvfetcher.overrideAttrs (old: {
  patches = [./deterministic.patch];
})
