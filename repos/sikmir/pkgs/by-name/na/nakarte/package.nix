{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  yarnConfigHook,
  yarnBuildHook,
  secretsConfig ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nakarte";
  version = "2025-12-20";

  src = fetchFromGitHub {
    owner = "sikmir";
    repo = "nakarte";
    rev = "0a2ffea6c504272cb837cee7afba3087a2e513bc";
    hash = "sha256-qrXSLdnwcd59/PMSeUGktkr+iF0YXjPCnVHzsm1NhPA=";
  };

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/yarn.lock";
    hash = "sha256-JFjeu3EVVQkz1jLQX+lb736jzr5xtvor4azctn20Mo4=";
  };

  postPatch =
    if (secretsConfig != null) then
      "cp ${builtins.toFile "secrets.js" secretsConfig} src/secrets.js"
    else
      "cp src/secrets.js{.template,}";

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
    yarnBuildHook
  ];

  installPhase = ''
    install -dm755 $out
    cp -r build/* $out
  '';

  meta = {
    homepage = "https://github.com/sikmir/nakarte";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.all;
    skip.ci = true;
  };
})
