{ stdenv
, fetchurl
, glibc
, musl
, zlib
}:
let
  libc =
    if stdenv.targetPlatform.isMusl
    then musl
    else glibc;
  binSha256 =
    if stdenv.targetPlatform.isMusl
    then "1rp5vi0wsv3f39zc4gqpcmc3cjk9s2mjc43966xvnm9mzxiiyb62"
    else "0g3lf2dzjr318mfk1qczdqjbcwm7a2a1778w2aay5gfvv99p0rkb";
in
stdenv.mkDerivation rec {
  pname = "elba";
  version = "0.3.2";

  src = fetchurl {
    url = "https://github.com/elba/elba/releases/download/${version}/elba-${version}-${stdenv.targetPlatform.config}.tar.gz";
    sha256 = binSha256;
  };

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -dm755 "$out/bin"
    install -m755 elba "$_"
  '';

  preFixup =
    let
      libPath = stdenv.lib.makeLibraryPath [
        libc
        zlib
      ];
    in ''
      patchelf \
        --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        --set-rpath "${libPath}" \
        $out/bin/elba
    '';

  meta = with stdenv.lib; {
    description = "A package manager for Idris";
    homepage = http://elba.pub;
    license = licenses.mit;
    maintainers = with maintainers; [ yurrriq ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
