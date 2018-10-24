self: super: {
  strace = super.strace.overrideAttrs (o: rec {
    name = "strace-${version}";
    version = "2018-10-24";

    src = super.fetchgit {
      url = https://github.com/strace/strace;
      rev = "43700247534bee217cdf1ec553558c4dcf158335";
      sha256 = "13ajfrf8rhs1fqk9pb72rbh76sfplpzpjzy5ny44nj92aa50nh75";
      leaveDotGit = true;
    };

    nativeBuildInputs = (o.nativeBuildInputs or [])
    ++ (with self; [
      git
      autoconf automake libtool
    ]);

    preConfigure = "./bootstrap";
  });
}
