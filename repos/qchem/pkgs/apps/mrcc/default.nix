{ stdenv, lib, makeWrapper, requireFile, writeScript, writeTextFile, which, coreutils }:
let
  localRelPrefix = "mrcc";

  /*
  Creation of wrapper scripts, that replace the entry points of MRCC, namely dmrcc and dmrcc_mpi.
  Those wrapper entrypoints create a local mrcc installation in the calling directory, that allows
  to obtain correct permissions for the basis sets.
  */
  commonEntry = ''
    # Define a cleanup function after crashes or normal termination of MRCC.
    function cleanup {
      rm -r $(pwd)/${localRelPrefix}
      export PATH=$originalPATH
      umask $originalUmask
    }

    # Look for all mrcc executables in the original installation directory.
    mrccExes=$(find @out@/bin -type f -executable ! -path BASIS ! -path MTESTS)

    # Create a local prefix for the mrcc installation and link all executables from the original
    # location to the new local prefix.
    mkdir -p $(pwd)/${localRelPrefix} && chown -R $USER $(pwd)/${localRelPrefix} && chmod u+rwx $(pwd)/${localRelPrefix}
    for exe in $mrccExes; do
      ln -s $exe $(pwd)/${localRelPrefix}/.
    done

    # To make the wrappers work again from the local prefix, replace all the original mrcc-prefix
    # paths.
    mrccLocalWrappers=$(find $(pwd)/${localRelPrefix}/ -type f -executable ! -name ".*-wrapped")
    for exe in $mrccLocalWrappers; do
      sed -i "s!@out@/bin/!$(pwd)/${localRelPrefix}/!g" $exe
    done;

    # Set a umask to make sure all files created during MRCC run have correct permissions.
    originalUmask=$(umask)
    umask 0023

    # The Basis directory must be copied and not just symlinked. This ensures, that the basis files
    # have correct permissions in there.
    cp --no-preserve=all -r @out@/share/BASIS ${localRelPrefix}/.

    # Save the original old path variable to restore it later and then make sure the local MRCC
    # installation prefix is the place where all the mrcc exes are found.
    originalPATH=$PATH
    export PATH=$(pwd)/${localRelPrefix}:$PATH

    # Create a trap if MRCC fails.
    trap cleanup EXIT ERR
  '';
  dmrccEntryScript = writeScript "dmrcc" (commonEntry + ''
      $(pwd)/${localRelPrefix}/dmrcc-original
    '');
  dmrccMpiEntryScript = writeScript "dmrcc_mpi" (commonEntry + ''
      $(pwd)/${localRelPrefix}/dmrcc_mpi-original
    '');

/*
This is the normal MRCC derivation without shenanigans. Only in the postFixup wrapper magic
happens to make MRCC work for the user. See the comments at postFixup.
*/
in stdenv.mkDerivation rec {
  pname = "mrcc";
  version = "2020.02.22";

  nativeBuildInputs = [
    makeWrapper
  ];

  src = let
    dashVersion = lib.strings.replaceStrings ["."] ["-"] version;
  in requireFile rec {
    name = "mrcc.${dashVersion}.binary.tar.gz";
    sha256 = "e7b4944c66b1b127f9e7b47ca973eee189a6085d4bbc8b2e46b082e57e49ad0b";
    url = "https://www.mrcc.hu/index.php/download-mrcc/mrcc-binary/send/4-mrcc-binary/31-mrcc-${dashVersion}-binary-tar";
    message = ''
      The MRCC source code and binaries are not publically available. Obtain your own license at
      https://www.mrcc.hu and download the binaries at ${url}. Add the archive ${name} to the nix
      store by:
        nix-store --add-fixed sha256 ${name}
      and then rebuild.
    '';
  };

  unpackPhase = ''
    tar -xf $src
  '';

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall

    # Move executables to $out
    mkdir -p $out/bin
    exes=$(find -type f -executable)
    for exe in $exes; do
      cp $exe $out/bin/.
    done

    # Move the tests and basis sets to share and make a symlink for MRCC
    mkdir -p $out/share
    cp -r BASIS $out/share/.
    cp -r MTEST $out/share/.
    ln -s $out/share/BASIS $out/bin/.
    ln -s $out/share/MTEST $out/bin/.

    # Copy the manual also to share
    cp manual.pdf $out/share/.

    runHook postInstall
  '';

  /*
  The postFixup introduces a lot of wrapper magic:
    1. All executables of MRCC are wrapped, so that correct MPI libraries and coreutils are found.
    2. The original mrcc entry points (dmrcc and dmrcc_mpi) are moved (to dmrcc-original and
       dmrcc_mpi-original), so that they can be replaced by other wrapper scripts
       (dmrccEntryScript and dmrccMpiEntryScript).
    3. The wrapper scripts dmrccEntryScript and dmrccMpiEntryScript are copied in the mrcc bin
       directory and replace the original entry points. Those scripts create in the directory from
       which they were called a "local" mrcc installation by linking the executables to calling
       directory and replace all the absolute paths in the wrappers of this derivation.
    4. The entrypoint wrapper scripts are wrapped AGAIN so that they have the correct coreutils
       available at runtime.
  */
  postFixup = ''
    # Step 1:
    # Look for all original mrcc executables and wrap them for paths and stuff
    exes=$(find $out/bin/ -type f -executable)
    for exe in $exes; do
    wrapProgram $exe \
      --prefix PATH : ${stdenv.cc.coreutils_bin}/bin \
      --prefix PATH : ${which}/bin
    done

    # Step 2:
    # Move the original mrcc entry points (dmrcc and dmrcc_mpi) to new, hidden names, so that they
    # can be replaced by my wrapper scripts. (They are already wrapped but that does not matter)
    mv $out/bin/dmrcc $out/bin/dmrcc-original
    mv $out/bin/dmrcc_mpi $out/bin/dmrcc_mpi-original

    # Step 3:
    # Replaces the original mrcc entry points by wrapper scripts, that create a local mrcc
    # installation in the calling directory.
    cp ${dmrccEntryScript} $out/bin/dmrcc && substituteAllInPlace $out/bin/dmrcc
    cp ${dmrccMpiEntryScript} $out/bin/dmrcc_mpi && substituteAllInPlace $out/bin/dmrcc_mpi

    # Step 4:
    # Now again wrap the entrypoints (which are wrapper scripts), so that they find the correct
    # coreutils.
    wrapProgram $out/bin/dmrcc --prefix PATH : ${coreutils}/bin
    wrapProgram $out/bin/dmrcc_mpi --prefix PATH : ${coreutils}/bin
  '';

  meta = with lib; {
    description = "MRCC is a suite of ab initio and density functional quantum chemistry programs for high-accuracy electronic structure calculations.";
    homepage = "https://www.mrcc.hu/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
