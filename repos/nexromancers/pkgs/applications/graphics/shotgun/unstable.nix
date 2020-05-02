import ./generic.nix ({ lib,
... } @ args: self: super: {
  pname = "${super.pname}-unstable";
  version = "2020-04-24";

  src = super.src // {
    rev = "c5021a7a929942af84c009f058ff8d4a3f9b67b5";
    sha256 = "0rs53lv9bvx9bx7kq319bk90zy4vh3m5adrjdnryj0y79n9fp3nw";
  };

  cargoSha256 = "1rlwwn3dl0mbw25yifj7v62j06z6k2dxyzsrv8npdkqhsqs99gkw";
})
