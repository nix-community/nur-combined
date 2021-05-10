{ stdenv, lib, gfortran, fetchFromGitHub, makeWrapper, bash, turbomole }:

stdenv.mkDerivation rec {
    pname = "cefine";
    version = "2.23";

    nativeBuildInputs = [
      gfortran
      makeWrapper
    ];

    propagatedBuildInputs = [ turbomole ];

    src = fetchFromGitHub  {
      owner = "grimme-lab";
      repo = pname;
      rev = "v${version}";
      sha256= "0jjmvcsn5wl0djglmy0ahbx1s6d6g6f04bv2w7rrsvh9has838sa";
    };

    hardeningDisable = [ "format" ];

    dontConfigure = true;

    buildPhase = ''
      gfortran -o cefine cefine.f90
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp cefine $out/bin/.
    '';

    binSearchPath = lib.strings.makeSearchPath "bin" [ bash turbomole ];

    postFixup = ''
      wrapProgram $out/bin/cefine \
        --prefix PATH : "${binSearchPath}"
    '';

    meta = with lib; {
      description = "Non-interactive command-line wrapper around turbomoles define";
      license = licenses.lgpl3Only;
      homepage = "https://github.com/grimme-lab/cefine";
      platforms = platforms.linux;
    };
  }
