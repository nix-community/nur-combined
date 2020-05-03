import ./generic.nix ({ lib,
... } @ args: self: super: {
  pname = "${super.pname}-unstable";
  version = "2020-05-02";

  src = super.src // {
    rev = "1f6890befa02f8cbf7b8fe4e00b1958c40511ba3";
    sha256 = "1jr2wrblkdpqgbscjqy1vrs0383zwg7820f9qv22zbdzjpncwy0k";
  };

  cargoSha256 = "1g12wqz1ycgfxni4r90ybkvi8c6yxfjpph10g2jkh62r94whxjdw";
})
