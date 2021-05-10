{ stdenv, lib, gfortran, fetchgit, python3, git }:

stdenv.mkDerivation rec {
    pname = "gdma";
    version = "2.3.3";

    nativeBuildInputs = [
      gfortran
      git
    ];

    buildInputs = [ python3 ];

    # Needs the .git subdirectory to generate a version string.
    src = fetchgit  {
      url = "https://gitlab.com/anthonyjs/${pname}.git";
      rev = "e2d289a25bc56278ef7962413201327eac68d11b";
      sha256= "0i6i2vz2lc0bj4sfragavxbx30zwxkh4lhjrk8lag0739xzhxr30";
      leaveDotGit = true;
    };

    postPatch = "patchShebangs src/version.py";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp -p bin/gdma $out/bin

      runHook postInstall
    '';

    hardeningDisable = [ "format" ];

    meta = with lib; {
      description = "Global Distributed Multipole Analysis from Gaussian Wavefunctions";
      homepage = "http://www-stone.ch.cam.ac.uk/pub/gdma/";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  }
