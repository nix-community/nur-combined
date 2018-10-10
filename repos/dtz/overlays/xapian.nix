self: super: {
  xapian = super.xapian.overrideAttrs(o: rec {
    name = "xapian-${version}";
    version = "2018-10-09";
    src = super.fetchgit {
      url = "https://github.com/xapian/xapian";
      rev = "4ca08213fcf5eca4d844cb522cad18235c81875c";
      sha256 = "168whd1lf4jm5w601ak805g3jzj54n44sh1cyfs1lba8vm9wfpbx";
      leaveDotGit = true;
    };
    patches = null; # Drop patch from upstream included by using latest

    # drop doc output because generating from git requires too many deps
    outputs = [ "out" /* "man" */ /* "doc" */ ];

    # Drop existing nativeBuildinputs, don't use autoreconfHook
    nativeBuildInputs = with self; [ git perl which automake autoconf libtool tcl bison /* python */ ];

    preConfigure = ''
      patchShebangs bootstrap
      ./bootstrap --download-tools=never xapian-core

      cd xapian-core
    '';

    configureFlags = (o.configureFlags or []) ++ [ "--enable-maintainer-mode" "--disable-documentation" ];

    # It's 2018
    enableParallelBuilding = true;
  });
}
