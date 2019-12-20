{ version, sha256, postPatch ? "", patches ? [] }:
{ stdenv, fetchurl, coreutils, procps, cpio }:
let oldPostPatch = postPatch;
in stdenv.mkDerivation rec {
  inherit version patches;
  name = "ncbi-blast-${version}";
  src = fetchurl {
    url = "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/${version}/${name}+-src.tar.gz";
    inherit sha256;
  };

  postPatch = ''
    patchShebangs ./scripts

    # TODO: helpers/
    for f in ./scripts/common/impl/*.sh ./src/build-system/Makefile* ./src/build-system/configure; do
      substituteInPlace $f \
        --replace "PATH=/bin:/usr/bin" "" \
        --replace "/bin/rm" "rm" \
        --replace "/bin/echo" "echo"\
        --replace "/bin/mkdir" "mkdir"\
        --replace "/bin/cp" "cp"\
        --replace "/bin/pwd" "pwd"\
        --replace "/bin/date" "date"\
        --replace "/bin/mv" "mv"\
        --replace "/bin/ln" "ln"\
        --replace "/bin/\$base_action" "\$base_action"\
        --replace "/bin/\$LN_S" "\$LN_S"\
        --replace "/usr/bin/dirname" "dirname" \
        2>/dev/null
    done
    substituteInPlace ./src/build-system/helpers/run_with_lock.c \
      --replace "/bin/rm" "${coreutils}/bin/rm" \
  '' + "\n" + oldPostPatch;

  preConfigure = ''
    export AR="$AR cr"
  '';

  preBuild = ''
    makeFlagsArray+=(
      'CXXFLAGS="-Wno-format-security"'
      'CFLAGS="-Wno-format-security"'
      '-j'
      "-l''${NIX_BUILD_CORES}"
    )
  '';

  buildInputs = [ procps cpio ];

  sourceRoot = "${name}+-src/c++";
}
