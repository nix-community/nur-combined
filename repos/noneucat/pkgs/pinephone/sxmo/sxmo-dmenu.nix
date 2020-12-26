{ stdenv, fetchgit, dmenu, patches ? null }:

(dmenu.overrideAttrs (oldAttrs: rec {
  name = "sxmo-dmenu-${version}";
  version = "4.9.7";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-dmenu";
    rev = "${version}";
    sha256 = "0yj3g1179xhw9kgp91xyc0451mdhp8w9fkxw9racvpwqkn47ai6c";
  };

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-dmenu";
    description = "Dmenu for sxmo";
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = oldAttrs.meta.platforms; 
  };
})).override {
  inherit patches;
}

