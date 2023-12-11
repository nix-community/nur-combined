{ stdenv
, libpulseaudio
, fetchFromGitHub
, hostPlatform
, lib
}: stdenv.mkDerivation {
  pname = "paswitch";
  version = "2012-11-21";
  buildInputs = [ libpulseaudio ];

  src = fetchFromGitHub {
    # mirror of https://www.tablix.org/~avian/git/paswitch.git
    owner = "arcnmx";
    repo = "paswitch";
    rev = "1b900dae95068be5f72cf679c889c0c12b01091b";
    sha256 = "0403rl2wpyymbxzvqj2r00sb3q4j63rhchsa1x6dkyvmdkg1xahr";
  };

  configurePhase = ''
    substituteInPlace Makefile --replace gcc '$(CC)'
  '';

  installPhase = ''
    install -Dm0755 $pname $out/bin/$pname
  '';

  meta = with lib; {
    homepage = "https://www.tablix.org/~avian/blog/archives/2012/06/switching_pulseaudio_output_device/";
    mainProgram = "paswitch";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
  passthru.ci.skip = hostPlatform.isDarwin;
}
