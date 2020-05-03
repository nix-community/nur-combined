import ./generic.nix ({ lib,
... } @ args: self: super: {
  pname = "${super.pname}-unstable";
  version = "2020-04-24";

  src = super.src // {
    rev = "c5021a7a929942af84c009f058ff8d4a3f9b67b5";
    sha256 = "0rs53lv9bvx9bx7kq319bk90zy4vh3m5adrjdnryj0y79n9fp3nw";
  };

  cargoSha256 = "1dnbjh06j03mh67asmpgqln70j9m02hcdlc2xc6i7h6027064irp";
})
