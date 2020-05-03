import ./generic.nix ({ lib,
... } @ args: self: super: {
  version = "2.2.0";

  src = super.src // {
    sha256 = "0fpc09yvxjcvjkai7afyig4gyc7inaqxxrwzs17mh8wdgzawb6dl";
  };

  cargoSha256 = "0sbhij8qh9n05nzhp47dm46hbc59awar515f9nhd3wvahwz53zam";
})
