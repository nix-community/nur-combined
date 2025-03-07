{
  stdenv,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:
stdenv.mkDerivation rec {
  pname = "arkenfox-userjs";
  version = "135.0";
  src = fetchFromGitHub {
    repo = "user.js";
    owner = "arkenfox";
    rev = version;
    hash = "sha256-21DoV4SMueMFRHMsvfsPfQIOtsvRWNY06rE4gB7xFnc=";
  };

  dontBuild = true;

  patches = [ ./cleaner.patch ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/user.js}
    cp user.js $out/share/user.js/
    cp prefsCleaner.sh $out/bin/userjs-prefsCleaner

    runHook postInstall
  '';

  postFixup = ''
    patchShebangs --build $out/bin/userjs-prefsCleaner
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Firefox privacy, security and anti-tracking";
    homepage = "https://github.com/arkenfox/user.js";
    platforms = platforms.all;
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
