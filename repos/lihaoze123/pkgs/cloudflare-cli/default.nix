{ lib, buildNpmPackage, fetchurl, nodejs, autoPatchelfHook, patchelf, stdenv, versionCheckHook }:

let
  # Older patchelf corrupts libvips' DT_INIT when extending its RUNPATH.
  # https://github.com/NixOS/patchelf/issues/639
  patchelfForSharp = if lib.versionAtLeast patchelf.version "0.19" then patchelf else patchelf.overrideAttrs (_: {
    version = "0.19.1";
    src = fetchurl {
      url = "https://github.com/NixOS/patchelf/releases/download/0.19.1/patchelf-0.19.1.tar.bz2";
      hash = "sha256-LM4B3pNlOCn2q2iiDC7CdeHACpRhEHBKJ+ko0ubohxY=";
    };
  });
in
buildNpmPackage rec {
  pname = "cloudflare-cli";
  version = "1.0.0-beta.17";

  # Use the published bundle, matching `npm install -g cf`.
  src = fetchurl {
    url = "https://registry.npmjs.org/cf/-/cf-${version}.tgz";
    hash = "sha512-Lw7BF96BwJVY2f/93XuikgRNe+klVr+happT37JpmX6J0XiM+HXGiVt6ZmyWeUGNmBkCFVN5zWimiqq6GgdJrg==";
  };
  sourceRoot = "package";

  postPatch = ''
    # npm publishes monorepo-only devDependencies; the bundle needs only runtime deps.
    ${lib.getExe nodejs} --input-type=commonjs -e '
      const fs = require("fs");
      const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
      delete pkg.devDependencies;
      fs.writeFileSync("package.json", JSON.stringify(pkg, null, 2) + "\n");
    '
    cp ${./package-lock.json} package-lock.json
  '';
  npmDepsHash = "sha256-Na9DjRfuHNdvVxIdy/gzJIJBx1m7TixRRdTnxMYJnlo=";
  dontNpmBuild = true;
  npmFlags = [ "--ignore-scripts" ];

  # workerd and sharp ship native binaries in their npm platform packages.
  nativeBuildInputs = [ patchelfForSharp autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/cf";
  postInstallCheck = ''
    "$out/bin/cloudflare" --version
    "$out/lib/node_modules/cf/node_modules/.bin/workerd" --version
    ${lib.getExe nodejs} --input-type=commonjs -e '
      const assert = require("node:assert/strict");
      const sharp = require(process.argv[1]);
      sharp({ create: { width: 1, height: 1, channels: 4, background: "red" } })
        .png().toBuffer().then(png => {
          assert.equal(png.subarray(1, 4).toString(), "PNG");
        }).catch(error => { console.error(error); process.exitCode = 1; });
    ' "$out/lib/node_modules/cf/node_modules/sharp"
  '';

  meta = {
    description = "Official CLI for the Cloudflare API and Workers projects";
    homepage = "https://github.com/cloudflare/cf";
    license = with lib.licenses; [ mit asl20 ];
    sourceProvenance = [ lib.sourceTypes.fromSource lib.sourceTypes.binaryNativeCode ];
    mainProgram = "cf";
    platforms = [ "x86_64-linux" ];
  };
}
