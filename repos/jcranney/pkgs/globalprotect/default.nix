{ 
  stdenv, fetchFromGitHub, pkgs
}:
stdenv.mkDerivation rec {
  name = "globalprotect-openconnect-${version}";
  version = "v2.4.6";
  src = fetchFromGitHub { 
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    rev = version;
    hash = "sha256-AxerhMQBgEgeecKAhedokMdpra1C9iqhutPrdAQng6Q";
  };
  buildInputs = with pkgs; [
    pnpm jq cargo perl openconnect nodejs curl
  ];
  buildPhase = ''
    ls
    make build-rs
    ls
  '';
  installPhase = ''

    make install
  '';
  # installPhase = ''
  #   echo "here i'm installing"
  # '';
  # buildPhase = ''
  #   export HOME=$(pwd)
  #   export DESTDIR=$out
  #   echo "here i'm building"
  # '';
}
