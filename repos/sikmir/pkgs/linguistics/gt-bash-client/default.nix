{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "gt-bash-client";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "OPHoperHPO";
    repo = "GT-bash-client";
    rev = finalAttrs.version;
    hash = "sha256-dVtwuZsF9ExH6qadUO2MJiWmQ/elTKaVZAp+o3b6XUg=";
  };

  installPhase = ''
    install -Dm755 translate.sh $out/bin/gt-bash-client
  '';

  meta = with lib; {
    description = "Get translated text from your terminal! Console Google Translate Script (bash+curl+sed)";
    inherit (finalAttrs.src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.all;
    skip.ci = true;
  };
})
