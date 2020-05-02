import ./generic.nix ({ lib,
... } @ args: self: super: {
  pname = "${super.pname}-unstable";
  version = "2020-05-02";

  src = super.src // {
    rev = "1f6890befa02f8cbf7b8fe4e00b1958c40511ba3";
    sha256 = "1jr2wrblkdpqgbscjqy1vrs0383zwg7820f9qv22zbdzjpncwy0k";
  };

  cargoSha256 = "0qcj39ljd331k45vf2yrqv64pw7cimgdnvwhfzqp93xqild4qdpn";
})
