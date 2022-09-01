{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "astronaut";
  version = "0.1.1";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = "astronaut";
    rev = version;
    hash = "sha256-eiUStCM9rJB4O+LVWxih6untjTPynj9cHX2b8Gz9/nQ=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorHash = "sha256-7SyawlfJ9toNVuFehGr5GQF6mNmS9E4kkNcqWllp8No=";

  ldflags = [ "-X main.ShareDir=${placeholder "out"}/share/astronaut" ];

  postBuild = ''
    scdoc < docs/astronaut.1.scd > docs/astronaut.1
  '';

  postInstall = ''
	install -Dm644 docs/astronaut.1 $out/share/man/man1/astronaut.1
	install -Dm644 config/astronaut.conf $out/share/astronaut/astronaut.conf
	install -Dm644 config/style.conf $out/share/astronaut/style.conf
  '';

  meta = with lib; {
    description = "A Gemini browser for the terminal";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
