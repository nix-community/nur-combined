# NOTE please dont use this
# instead, build the isolated-vm module
# in the app that requires isolated-vm
# then you dont need a lockfile in nix sources
# examples:
# pkgs/by-name/we/webcrack/package.nix

{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  importNpmLock,
  nodejs,
}:

buildNpmPackage rec {
  pname = "isolated-vm";
  version = "6.0.2";

  src = fetchFromGitHub {
    owner = "laverdet";
    repo = "isolated-vm";
    tag = "v${version}";
    hash = "sha256-RS3LUu0rxw8O/O3TK4eezmNPUujAaBTEb3YZnr4j6Jg=";
  };

  # npmDepsHash = "";

  # TODO remove this in favor of npmDepsHash
  # once upstream has a lockfile in the source tree
  # https://github.com/laverdet/isolated-vm/issues/555
  npmDeps = importNpmLock {
    npmRoot = src;
    package = lib.importJSON ./package.json;
    packageLock = lib.importJSON ./package-lock.json;
  };

  npmConfigHook = importNpmLock.npmConfigHook;

  # dont run the build in npmConfigHook
  # fix: npm error gyp ERR! stack Error: EACCES: permission denied, mkdir '/nix/store/z1ivaf845p444waay9bxkl1nc3k793rg-source/build'
  # npmConfigHook is trying to run the build in $src (read-only)
  # but we want to run the build in $NIX_BUILD_TOP/$sourceRoot (write access)
  npmRebuildFlags = [ "--ignore-scripts" ];

  # run the build in $NIX_BUILD_TOP/$sourceRoot
  npmBuildScript = "rebuild";

  # FIXME
  /*
  +++ npm prune --omit=dev --no-save
  npm warn Unknown env config "nodedir". This will stop working in the next major version of npm. See `npm help npmrc` for supported config options.
  npm error code ENOTCACHED
  npm error request to https://registry.npmjs.org/prebuild failed: cache mode is 'only-if-cached' but no cached response is available.
  */
  dontNpmPrune = true;

  postInstall = ''
    # also install out/isolated_vm.node
    cp -r -v out $out/lib/node_modules/isolated-vm
  '';

  meta = {
    description = "Secure & isolated JS environments for nodejs";
    homepage = "https://github.com/laverdet/isolated-vm";
    changelog = "https://github.com/laverdet/isolated-vm/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.all;
  };
}
