{ lib, buildGoModule, fetchFromSourcehut, scdoc, installShellFiles }:

buildGoModule rec {
  pname = "astronaut";
  version = "0.1.1";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = "astronaut";
    rev = version;
    hash = "sha256-eiUStCM9rJB4O+LVWxih6untjTPynj9cHX2b8Gz9/nQ=";
  };

  nativeBuildInputs = [ scdoc installShellFiles ];

  vendorHash = "sha256-7SyawlfJ9toNVuFehGr5GQF6mNmS9E4kkNcqWllp8No=";

  ldflags = [ "-X main.ShareDir=${placeholder "out"}/share/astronaut" ];

  postBuild = ''
    scdoc < docs/astronaut.1.scd > docs/astronaut.1
  '';

  postInstall = ''
    installManPage docs/astronaut.1
    install -Dm644 config/*.conf -t $out/share/astronaut
  '';

  meta = with lib; {
    description = "A Gemini browser for the terminal";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
