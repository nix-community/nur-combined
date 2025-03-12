{ lib, stdenv, fetchurl, glibc, gcc }:

stdenv.mkDerivation rec {
  version = "2019u3";
  name = "intel-compilers-${version}";
  sourceRoot = "/home/scratch/intel/2019";

  propagatedBuildInputs = [ glibc gcc ];

  phases = [ "installPhase" "fixupPhase" "installCheckPhase" "distPhase" ];

  installPhase = ''
     cp -a $sourceRoot $out
     # Fixing links
     for i in $(find $out -type l)
     do
       dest=$(readlink $i)
       if [[ $dest = *$sourceRoot* ]]
       then
         rm $i
         newlink=$(echo "$dest" |sed s",.*$sourceRoot,$out,")
         ln -s $newlink $i
      fi
    done
    # Fixing man path
    #rm -f $out/man
    mkdir -p $out/share
    ln -s ../compilers_and_libraries/linux/man/common $out/share/man
  '';

  postFixup = ''
    echo "Fixing rights..."
    chmod u+w -R $out
    echo "Patching rpath and interpreter..."
    find $out -type f -exec $SHELL -c 'patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) --set-rpath ${glibc}/lib:${gcc.cc}/lib:${gcc.cc.lib}/lib:$out/lib/intel64:$out/compilers_and_libraries_2019.3.0.591499/linux/bin/intel64 2>/dev/null {}' \;
    echo "Fixing path into scripts..."
    for file in `grep -l -r "$sourceRoot" $out`
    do
      sed -e "s,$sourceRoot,$out,g" -i $file
    done 
  '';

  meta = {
    description = "Intel compilers and libraries 2019 update 3";
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}

