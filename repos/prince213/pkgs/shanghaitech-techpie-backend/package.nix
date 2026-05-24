{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nodejs,
  pnpmConfigHook,
  pnpm_9,
}:

buildNpmPackage (finalAttrs: {
  pname = "shanghaitech-techpie-backend";
  version = "0-unstable-2026-05-22";

  src = fetchFromGitHub {
    private = true;
    owner = "Honahec";
    repo = "shanghaitech-cpdaily-auth";
    rev = "7c67c3a8a53a661680412aeee884fee68dde3202";
    hash = "sha256-HTZ9N9FvVIHEXELw1KdXkX3IlMGS//+nUt0IqLyKgQg=";
  };

  npmDeps = null;
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_9;
    fetcherVersion = 3;
    hash = "sha256-w2aVJDCcr5X4G8InECPv3GoQgf8UMRgJ1L1Ezpb/7CQ=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    pnpm_9
  ];

  npmConfigHook = pnpmConfigHook;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r .next/standalone $out/share/shanghaitech-techpie-backend
    rm $out/share/shanghaitech-techpie-backend/node_modules/.pnpm/node_modules/semver

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/shanghaitech-techpie-backend \
      --add-flag $out/share/shanghaitech-techpie-backend/server.js

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Honahec/shanghaitech-cpdaily-auth";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "shanghaitech-techpie-backend";
  };
})
