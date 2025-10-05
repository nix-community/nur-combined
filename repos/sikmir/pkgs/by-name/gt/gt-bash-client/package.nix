{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gt-bash-client";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "OPHoperHPO";
    repo = "GT-bash-client";
    tag = finalAttrs.version;
    hash = "sha256-dVtwuZsF9ExH6qadUO2MJiWmQ/elTKaVZAp+o3b6XUg=";
  };

  installPhase = ''
    install -Dm755 translate.sh $out/bin/gt-bash-client
  '';

  meta = {
    description = "Get translated text from your terminal! Console Google Translate Script (bash+curl+sed)";
    homepage = "https://github.com/OPHoperHPO/GT-bash-client";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
})
