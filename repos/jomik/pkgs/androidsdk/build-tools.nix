{ lib, pkgs, pkgsi686Linux }:
{ version, sha256 }:

let
  inherit (pkgs) stdenv;
  stdenv_32bit = pkgsi686Linux.stdenv;
  zlib_32bit = pkgsi686Linux.zlib;
  ncurses_32bit = pkgsi686Linux.ncurses5;
in stdenv.mkDerivation rec {
  inherit version;
  name = "android-sdk-build-tools-r${version}";
  src = pkgs.fetchurl {
    inherit sha256;
    url = "https://dl.google.com/android/repository/build-tools_r${version}-linux.zip";
  };
  buildInputs = with pkgs; [ unzip file ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/build-tools/${version}
    mv -t $out/build-tools/${version} ./*

    # Avoid audit-tmpdir reacting to "build" in rpath
    mkdir -p $out/libs/${version}
    ln -s $out/build-tools/${version}/{lib,lib64} $out/libs/${version}
  '';

  preFixup = ''
    prefix=$out/build-tools/${version}
    libdir=$out/libs/${version}

    for f in $(grep -Rl /bin/ls $prefix); do
      sed -i -e "s|/bin/ls|${pkgs.coreutils}/bin/ls|" "$f"
    done

    find $prefix -type f -print0 | while IFS= read -r -d "" file; do
      type=$(file "$file")
      ## Patch 64-bit binaries
      if grep -q "ELF 64-bit" <<< "$type"; then
        if grep -q "interpreter" <<< "$type"; then
          patchelf --set-interpreter ${stdenv.cc.libc.out}/lib/ld-linux-x86-64.so.2 "$file"
        fi
        patchelf --set-rpath $libdir/lib64:${stdenv.cc.cc.lib.out}/lib:${pkgs.zlib.out}/lib:${pkgs.ncurses5.out}/lib "$file"
      ## Patch 32-bit binaries
      elif grep -q "ELF 32-bit" <<< "$type"; then
        if grep -q "interpreter" <<< "$type"; then
          patchelf --set-interpreter ${stdenv_32bit.cc.libc.out}/lib/ld-linux.so.2 "$file"
        fi
        patchelf --set-rpath $libdir/lib:${stdenv_32bit.cc.cc.lib.out}/lib:${zlib_32bit.out}/lib:${ncurses_32bit.out}/lib "$file"
      fi
    done
  '';
}
