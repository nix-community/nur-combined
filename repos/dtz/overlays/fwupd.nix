self: super: {
  fwupd = super.fwupd.overrideAttrs(o: rec {
    name = "fwupd-${version}";
    version = "2018-10-11";

    src = super.fetchFromGitHub {
      owner = "hughsie";
      repo = "fwupd";
      rev = "6754f5aa70bb470364ec6c774257ac6cacd0dbb8";
      sha256 = "0kia1nj6mdqy3qcqf5bqv2cnwxp76l4ah6d948ivd7sm6c5zp5an";
    };

  });
}
