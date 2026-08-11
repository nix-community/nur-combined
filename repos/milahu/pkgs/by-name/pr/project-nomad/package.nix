{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  pkg-config,
  libzim,
  nodejs,
  makeWrapper,
}:

# fix: error: zim/illustration.h: No such file or directory
# https://github.com/NixOS/nixpkgs/pull/495709 # libzim 9.5.0
let old_libzim = libzim; in
let
  libzim = old_libzim.overrideAttrs (oldAttrs: rec {
    # https://github.com/openzim/node-libzim/blob/main/.env
    version = "9.5.0";
    src = fetchFromGitHub {
      owner = "openzim";
      repo = "libzim";
      tag = version;
      hash = "sha256-YeskvTtwibKQxMY4c6yEHW+EmXUq4AXpd5XLxKfsmXg=";
    };
    patches = [ ];
  });
in

buildNpmPackage (finalAttrs: {

  pname = "project-nomad";

  version = "1.29.1";

  src = fetchFromGitHub {
    owner = "Crosstalk-Solutions";
    repo = "project-nomad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MZwM2WDU8Jy+k382FAQ7Rlf0dMdUE/UxwtLEWcLrAXE=";
  };

  sourceRoot = "${finalAttrs.src.name}/admin";

  buildInputs = [
    libzim
  ];

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  npmDepsHash = "sha256-3BIwW9N95FgzusBh5valj8ufxxJ4G5/2obf1d6ozewQ=";

  # fix: @openzim/libzim tries to download libzim
  # npm error path /build/source/admin/node_modules/@openzim/libzim
  # npm error command failed
  # npm error command sh -c npm run download && node-gyp rebuild -v && npm run bundle
  #
  # dont run the "install" script of @openzim/libzim
  # https://github.com/openzim/node-libzim/blob/main/package.json
  # "install": "npm run download && node-gyp rebuild -v && npm run bundle",
  # npm-config-hook.sh runs: npm rebuild $npmRebuildFlags
  npmRebuildFlags = [ "--ignore-scripts" ];

  # fix: Error: Could not locate the bindings file zim_binding.node
  # https://github.com/openzim/node-libzim
  postConfigure = ''
    pushd node_modules/@openzim/libzim

    # use libzim via pkg-config
    substituteInPlace binding.gyp \
      --replace-fail \
        '"libzim_local": "false"' \
        '"libzim_local": "true"'

    npm run build

    # fix: dont create dangling symlink
    # https://github.com/openzim/node-libzim/issues/186
    rm -v build/Release/libzim.so || true

    popd
  '';

  postInstall = ''
    makeWrapper ${nodejs}/bin/node $out/bin/project-nomad-server \
      --add-flags "$out/lib/node_modules/project-nomad-admin/build/bin/server.js"

    makeWrapper ${nodejs}/bin/node $out/bin/project-nomad-console \
      --add-flags "$out/lib/node_modules/project-nomad-admin/build/bin/console.js"
  '';

  meta = {
    description = "Project N.O.M.A.D, is a self-contained, offline survival computer packed with critical tools, knowledge, and AI to keep you informed and empowered—anytime, anywhere";
    homepage = "https://github.com/Crosstalk-Solutions/project-nomad";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "project-nomad-server";
    platforms = lib.platforms.all;
  };
})
