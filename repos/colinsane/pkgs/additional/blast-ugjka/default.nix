{ buildGoModule
, fetchFromGitHub
, lib
, makeWrapper
, pulseaudio
}:
buildGoModule rec {
  pname = "blast-ugjka";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "ugjka";
    repo = "blast";
    rev = "v${version}";
    hash = "sha256-Y9Jj+UrrsyRfihHAdC354jb1385xqLIufB0DoikrXYM=";
  };

  vendorHash = "sha256-yPwLilMiDR1aSeuk8AEmuYPsHPRWqiByGLwgkdI5t+s=";

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = ''
    wrapProgram $out/bin/blast \
        --suffix PATH : ${lib.makeBinPath [ pulseaudio ]}
  '';

  meta = with lib; {
    description = "blast your linux audio to DLNA receivers";
    # license = licenses.mit;  # MIT + NoAI
    inherit (src.meta) homepage;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.unix;
  };
}
