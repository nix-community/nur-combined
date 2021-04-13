{ }:

# TODO: RevBayes.
stdenv.mkDerivation {

  # # From the shell.nix file.

  # name = "revbayes";
  # nativeBuildInputs = [ boost cmake meson ninja pkg-config zlib ];

  # # Temporary hack. Meson is no longer able to pick up Boost automatically.
  # # https://github.com/NixOS/nixpkgs/issues/86131
  # BOOST_INCLUDEDIR = "${lib.getDev boost}/include";
  # BOOST_LIBRARYDIR = "${lib.getLib boost}/lib";

  meta = {
    broken = true;
  };
}
