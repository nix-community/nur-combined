final: prev:
with prev; let
  versions = {
    "mpi.2021.1.1" = {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/17397/l_mpi_oneapi_p_2021.1.1.76_offline.sh";
      sha256 = null;
      url_name = "mpi_oneapi";
    };
    "mpi.2021.2.0" = {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/17729/l_mpi_oneapi_p_2021.2.0.215_offline.sh";
      sha256 = "sha256-0NTN0R7a/y5yheOPU33vzP8443owZ8AvSvQ6NimtSqM=";
      url_name = "mpi_oneapi";
    };
    "mpi.2021.3.0" = {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/17947/l_mpi_oneapi_p_2021.3.0.294_offline.sh";
      sha256 = "sha256-BMSPhk7kxyOxtMpi8r6owE1dfj3hkXH9YrF4aLx5vDY=";
      url_name = "mpi_oneapi";
    };
    "mpi.2021.3.1" = {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/18016/l_mpi_oneapi_p_2021.3.1.315_offline.sh";
      sha256 = "sha256-g3asb+bSdtob6K2qJo03sxNt3dLAHtCPdf0cRJYHXTo=";
      url_name = "mpi_oneapi";
    };

    # tbb version('2021.1.1', sha256='535290e3910a9d906a730b24af212afa231523cf13a668d480bade5f2a01b53b'
    "tbb.2021.3.0" = {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/17952/l_tbb_oneapi_p_2021.3.0.511_offline.sh";
      sha256 = "0cvncglahb224d8fcrf26vqc62dwbf282s69x512w9ixiq0mwgxq";
      url_name = "tbb_oneapi";
    };
    #mkl.version('2021.1.1', sha256='818b6bd9a6c116f4578cda3151da0612ec9c3ce8b2c8a64730d625ce5b13cc0c', expand=False)

    "compilers.2021.1.0" = {
      sha256 = "666b1002de3eab4b6f3770c42bcf708743ac74efeba4c05b0834095ef27a11b9";
      url_name = "HPCKit";
    };
    "compilers.2021.2.0" = {
      sha256 = "sha256-WrxH4zqXQVwi2pGEYLuQbcrShVIzrjg/ztpWZSJWLEo=";
      url_name = "HPCKit";
    };
    "compilers.2021.3.0" = {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/17912/l_HPCKit_p_2021.3.0.3230_offline.sh";
      sha256 = "sha256-G3zjpPRGyUnEUkg+snC9twzNuEO/VeQLvsZO925OYz4=";
      url_name = "HPCKit";
    };
  };

  components = {
    mpi = [
      "intel.oneapi.lin.mpi.devel,v=*" #2021.1.1-76
      "intel.oneapi.lin.mpi.runtime,v=*" #2021.1.1-76
    ];
    compilers = [
      "intel.oneapi.lin.compilers-common.runtime,v=*" #2021.1.1-189
      "intel.oneapi.lin.compilers-common,v=*" #2021.1.1-189
      "intel.oneapi.lin.dpcpp-cpp-common.runtime,v=*" #2021.1.1-189
      "intel.oneapi.lin.dpcpp-cpp-common,v=*" #2021.1.1-189
      "intel.oneapi.lin.dpcpp-cpp-compiler-pro,v=*" #2021.1.1-189
      "intel.oneapi.lin.dpcpp-cpp-pro-fortran-compiler-common,v=*" #2021.1.1-189
      "intel.oneapi.lin.ifort-compiler,v=*" #2021.1.1-189
      "intel.oneapi.lin.openmp,v=*" #2021.1.1-189
    ];
    tbb = [
      "intel.oneapi.lin.tbb.devel,v=*"
      "intel.oneapi.lin.tbb.runtime,v=*"
    ];
  };
  # mkl', components='intel.oneapi.lin.mkl.devel', releases=releases, url_name='onemkl')

  oneapiPackage = {
    name,
    version,
  }: attrs: let
    pname = "oneapi-${name}";
    url = versions."${name}.${version}".url;
    _oneapi_file = builtins.baseNameOf url;
    #self._url_name, version, release['build'])";

    extract = pattern: ''
      case "${pattern}" in
      *runtime*)
        mkdir -p runtime; cd runtime
        7za l    ../packages/${pattern}/cupPayload.cup
        7za x -y ../packages/${pattern}/cupPayload.cup
        cd -
        ;;
      *)
        mkdir -p out; cd out
        7za l    ../packages/${pattern}/cupPayload.cup
        7za x -y ../packages/${pattern}/cupPayload.cup
        cd -
        ;;
      esac
    '';
  in
    prev.stdenv.mkDerivation ({
        inherit pname version;

        src = prev.fetchurl {
          inherit (versions."${name}.${version}") url sha256;
        };

        buildInputs = with final; [
          p7zip
        ];

        unpackPhase = ''
          sh $src --extract-folder oneapi -x
          cd oneapi/$(basename ${_oneapi_file} .sh)
        '';

        nativeBuildInputs = [file patchelf nix-patchtools];

        dontPatchELF = true;
        dontStrip = true;
        noAuditTmpdir = true;

        installPhase = ''
          ${lib.concatMapStringsSep "\n" extract components."${name}"}
        '';
      }
      // attrs);

  mpi_attrs = {
    isIntel = true;
    outputs = ["out" "runtime"];

    libs = lib.concatStringsSep ":" [
      "${stdenv.cc.libc}/lib"
      "${gcc.cc}/lib"
      "${gcc.cc.lib}/lib"
      "${placeholder "runtime"}/lib"
    ];

    preFixup = ''
      mv out/_installdir/mpi/* $out

      mv runtime/_installdir/mpi/* $runtime
      # TODO handle debug/debug_mt/release_mt
      set -x
      (cd $runtime/lib/release; find \! -type d -exec ln -vsf $runtime/lib/release/{} $runtime/lib/{} \; )

      (cd $runtime; find -type d -exec mkdir -vp $out/{} \; )
      (cd $runtime; find \! -type d -exec ln -vsf $runtime/{} $out/{} \; )
      set +x

      sed -i -e "s@prefix=I_MPI_SUBSTITUTE_INSTALLDIR@prefix=$out@" $out/bin/mpi*
      sed -i -e "s@prefix=__EXEC_PREFIX_TO_BE_FILLED_AT_INSTALL_TIME__@prefix=$out@" $out/bin/mpi*

      echo $libs
      autopatchelf $out $runtime

    '';
  };

  libelf_0815 = lib.upgradeOverride libelf (o: {
    version = "0.8.15";
    src = fetchurl {
      url = "https://sourceware.org/elfutils/ftp/0.185/elfutils-0.185.tar.bz2";
      sha256 = "sha256-3I0+dKsglGXn9Wjhs7uaWhQvhlbitX0QBJpz2irmtaY=";
    };
    patches = [];
    nativeBuildInputs = o.nativeBuildInputs ++ [m4];
    buildInputs = (o.buildInputs or []) ++ [zlib];
    configureFlags =
      o.configureFlags
      ++ [
        "--disable-libdebuginfod"
        "--disable-debuginfod"
      ];
    doCheck = false;
  });

  libffi_3_0_13 = lib.upgradeOverride libffi (o: rec {
    version = "3.0.13";
    src = fetchurl {
      url = "https://sourceware.org/pub/libffi/libffi-${version}.tar.gz";
      sha256 = "0dya49bnhianl0r65m65xndz6ls2jn1xngyn72gd28ls3n7bnvnh";
    };

    patches = [];
  });

  compilers_attrs = mpi: tbb: {
    langFortran = true;
    isOneApi = true;

    outputs = ["out" "runtime"]; # FIXME runtime

    libs =
      (lib.concatStringsSep ":" [
        "${placeholder "runtime"}/lib"
        "${placeholder "runtime"}/compiler/lib/intel64_lin"
        "${placeholder "out"}/compiler/lib/intel64_lin"
      ])
      + ":"
      + (lib.makeLibraryPath [
        stdenv.cc.libc
        stdenv.cc.cc.lib
        zlib
        mpi
        tbb
        libxml2
        libelf_0815 #libelf.so.1
        libelf # libelf.so.0
        libffi_3_0_13 # libffi.so.6
      ]);

    preFixup = ''
      mv out/_installdir/compiler/*/linux $out

      mv runtime/_installdir/compiler/*/linux $runtime
      # Fixing man path
      rm -rf $out/documentation
      rm -rf $out/man

      rm -r $out/compiler/lib/ia32_lin
      rm -r $out/compiler/lib/ia32
      rm -r $runtime/compiler/lib/ia32_lin
      rm -r $out/bin/ia32

      (cd $runtime; find -type d -exec mkdir -vp  $out/{} \; )
      (cd $runtime; find -type f -exec ln -vsf $runtime/{} $out/{} \; )
      (cd $runtime/compiler/lib; ln -sv intel64_lin intel64)

      # FIXME
      mv $out/bin/clang%2B%2B $out/bin/clang++

      find $out -print0 | xargs -0 -i chmod +w {}
      # fix executable permission on shared libs
      find $out $runtime -type f -print0 -name \*.so\* | xargs -0 -i chmod +x {}

      # FIXME: libze_loader.so.1 (https://github.com/oneapi-src/level-zero)
      rm $out/lib/libomptarget.rtl.level0.so
      rm $runtime/lib/libpi_level_zero.so

      rm -r $out/lib/oclfpga/ # libxerces-c-3.2_dspba.so

      echo $libs
      autopatchelf $out
      autopatchelf $runtime

    '';
    passthru = {
      hardeningUnsupportedFlags = ["stackprotector"];
    };
  };

  hwloc_1 = lib.upgradeOverride hwloc (o: rec {
    version = "1.11.10";
    src = fetchurl {
      url = "http://www.open-mpi.org/software/hwloc/v1.11/downloads/${o.pname}-${version}.tar.bz2";
      sha256 = "1ryibcng40xcq22lsj85fn2vcvrksdx9rr3wwxpq8dw37lw0is1b";
    };

    patches = [];
  });

  tbb_attrs = {
    isIntel = true;
    outputs = ["out" "runtime"];

    libs =
      (lib.concatStringsSep ":" [
        "${stdenv.cc.libc}/lib"
        "${gcc.cc}/lib"
        "${gcc.cc.lib}/lib"
      ])
      + ":"
      + (lib.makeLibraryPath [
        hwloc_1 # libhwloc.so.5
        hwloc # libhwloc.so.15
      ]);
    preFixup = ''
      mv out/_installdir/tbb/* $out
      mv runtime/_installdir/tbb/* $runtime

      rm -r $out/lib/ia32
      ln -s $out/lib/intel64/gcc4.8/* $out/lib/
      ln -s $runtime/lib/intel64/gcc4.8/* $out/lib/

      (cd $runtime; find -type d -exec mkdir -vp  $out/{} \; )
      (cd $runtime; find -type f -exec ln -vsf $runtime/{} $out/{} \; )

      echo $libs
      autopatchelf $out $runtime

    '';
  };

  wrapCCWith = {
    cc,
    # This should be the only bintools runtime dep with this sort of logic. The
    # Others should instead delegate to the next stage's choice with
    # `targetPackages.stdenv.cc.bintools`. This one is different just to
    # provide the default choice, avoiding infinite recursion.
    bintools ?
      if pkgs.targetPlatform.isDarwin
      then pkgs.darwin.binutils
      else pkgs.binutils,
    libc ? bintools.libc or pkgs.stdenv.cc.libc,
    ...
  } @ extraArgs:
    pkgs.callPackage ./build-support/cc-wrapper (let
      self =
        {
          nativeTools = pkgs.targetPlatform == pkgs.hostPlatform && pkgs.stdenv.cc.nativeTools or false;
          nativeLibc = pkgs.targetPlatform == pkgs.hostPlatform && pkgs.stdenv.cc.nativeLibc or false;
          nativePrefix = pkgs.stdenv.cc.nativePrefix or "";
          noLibc = !self.nativeLibc && (self.libc == null);

          isGNU = cc.isGNU or false;
          isClang = true;
          isIntel = false;
          isOneApi = true;

          inherit cc bintools libc;
        }
        // extraArgs;
    in
      self);

  mkExtraBuildCommands = release_version: cc: runtime:
    ''
      rsrc="$out/resource-root"
      mkdir "$rsrc"

      if test ! -e ${cc}/lib/clang/${release_version}; then
        echo "error: ${cc}/lib/clang/${release_version} does not exists"
        ls ${cc}/lib/clang/
        exit 1
      fi

      ln -s "${cc}/lib/clang/${release_version}/include" "$rsrc"
      ln -s "${runtime}/lib" "$rsrc/lib"
      echo "-resource-dir=$rsrc" >> $out/nix-support/cc-cflags
      echo "-L${runtime}/lib" >> $out/nix-support/cc-cflags
    ''
    + prev.lib.optionalString prev.stdenv.targetPlatform.isLinux ''
      echo "--gcc-toolchain=${gccForLibs} -B${gccForLibs}" >> $out/nix-support/cc-cflags
    '';

  mkStdEnv = compilers: let
    stdenv_ = pkgs.overrideCC pkgs.stdenv compilers;
  in
    stdenv_
    // {
      mkDerivation = args:
        stdenv_.mkDerivation (args
          // {
            CC = "icx";
            CXX = "icpx";
            FC = "ifx";
            F77 = "ifx";
            F90 = "ifx";
            I_MPI_CC = "icx";
            I_MPI_CXX = "icpx";
            I_MPI_FC = "ifx";
            I_MPI_F77 = "ifx";
            I_MPI_F90 = "ifx";
          });
    };

  mkLegacyStdEnv = compilers: let
    stdenv_ = pkgs.overrideCC pkgs.stdenv (compilers // {isIntel = true;});
  in
    stdenv_
    // {
      mkDerivation = args:
        stdenv_.mkDerivation (args
          // {
            CC = "icc";
            CXX = "icpc";
            FC = "ifort";
            F77 = "ifort";
            F90 = "ifort";
            I_MPI_CC = "icc";
            I_MPI_CXX = "icpc";
            I_MPI_FC = "ifort";
            I_MPI_F77 = "ifort";
            I_MPI_F90 = "ifort";
          });
    };
in rec {
  ### For quick turnaround debugging, copy instead of install
  ### copytree('/opt/intel/oneapi/compiler', path.join(prefix, 'compiler'),
  ###          symlinks=True)
  ##rpath_dirs = ['lib',
  ##'lib/x64',
  ##'lib/emu',
  ##'lib/oclfpga/host/linux64/lib',
  ##'lib/oclfpga/linux64/lib',
  ##'compiler/lib/intel64_lin',
  ##'compiler/lib']
  ##patch_dirs = ['compiler/lib/intel64_lin',
  ##'compiler/lib/intel64',
  ##'bin']
  ##eprefix = path.join(prefix, 'compiler', 'latest', 'linux')
  ##rpath = ':'.join([path.join(eprefix, c) for c in rpath_dirs])
  ##for pd in patch_dirs:
  ##for file in glob.glob(path.join(eprefix, pd, '*')):
  ### Try to patch all files, patchelf will do nothing if
  ### file should not be patched
  ##subprocess.call(['patchelf', '--set-rpath', rpath, file])
  oneapiPackages_2021_1_0 = with oneapiPackages_2021_1_0; {
    unwrapped = oneapiPackage {
      name = "compilers";
      version = "2021.1.0";
    } (compilers_attrs mpi tbb);

    compilers = wrapCCWith {
      cc = unwrapped;
      #extraPackages = [ /*redist*/ final.which final.binutils unwrapped ];
      extraPackages = [
        unwrapped.runtime
        gcc
        /*
        for ifx
        */
      ];
      extraBuildCommands = mkExtraBuildCommands "12.0.0" unwrapped unwrapped.runtime;
    };

    mpi =
      oneapiPackage {
        name = "mpi";
        version = "2021.1.1";
      }
      mpi_attrs;

    /*
    Return a modified stdenv that uses Intel compilers
    */
    stdenv = mkStdEnv compilers;
    legacyStdenv = mkLegacyStdEnv compilers;
  };

  oneapiPackages_2021_2_0 = with oneapiPackages_2021_2_0; {
    unwrapped = oneapiPackage {
      name = "compilers";
      version = "2021.2.0";
    } (compilers_attrs mpi tbb);

    compilers = wrapCCWith {
      cc = unwrapped;
      #extraPackages = [ /*redist*/ final.which final.binutils unwrapped ];
      extraPackages = [
        unwrapped.runtime
        gcc
        /*
        for ifx
        */
      ];
      extraBuildCommands = mkExtraBuildCommands "12.0.0" unwrapped unwrapped.runtime;
    };

    mpi =
      oneapiPackage {
        name = "mpi";
        version = "2021.2.0";
      }
      mpi_attrs;

    /*
    Return a modified stdenv that uses Intel compilers
    */
    stdenv = mkStdEnv compilers;
    legacyStdenv = mkLegacyStdEnv compilers;
  };

  oneapiPackages_2021_3_0 = with oneapiPackages_2021_3_0; {
    unwrapped = oneapiPackage {
      name = "compilers";
      version = "2021.3.0";
    } (compilers_attrs mpi tbb);

    compilers = wrapCCWith {
      cc = unwrapped;
      #extraPackages = [ /*redist*/ final.which final.binutils unwrapped ];
      extraPackages = [
        unwrapped.runtime
        gcc
        /*
        for ifx
        */
      ];
      extraBuildCommands = mkExtraBuildCommands "13.0.0" unwrapped unwrapped.runtime;
    };

    mpi =
      oneapiPackage {
        name = "mpi";
        version = "2021.3.0";
      }
      mpi_attrs;

    /*
    Return a modified stdenv that uses Intel compilers
    */
    stdenv = mkStdEnv compilers;
    legacyStdenv = mkLegacyStdEnv compilers;
  };

  oneapiPackages_2021_3_1 = with oneapiPackages_2021_3_1; {
    unwrapped = oneapiPackage {
      name = "compilers";
      version = "2021.3.0";
    } (compilers_attrs mpi tbb);

    compilers = wrapCCWith {
      cc = unwrapped;
      #extraPackages = [ /*redist*/ final.which final.binutils unwrapped ];
      extraPackages = [
        unwrapped.runtime
        gcc
        /*
        for ifx
        */
      ];
      extraBuildCommands = mkExtraBuildCommands "13.0.0" unwrapped unwrapped.runtime;
    };

    mpi =
      oneapiPackage {
        name = "mpi";
        version = "2021.3.1";
      }
      mpi_attrs;

    tbb =
      oneapiPackage {
        name = "tbb";
        version = "2021.3.0";
      }
      tbb_attrs;

    /*
    Return a modified stdenv that uses Intel compilers
    */
    stdenv = mkStdEnv compilers;
    legacyStdenv = mkLegacyStdEnv compilers;
  };
}
