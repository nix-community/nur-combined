let
  prefix = "https://sources.debian.org/data/main/n/ns2/2.35+dfsg-3/debian/patches";
in [
  {
    url = "${prefix}/0003-fix-gcc-4.7-ftbfs.patch.patch";
    sha256 = "1h2p3jl58gb1fw1f81r4s9gjsixqn37n6a9d0s4srf0m1xcnk5xx";
  }
  {
    url = "${prefix}/0006-hack-for-tcl8.6.patch";
    sha256 = "06xhk5vl15cgjb827mry1d4zb17br5qjaa4c164rffpyk6klh6bd";
  }
  {
    url = "${prefix}/0007-fix-build-with-gcc6.patch";
    sha256 = "15h3nmzjix118j8ws4bfhzbvr75yamfffdmgvkw94mqf1b970w8p";
  }
]
