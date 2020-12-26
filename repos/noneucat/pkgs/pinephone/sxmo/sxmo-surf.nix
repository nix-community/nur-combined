{ stdenv, fetchgit, surf, patches ? null }:

(surf.overrideAttrs (oldAttrs: rec {
  pname = "sxmo-surf";
  version = "2.0.3";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-surf";
    rev = "${version}";
    sha256 = "19q0cyp703gjcvj5yivwka94v9j24h1kbj6476m505xg3ircczgr";
  };

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-surf";
    description = "The suckless surf browser fork for sxmo";
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = oldAttrs.meta.platforms; 
  };
})).override {
  inherit patches;
}