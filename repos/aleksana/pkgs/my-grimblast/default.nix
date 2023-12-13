{ lib
, stdenvNoCC
, fetchFromGitHub
, coreutils
, scdoc
, makeWrapper
, wl-clipboard
, dunst
, slurp
, grim
, jq
, bash
, hyprland ? null
, gthumb
}:
stdenvNoCC.mkDerivation rec {
  pname = "my-grimblast";
  version = "0.1";

  prefetch = fetchFromGitHub {
    owner = "hyprwm";
    repo = "contrib";
    rev = "bfd3e0efc1af9654808e644b157eb3c170c26fa1";
    hash = "sha256-BWqQQLhpuQolMiLMTcsc8cNlNzI9+MG/uc184IlP2nA=";
  };

  src = "${prefetch}/${pname}";

  patches = [ ./grimblast.patch ];

  buildInputs = [ bash scdoc ];
  makeFlags = [ "PREFIX=$(out)" ];
  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/grimblast --prefix PATH ':' \
      "${lib.makeBinPath ([
        wl-clipboard
        coreutils
        dunst
        slurp
        grim
        jq
      ]
      ++ lib.optional (hyprland != null) hyprland)}" \
      --set GRIMBLAST_EDITOR ${gthumb}/bin/gthumb
  '';

  meta = with lib; {
    description = "A helper for screenshots within hyprland, based on grimshot";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ misterio77 ];
  };
}
