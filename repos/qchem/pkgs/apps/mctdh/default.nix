{ stdenv, lib, writeText, requireFile, python27, perl, gfortran
, blas, lapack, mpi, scalapack
# compile the MPI version
, useMPI ? false
} :

assert (!blas.isILP64) && (!lapack.isILP64);

let
  version = "8.4.17";

  platformcnf = writeText "platform.cnf" ''
    MCTDH_VERSION="${with lib.versions; major version + minor version}"
    MCTDH_PLATFORM="x86_64"
    MCTDH_COMPILER=${if useMPI then "gfortran" else "gfortran-64"}
    MCTDH_GNU_COMPILER="gfortran"
    ${lib.optionalString useMPI "MCTDH_SCALAPACK_FLAGS=-DSCALAPACK"}
    ${lib.optionalString useMPI "MCTDH_SCALAPACK_LIBS=-lscalapack"}
    MCTDH_GFORTRAN="gfortran"
    MCTDH_GFORTRAN_VERSION="${lib.getVersion gfortran}"

  '';

in stdenv.mkDerivation {
  pname = "mctdh";
  inherit version;

  src = requireFile {
    url = "https://www.pci.uni-heidelberg.de/cms/mctdh.html";
    name = "mctdh84.17.tgz";
    sha256 = "0p6dlpf0ikw6g8m3wsvda17ppcqb0nqijnx4ycy81vwdgx1fz8a5";
  };

  nativeBuildInputs = [ gfortran ];
  buildInputs = [ python27 perl blas lapack ]
    ++ lib.optional useMPI [ mpi scalapack ];

  postPatch = ''
    patchShebangs ./bin
    patchShebangs ./install

    # fix absoulte paths names
    find bin/ -type f -exec sed -i 's:/bin/mv:mv:' \{} \;
    find bin/ -type f -exec sed -i 's:/bin/rm:rm:' \{} \;
    find bin/ -type f -exec sed -i 's:/bin/mkdir:mkdir:' \{} \;
    find install/ -type f -exec sed -i 's:/bin/mv:mv:' \{} \;
    find install/ -type f -exec sed -i 's:/bin/rm:rm:' \{} \;
    find install/ -type f -exec sed -i 's:/bin/mkdir:mkdir:' \{} \;

    # remove build date
    sed -i 's:\$(date):none:' install/install_mctdh

    # fix the include dir for operators
    sed -i "s:\(mctdh[1-3]=\`echo \)\$MCTDH_DIR:\1$out/share/mctdh:" install/install_mctdh
  '';

  configurePhase = ''
    cp ${platformcnf} install/platform.cnf.priv
    sed -i 's/EXTERNAL_BLAS.*/EXTERNAL_BLAS=-lblas/;s/EXTERNAL_LAPACK.*/EXTERNAL_LAPACK=-llapack/' \
         install/compile.cnf_le

    mkdir utils
    cp -r bin/* utils/

    echo -e "n\nn\ny\nn\nn\n" | install/install_mctdh

    export MCTDH_DIR=$PWD/
  '';

  buildPhase = ''
    bin/compile -a -x lapack -Q -P ${lib.optionalString useMPI "-S -m"} all
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/mctdh

    cp -r operators $out/share/mctdh
    cp -r source/surfaces $out/share/mctdh

    cp -r utils/* $out/bin
    cp bin/binary/x86_64/* $out/bin

    ver=${lib.versions.major version}${lib.versions.minor version}
    for i in $(ls $out/bin/*''${ver}*); do
      ln -s "$i" $(echo $i | sed "s/\(.*\)''${ver}.*/\1/")
    done
  '';

  meta = with lib; {
    description = "Multi configuration time dependent hartree dynamics package";
    homepage = https://www.pci.uni-heidelberg.de/cms/mctdh.html;
    license = licenses.unfree;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}

