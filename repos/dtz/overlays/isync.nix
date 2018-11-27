self: super: {
  isync = super.isync.overrideAttrs (o: rec {
    name = "isync-git-${version}";
    version = "2018-11-27";
    src = super.fetchgit {
      url = https://git.code.sf.net/p/isync/isync;
      rev = "95d18e2778f28b7aac4f92dc6770430ee7c7ca4b";
      sha256 = "1iycmcqslxis9kbc0c1a3i3qy6msvwgy64xgjy0dvzpg3wsbvsg5";
    };

    nativeBuildInputs = with self; [ autoconf automake perl pkgconfig ];
    buildInputs = with self; [ cyrus_sasl db openssl zlib ];

    # Needed when building from git
    preConfigure = ''
      touch ChangeLog
      ./autogen.sh
    '';

  });
}
