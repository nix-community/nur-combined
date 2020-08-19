{ stdenv, libpulseaudio, fetchgit, lib, hostPlatform }: lib.drvExec "bin/paswitch" (stdenv.mkDerivation rec {
  pname = "paswitch";
  version = "1b900dae95068be5f72cf679c889c0c12b01091b";
  buildInputs = [ libpulseaudio ];
  src = fetchgit {
    rev = version;
    url = https://www.tablix.org/~avian/git/paswitch.git;
    sha256 = "0403rl2wpyymbxzvqj2r00sb3q4j63rhchsa1x6dkyvmdkg1xahr";
  };

  configurePhase = ''
    substituteInPlace Makefile --replace gcc '$(CC)'
  '';

  installPhase = ''
    install -Dm0755 $pname $out/bin/$pname
  '';

  passthru.ci.skip = hostPlatform.isDarwin;
})
