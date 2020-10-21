{ stdenv
, fetchurl
, dpkg
, makeWrapper
#, fetchFromGitHub
, python3Packages
, python3
, nodejs
, gcc_multi
, binutils
, gnumake
, which
, git
, perl
, curl
, glibc_multi
, yarn
}:

stdenv.mkDerivation rec {
  pname = "frida";
  version = "12.11.18";
  #disabled = !isPy38;
  #wheelName = "frida-${version}-cp${pythonVersion}-cp${pythonVersion}-linux_x86_64.whl";

  # building is somewhat complicated, described in https://nixos.wiki/wiki/Frida
  /* src = fetchFromGitHub {
    owner = "frida";
    repo = "frida";
    rev = "${version}";
    sha256 = "057017mglqa5ii52i0cxnrraw1qzdwqk5668d7x9n7qci81zgfic";
  }; */


  src = fetchurl {
    url = "https://github.com/frida/frida/releases/download/12.11.18/python3-frida_${version}-1.ubuntu-focal_amd64.deb";
    sha256 = "0wg0vsdlhv4wvp52ph0hhqclwrwfv4dxxs03p0mk5vxcalhpvjq8";
  };

  nativeBuildInputs = [ dpkg makeWrapper
    python3
    gcc_multi
    binutils
    gnumake
    which
    git
    nodejs
    perl
    curl
    glibc_multi
    yarn
   ];

  unpackPhase = "dpkg-deb -x $src $out";
  installPhase = ''
    mkdir $out/lib
    
  '';


  meta = with stdenv.lib; {
    description = "Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers";
    homepage = "https://www.frida.re";
    license = licenses.wxWindows;
  };
}
