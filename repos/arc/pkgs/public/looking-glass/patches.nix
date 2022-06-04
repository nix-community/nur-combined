{ fetchpatch }: {
  singlethread = fetchpatch {
    url = "https://github.com/arcnmx/LookingGlass/commit/f654f19606219157afe03ab5c5b965a28d3169ef.patch";
    sha256 = "0g532b0ckvb3rcahsmmlq3fji6zapihqzd2ch0msj0ygjzcgkabw";
  };
  cmake-obs-installdir = ./obs-installdir.patch;
  nvfbc-pointerthread = fetchpatch {
    url = "https://github.com/arcnmx/LookingGlass/commit/cc273ce977b9fcb12079548c91bee45d6d470cba.patch";
    sha256 = "1db2lasjb6h6kp2p28whnf5r88nfr5zckwmwsa81v0chif41pdrr";
  };
  nvfbc-framesize = fetchpatch {
    url = "https://github.com/arcnmx/LookingGlass/commit/0791f3e5f01b64ca75e89700668165065d261306.patch";
    sha256 = "17nb35v8yc8m28lg30smkjyckp5nrig3l1pr70yw4s3i0xn6v1mf";
  };
  nvfbc-scale = fetchpatch {
    url = "https://github.com/arcnmx/LookingGlass/commit/67c51c58f9bde8468a9fd918ab82f8f768bfb17b.patch";
    sha256 = "03s0g959wpih1bndkjhi5wyfn15n6axc364gb5v9szx5xsya8p45";
  };
}
