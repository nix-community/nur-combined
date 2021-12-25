{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "astronaut";
  version = "0.1.0";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = version;
    hash = "sha256-42n7XB7hJcuB7vvWB2chUUWFyZQkRTsdUnqEloU22GU=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-7SyawlfJ9toNVuFehGr5GQF6mNmS9E4kkNcqWllp8No=";

  installPhase = ''
    runHook preInstall
    make PREFIX=$out install
    runHook postInstall
  '';

  meta = with lib; {
    description = "A Gemini browser for the terminal";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
