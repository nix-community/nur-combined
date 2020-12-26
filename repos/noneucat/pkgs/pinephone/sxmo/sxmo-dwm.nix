{ stdenv, dwm, fetchgit, patches ? [], conf ? null }:

(dwm.overrideAttrs (oldAttrs: rec {
  name = "sxmo-dwm-${version}";
  version = "6.2.10";

  src = fetchgit {
    url = "https://git.sr.ht/~mil/sxmo-dwm";
    rev = "${version}";
    sha256 = "15c4x9948pjzp31fd8ji50gzhxd8ak70vm5xx12d0ns6lz423y9s";
  };

  postPatch = oldAttrs.postPatch + ''

sed -i "s@CC = cc@CC = $CC@g" config.mk
  '';

  meta = {
    homepage = "https://git.sr.ht/~mil/sxmo-dwm";
    description = "Dwm for sxmo";
    license = stdenv.lib.licenses.mit;
    maintainers = [ stdenv.lib.maintainers.noneucat ];
    platforms = oldAttrs.meta.platforms; 
  };
})).override {
  inherit conf;
  patches = patches ++ [ ./0001-Keep-track-of-whether-the-multikey-timer-is-set.patch ];
}
