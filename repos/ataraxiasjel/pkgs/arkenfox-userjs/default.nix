{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:
stdenv.mkDerivation rec {
  pname = "arkenfox-userjs";
  version = "117.0";
  src = fetchFromGitHub {
    repo = "user.js";
    owner = "arkenfox";
    rev = version;
    hash = "sha256-mvQwK11nhZ9yiP9ONeHrP2by5h1UgFSABWkI25YjlN4=";
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
