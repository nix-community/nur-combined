self: super: {
  fwupd = super.fwupd.overrideAttrs(o: rec {
    name = "fwupd-${version}";
    version = "1.1.3";

    src = super.fetchFromGitHub {
      owner = "hughsie";
      repo = "fwupd";
      rev = version; # "802a279bd2b53e59f1d1d363c2d106e59b59b6fb";
      sha256 = "03yiag3rp0g7d6m9nb9wqq7myady5gjf6lybhic6sb53xnbn6091";
    };

  });
}
