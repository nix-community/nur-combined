self: super: {
  valgrind = super.valgrind.overrideAttrs(o: rec {
    name = "valgrind-3.14.0.RC2";
    src = super.fetchgit {
      url = "git://sourceware.org/git/valgrind.git";
      rev = "d2af42d826d65f3a6722a33309e721264846efd3"; # not tagged, idk
      sha256 = "1zajcbnv1f3j2brxhmcjhml15nr3n956ws96467c49j8hnn2jzc0";
    };

    nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ self.autoreconfHook ];

    outputs = [ "out" "dev" /* "man" "doc" */ ]; # idk why
  });
}
