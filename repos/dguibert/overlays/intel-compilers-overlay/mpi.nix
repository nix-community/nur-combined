{ stdenv, fetchurl, glibc, gcc, file
, cpio, rpm
, patchelf
, preinstDir ? "opt/intel/compilers_and_libraries_${version}/linux/mpi"
, version ? "2019.1.144"
}:

let

  versions = {
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11595/l_mpi_2017.3.196.tgz
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11334/l_mpi_2017.2.174.tgz
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11014/l_mpi_2017.1.132.tgz
    ## # built from parallel_studio_xe_2016.3.068
    # http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9278/l_mpi_p_5.1.3.223.tgz
    #"2017.4.239" = fetchurl {
    #  url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12209/l_mpi_2017.4.239.tgz";
    #  sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d6";
    #};
    #"2018.0.128" = fetchurl {
    #  url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12120/l_mpi_2018.0.128.tgz";
    #  sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d5";
    #};
    #"2018.1.163" = fetchurl {
    #  url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12414/l_mpi_2018.1.163.tgz";
    #  sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d4";
    #};
    #"2018.2.189" = fetchurl {
    #  url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12748/l_mpi_2018.2.199.tgz";
    #  sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d3";
    #};
    "2018.3.222" = fetchurl {
      url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13112/l_mpi_2018.3.222.tgz";
      sha256 = "16c94p7w12hyd9x5v28hhq2dg101sx9lsvhlkzl99isg6i5x28ah";
    };
    "2018.5.274" = fetchurl {
      url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13741/l_mpi_2018.4.274.tgz";
      sha256 = "1q6qbnfzqkxc378mj803a2g6238m0ankrf34i482z70lnhz4n4d1";
    };
    "2019.0.117" = fetchurl {
      url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13584/l_mpi_2019.0.117.tgz";
      sha256 = "025ww7qa03mbbs35fb63g4x8qm67i49bflm9g8ripxhskks07d6z";
    };
    "2019.1.144" = fetchurl {
      url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/14879/l_mpi_2019.1.144.tgz";
      sha256 = "1kf3av1bzaa98p5h6wagc1ajjhvahlspbca26wqh6rdqnrfnmj6s";
    };
  };

  components_ = [
    "intel-mpi-rt-*"
    "intel-mpi-sdk-*"
  ];

  extract = pattern: ''
    for rpm in $(ls /build/l_mpi_*/rpm/${pattern}); do
      ${rpm}/bin/rpm2cpio $rpm | ${cpio}/bin/cpio -ivd
    done
  '';


self = stdenv.mkDerivation rec {
  inherit version;
  name = "intelmpi-${version}";
  src = versions."${version}";

  nativeBuildInputs= [ file patchelf ];

  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    set -xv
    mkdir $out
    cd $out
    echo "${stdenv.lib.concatStringsSep "+" components_}"
    ${stdenv.lib.concatMapStringsSep "\n" extract components_}

    mv ${preinstDir}/* .
    rm -rf opt
    set +xv

    mkdir $out/Licenses
    #cp $licenseFile} $out/Licenses
    # Fixing man path
    rm -rf $out/benchmarks

    ln -s $out/intel64/bin $out/bin
    ln -s $out/intel64/etc $out/etc
    ln -s $out/intel64/include $out/include
    ln -s $out/intel64/lib $out/lib

  '';

  postFixup = ''
    echo "Patching rpath and interpreter..."
    for f in $(find $out -type f -executable); do
      type="$(file -b --mime-type $f)"
      case "$type" in
      "application/executable"|"application/x-executable")
        echo "Patching executable: $f"
        patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) --set-rpath ${glibc}/lib:${gcc.cc}/lib:${gcc.cc.lib}/lib:\$ORIGIN:\$ORIGIN/../lib $f || true
        ;;
      "application/x-sharedlib"|"application/x-pie-executable")
        echo "Patching library: $f"
        patchelf --set-rpath ${glibc}/lib:${gcc.cc}/lib:${gcc.cc.lib}/lib:\$ORIGIN:\$ORIGIN/../lib:\$ORIGIN/../../libfabric/lib $f || true
        ;;
      *) 
        echo "$f ($type) not patched" 
        ;;
      esac
    done
     echo "Fixing path into scripts..."
    for file in `grep -l -r "/${preinstDir}" $out`; do
      sed -e "s,/${preinstDir},$out,g" -i $file
    done
    for file in `grep -l -r "I_MPI_SUBSTITUTE_INSTALLDIR" $out`; do
      sed -e "s,I_MPI_SUBSTITUTE_INSTALLDIR,$out,g" -i $file
    done
  '';

  passthru = {
    isIntel = true;
  };

  meta = {
    description = "Intel MPI ${version} library";
    maintainers = [ stdenv.lib.maintainers.dguibert ];
    platforms = stdenv.lib.platforms.linux;
  };
};
in self
