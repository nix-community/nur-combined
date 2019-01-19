{ stdenv, fetchurl, glibc, gcc, file
, cpio, rpm
, patchelf
, version ? "2019.0.117"
, preinstDir ? "opt/intel/compilers_and_libraries_${version}/linux"
, config
}:

let
  inherit (builtins) elem;
  licenseHelpMsg = text: ''
    error: ${text} for Intel Parallel Studio
     Packages that are part of Intel Parallel Studio require a license and acceptance
    of the End User License Agreement (EULA).
     You can purchase a license at
    https://software.intel.com/en-us/parallel-studio-xe
     You can review the EULA at
    https://software.intel.com/en-us/articles/end-user-license-agreement
     Once purchased, you can use your license with the Intel Parallel Studio Nix
    packages using the following methods:
     a) for `nixos-rebuild` you can indicate the license file to use and your
       acceptance of the EULA by adding lines to `nixpkgs.config` in the
       configuration.nix, like so:
         {
           nixpkgs.config.psxe.licenseFile = /home/user/COM_L___XXXX-XXXXXXXX.lic;
         }
     b) For `nix-env`, `nix-build`, `nix-shell` or any other Nix command you can
       indicate the license file to use and your acceptance of the EULA by adding
       lines to ~/.config/nixpkgs/config.nix, like so:
          {
            psxe.licenseFile = /home/user/COM_L___XXXX-XXXXXXXX.lic;
          }
     Please note that the license type can be one of "composer", "professional" or
    "cluster";
     '';
  licenseFile = config.psxe.licenseFile or (throw (licenseHelpMsg "missing license file"));

  components_ = [
    "intel-comp*"
    "intel-c-comp*"
    "intel-openmp*"
    "intel-icc*"
    "intel-ifort*"
  ];

  extract = pattern: ''
    for rpm in $(ls /build/parallel_studio_xe_*/rpm/${pattern} | grep -v 32bit); do
      ${rpm}/bin/rpm2cpio $rpm | ${cpio}/bin/cpio -ivd
    done
  '';

versions = {
# "2016.0.109"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/7997/parallel_studio_xe_2016.tgz
# "2016.1.150"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/8365/parallel_studio_xe_2016_update1.tgz
# "2016.2.181"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/8676/parallel_studio_xe_2016_update2.tgz
# "2016.3.210" = null;
# "2016.3.223"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9061/parallel_studio_xe_2016_update3.tgz
# "2016.4.258"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9781/parallel_studio_xe_2016_update4.tgz
#
#
# "2017.0.098"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/9651/parallel_studio_xe_2017.tgz
# "2017.1.132"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/10973/parallel_studio_xe_2017_update1.tgz
# "2017.2.174"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11298/parallel_studio_xe_2017_update2.tgz
# http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11460/parallel_studio_xe_2017_update3.tgz
# "2017.4.196"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11537/parallel_studio_xe_2017_update4.tgz
# "2017.5.239"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12138/parallel_studio_xe_2017_update5.tgz
# http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12534/parallel_studio_xe_2017_update6.tgz
# "2017.7.259"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12856/parallel_studio_xe_2017_update7.tgz
# http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13709/parallel_studio_xe_2017_update8.tgz
#
#
# "2018.0.128"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12062/parallel_studio_xe_2018_professional_edition.tgz
# "2018.1.163"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12375/parallel_studio_xe_2018_update1_professional_edition.tgz
# "2018.2.199"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12718/parallel_studio_xe_2018_update2_professional_edition.tgz
# "2018.3.222"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/12999/parallel_studio_xe_2018_update3_professional_edition.tgz
# "2018.5.274"http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13718/parallel_studio_xe_2018_update4_professional_edition.tgz


  "2019.0.117" = fetchurl {
    url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/13578/parallel_studio_xe_2019_professional_edition.tgz";
    sha256 = "1qhicj98x60csr4a2hjb3krvw74iz3i3dclcsdc4yp1y6m773fcl";
  };
  "2019.1.144" = fetchurl {
    url = "http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/14854/parallel_studio_xe_2019_update1_professional_edition.tgz";
    sha256 = "1rhcfbig0qvkh622cvf8xjk758i3jh2vbr5ajdgms7jnwq99mii8";
  };
};


self = stdenv.mkDerivation rec {
  inherit version;
  name = "intel-compilers-${version}";

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
    cp ${licenseFile} $out/Licenses
  '';

  preFixup = ''
    # Fixing man path
    rm -f $out/documentation
    rm -f $out/man

    #TODO keep $ORIGIN:$ORIGIN/../lib
    #autopatchelf "$out"

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
        patchelf --set-rpath ${glibc}/lib:${gcc.cc}/lib:${gcc.cc.lib}/lib:\$ORIGIN:\$ORIGIN/../lib $f || true
        ;;
      *)
        echo "$f ($type) not patched"
        ;;
      esac
    done

    echo "Fixing path into scripts..."
    for file in `grep -l -r "/${preinstDir}/" $out`
    do
      sed -e "s,/${preinstDir}/,$out,g" -i $file
    done

    libc=$(dirname $(dirname $(echo ${glibc}/lib/ld-linux*.so.2)))
    for comp in icc icpc ifort ; do
      echo "-idirafter $libc/include -dynamic-linker $(echo ${glibc}/lib/ld-linux*.so.2)" >> $out/bin/intel64/$comp.cfg
    done

    for comp in icc icpc ifort xild xiar; do
      echo "#!/bin/sh" > $out/bin/$comp
      echo "export PATH=${gcc}/bin:${gcc.cc}/bin:\$PATH" >> $out/bin/$comp
      echo "source $out/bin/compilervars.sh intel64" >> $out/bin/$comp
      echo "$out/bin/intel64/$comp \"\$@\"" >> $out/bin/$comp
      chmod +x $out/bin/$comp
    done

    ln -s $out/compiler/lib/intel64_lin $out/lib
  '';

  enableParallelBuilding = true;

  passthru = {
    lib = self; # compatibility with gcc, so that `stdenv.cc.cc.lib` works on both
    isIntel = true;
    hardeningUnsupportedFlags = [ "stackprotector" ];
    langFortran = true;
  } // stdenv.lib.optionalAttrs stdenv.isLinux {
    inherit gcc;
  };

  meta = {
    description = "Intel compilers and libraries ${version}";
    maintainers = [ stdenv.lib.maintainers.dguibert ];
    platforms = stdenv.lib.platforms.linux;
  };
};
in self
