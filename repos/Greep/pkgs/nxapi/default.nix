{ lib
, buildNpmPackage
, nodejs_22
, makeWrapper
, fetchurl
, maintainers
}:

let
  version = "1.6.1";

  # The npm tarball contains dist/ (precompiled CLI) + bin/ + resources/
  # but NOT package-lock.json (required by buildNpmPackage).
  srcTarball = fetchurl {
    url = "https://registry.npmjs.org/nxapi/-/nxapi-${version}.tgz";
    hash = "sha256-xDJ/s6jYgU4SCeqknCUm9avo5QHjExha1OZfWIXS7TU=";
  };

  # package-lock.json fetched from the git tag v1.6.1
  packageLock = fetchurl {
    url = "https://raw.githubusercontent.com/samuelthomas2774/nxapi/v${version}/package-lock.json";
    hash = "sha256-lnSDclqWoSJvXMmBjSLiPGNzvX7oSB/nFBn2UhDTS34=";
  };
in buildNpmPackage {
  pname = "nxapi";
  inherit version;

  src = srcTarball;

  # Injects the missing package-lock.json into the npm tarball
  postPatch = ''
    cp ${packageLock} package-lock.json
  '';

  # dist/ is already present in the tarball, no need for tsc/rollup
  dontNpmBuild = true;

  # register-scheme is an optional git dependency (from discord-rpc)
  forceGitDeps = true;

  npmDepsHash = "sha256-5SORJHxpBLeje5XRPP36gesiary3qpnI8MdvTAsL8yM=";

  nodejs = nodejs_22;

  nativeBuildInputs = [ makeWrapper ];

  # Avoids native recompilation of sharp (uses prebuilt binaries)
  npmFlags = [ "--ignore-scripts" ];

  # Wrapper to launch via node
  postInstall = ''
    wrapProgram $out/bin/nxapi \
      --prefix PATH : ${lib.makeBinPath [ nodejs_22 ]}
  '';

  meta = with lib; {
    description = "Nintendo Switch Online/Parental Controls app APIs - CLI";
    homepage = "https://github.com/samuelthomas2774/nxapi";
    license = licenses.agpl3Plus;
    mainProgram = "nxapi";
    platforms = platforms.linux;
    maintainers = with maintainers; [ greep ];
  };
}