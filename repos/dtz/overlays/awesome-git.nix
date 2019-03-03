self: super: {
  # XXX: This assumes base 'awesome' is 4.3(+?), which it is on master
  awesome = super.awesome.overrideAttrs (o: rec {
    pname = "awesome";
    name = "${pname}-${version}"; # override
    version = "2019-02-27";
    src = super.fetchFromGitHub {
      owner = "AwesomeWM";
      repo = "awesome";
      rev = "e4e7abda5fb3b155cde8867b1c063ad4e8eb0d8b";
      sha256 = "178vxb3b6zpzxcff9w2h8bffidi9rly9sjhbl377q308mag3i7xr";
    };

    patches = [
      (super.fetchpatch {
        name = "PR2715.patch";
        url = "https://github.com/awesomeWM/awesome/compare/f5c329237ca19fbe92f96c7d49458e67e03c91cb~4..f5c329237ca19fbe92f96c7d49458e67e03c91cb.patch";
        sha256 = "1ibgk1yd03c0c8x8kjvgffa38iczvk61zdia2a2gxdxb10vvc7bs";
      })
    ];
  });
}
