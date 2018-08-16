{ stdenv, fetchgit, buildGoPackage }:

with import ./src.nix;
buildGoPackage rec {
  name = "slipstream-ipcd-${version}";
  inherit version;
  src = fetchgit srcinfo;

  goPackagePath = "github.com/dtzWill/ipcopter"; # (?)

  doCheck = false; # TODO: Fix path to 'ipcd' binary used in testing...?

  meta = with stdenv.lib; {
    description = "Slipstream daemon";
    homepage = https://wdtz.org/slipstream;
    license = licenses.isc;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
