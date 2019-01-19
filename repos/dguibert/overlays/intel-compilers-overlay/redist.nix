{ stdenv, fetchurl, glibc, file
, patchelf
, version ? "2019.0.117"
, preinstDir ? "compilers_and_libraries_${version}/linux"
}:

let
redist_srcs = {
  "2019.1.144" = fetchurl { url="https://software.intel.com/sites/default/files/managed/79/cd/l_comp_lib_2019.1.144_comp.for_redist.tgz"; sha256="05kd2lc2iyq3rgnbcalri86nf615n0c1ii21152yrfyxyhk60dxm"; };
};

in stdenv.mkDerivation rec {
  inherit version;
  name = "intel-compilers-redist-${version}";

  src = redist_srcs."${version}";
  nativeBuildInputs= [ file patchelf ];

  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    set -xv
    mkdir $out
    mv compilers_and_libraries_${version}/linux/* $out
    ln -s $out/compiler/lib/intel64_lin $out/lib
    set +xv
  '';
  preFixup = ''
    echo "Patching rpath and interpreter..."
    for f in $(find $out -type f -executable); do
      type="$(file -b --mime-type $f)"
      case "$type" in
      "application/executable"|"application/x-executable")
        echo "Patching executable: $f"
        patchelf --set-interpreter $(echo ${glibc}/lib/ld-linux*.so.2) --set-rpath ${glibc}/lib:\$ORIGIN:\$ORIGIN/../lib $f || true
        ;;
      "application/x-sharedlib"|"application/x-pie-executable")
        echo "Patching library: $f"
        patchelf --set-rpath ${glibc}/lib:\$ORIGIN:\$ORIGIN/../lib $f || true
        ;;
      *)
        echo "$f ($type) not patched"
        ;;
      esac
    done

    echo "Fixing path into scripts..."
    for file in `grep -l -r "${preinstDir}/" $out`
    do
      sed -e "s,${preinstDir}/,$out,g" -i $file
    done
  '';

  meta = {
    description = "Intel compilers and libraries ${version}";
    maintainers = [ stdenv.lib.maintainers.dguibert ];
    platforms = stdenv.lib.platforms.linux;
  };

}
