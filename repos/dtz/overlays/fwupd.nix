self: super: {
  fwupd = super.fwupd.overrideAttrs(o: rec {
    name = "fwupd-${version}";
    version = "2018-10-02";

    src = super.fetchFromGitHub {
      owner = "hughsie";
      repo = "fwupd";
      rev = "55ab100334ad0b441e3b44c1f8cae125f40e7e3d";
      sha256 = "1m6jny9w3bc9b0d8cv0czcaf99ky9g0mv5bxmkcvrkzdx4zqgwbd";
    };
  });
}
