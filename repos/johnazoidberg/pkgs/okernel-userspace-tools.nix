{ stdenv, fetchFromGitHub, glibc }:
stdenv.mkDerivation {
  name = "okernel-userspace-tools";
  src = fetchFromGitHub {
    owner = "JohnAZoidberg";
    repo = "linux-okernel-components";
    rev = "2921e8da757e451a54517297991bf70e8b427985";
    sha256 = "0ylwz9yw16jb6d12xbfq9hncw30h12ds5y16vb4rcdv2vpq8f4lc";
  };

  postUnpack = "sourceRoot=\${sourceRoot}/userspace_tools/";

  nativeBuildInputs = [ glibc.static ];

  makeFlags = "DESTDIR= PREFIX=$(out)";  # is this not standard?
}
