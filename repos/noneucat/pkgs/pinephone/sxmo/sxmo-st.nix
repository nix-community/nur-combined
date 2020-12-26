{ stdenv, fetchgit, st, pkgconfig
, conf ? null, patches ? [], extraLibs ? [] }:

(st.overrideAttrs (oldAttrs: rec {
  pname = "sxmo-st";
  version = "0.8.3.3";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-st";
    rev = "${version}";
    sha256 = "1fyxyywgz04yq20l0v59f4mvlhi2nyn079fa9hnh5c9ygb0nn2jj";
  };

  postPatch = oldAttrs.postPatch + ''
  
sed -i "s@PKG_CONFIG = pkg-config@PKG_CONFIG = ${pkgconfig}/bin/pkg-config@g" config.mk
  '';

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-st";
    description = "St terminal emulator for sxmo";
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = oldAttrs.meta.platforms; 
  };
})).override {
  inherit
    conf
    patches
    extraLibs;
}