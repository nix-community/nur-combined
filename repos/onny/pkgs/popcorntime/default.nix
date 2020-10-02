{ pkgs, fetchurl, unzip
, callPackage, writeShellScriptBin, makeWrapper
, nodePackages, nwjs, phantomjs2 }:

with callPackage ./src.nix {}; let

  bundle = "$out/usr/share/${pname}";

  expectedNwjsVersion = "0.44.5";

  nwjs' = nwjs.overrideAttrs (x: {
    ffmpegPrebuilt = fetchurl {
      url = "https://github.com/iteufel/nwjs-ffmpeg-prebuilt/releases/download/${x.version}/${x.version}-linux-x64.zip";
      sha256 = "1ch14s80p4dpwkhwa831kqy4j7m55v1mdxvq0bdaa5jpd7c75mbk";
    };
    patchPhase = ''
      cd lib
      ${unzip}/bin/unzip -o $ffmpegPrebuilt
      ${x.patchPhase or ""}
    '';
  });

in (import ./node/default.nix {
  inherit pkgs;
}).package.override (x: {

  inherit src;
  name = pname;

  production = true;

  buildInputs = x.buildInputs ++ [
    (writeShellScriptBin "guppy" "true")

    nodePackages.node-gyp-build
    nodePackages.gulp

    phantomjs2
    makeWrapper
  ];

  preRebuild = ''
    patch -p1 < ${./ext-player.patch}
  '';

  postInstall = ''
    cache=cache/${expectedNwjsVersion}-sdk/linux64/
    mkdir -p $cache
    cp --no-preserve=mode -r ${nwjs'}/share/nwjs/. $cache
    gulp build
    mkdir -p ${bundle}
    cp -r build/Popcorn-Time/linux64/. ${bundle}
    chmod +x ${bundle}/Popcorn-Time
    mkdir -p $out/bin
    makeWrapper ${bundle}/Popcorn-Time $out/bin/${pname}
    rm -r $out/lib
  '';
})
