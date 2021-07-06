{ fetchpatch }: {
  singlethread = fetchpatch {
    url = "https://github.com/arcnmx/LookingGlass/commit/f654f19606219157afe03ab5c5b965a28d3169ef.patch";
    sha256 = "0g532b0ckvb3rcahsmmlq3fji6zapihqzd2ch0msj0ygjzcgkabw";
  };
  cmake-rc-revert = fetchpatch {
    url = "https://github.com/arcnmx/LookingGlass/commit/b21d4aa622e00913cbf991633eb4ae6a2dd2fe7a.patch";
    sha256 = "0dypvmn7rl0l4pd7vhp548prim1r1y3krxwms2kcyy8dq2p02c3b";
  };
  cmake-rc = fetchpatch {
    url = "https://github.com/arcnmx/LookingGlass/commit/64170aff1f856314a24d9f89b24fc2f822d2ea52.patch";
    sha256 = "066x8pp5mnz9lkp9v46iampx5y58i0yrcb62d91033il8l980hvq";
  };
}
