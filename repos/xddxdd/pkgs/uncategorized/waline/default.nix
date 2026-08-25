{
  fetchurl,
  lib,
  buildNpmPackage,
  nodejs,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "waline";
  version = "1.41.5";
  src = fetchurl {
    url = "https://registry.npmjs.org/@waline/vercel/-/vercel-1.41.4.tgz";
    hash = "sha256-7zU5WOzvftX0gdok1eYgTQ/CuCIEEle/ZC2oxqvmUng=";
  };
  sourceRoot = "package";

  npmDepsHash = "sha256-svdWIpsD3aLejiG+Ja6D6XKbWVlchP42olJsRKNfjkM=";

  patches = [ ./runtime-path.patch ];

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/waline \
      --add-flags "$out/lib/node_modules/@waline/vercel/vanilla.js"
  '';

  meta = {
    description = "Server for the Waline comment system";
    homepage = "https://github.com/walinejs/waline";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "waline";
    platforms = lib.platforms.linux;
  };

  passthru.updateScript = nix-update-script { };
})
