{
  lib,
  buildNpmPackage,
  fetchurl,
  python3,
  pkg-config,
  cmake,
}:

buildNpmPackage (finalAttrs: {
  pname = "deepseek-harness";
  version = "0.1.0-rc.6";

  src = fetchurl {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-${finalAttrs.version}.tgz";
    hash = "sha512-brpZfED7ieRa2PQ5tUxMhHrM1pb2CmKFVM/f6yMULBDMicahk+Z2OsHgTwTDnoiZm23Ftu9rQz0NN4pflaoJcg==";
  };

  npmDepsHash = "sha256-9Cx3OhIK3xuyd6o+HZhAs+2eGsIrys8fNdtRePd4GnQ=";

  nativeBuildInputs = [
    python3
    pkg-config
    cmake
  ];

  dontUseCmakeConfigure = true;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "DeepSeek Harness: Everything is a Plugin";
    longDescription = ''
      DeepSeek Harness (dsh) is an open-source agent harness developed by
      DeepSeek AI. It uses an architecture where everything is a plugin,
      and is powered by Cordis.
    '';
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    downloadPage = "https://www.npmjs.com/package/@deepseek-ai/dsh";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dsh";
  };
})
