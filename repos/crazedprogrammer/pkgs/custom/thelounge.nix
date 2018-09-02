# I'll fix this sometime, but not today.

{ stdenv, fetchFromGitHub, callPackage, nodejs }:

stdenv.mkDerivation {
  name = "thelounge";
  version = "2.5.0-rc.5";

  src = fetchFromGitHub {
    owner = "thelounge";
    repo = "lounge";
    rev = "69ef6831b9bf59e842cf4c3c17578260d9b83c34";
    sha256 = "19scp431lx3s6qncvgcb0c2mzlbd7dlgpk3dgxm21kgsrxxdb4bi";
  };

  buildInputs = [ nodejs ];
  buildPhase = ''
    HOME=/tmp npm i
    HOME=/tmp NODE_ENV=production npm run build
  '';

  installPhase = ''
    mkdir -p $out/lib
    mkdir -p $out/bin
    cp -r . $out/lib/lounge
    chmod +x $out/lib/lounge/index.js
    ln -s $out/lib/lounge/index.js $out/bin/lounge
  '';

  # Cannot be built inside a sandbox because npm requires networking.
  __noChroot = true;
}



# with stdenv.lib;

# let
#   nodePackages = callPackage (import <nixpkgs/pkgs/top-level/node-packages.nix>) {
#     self = nodePackages;
#     generated = package/thelounge.nix;
#   };
# in
#
# nodePackages.buildNodePackage rec {
#   name = "thelounge";
#   version = "2.5.0-rc.2";
#
#   src = fetchFromGitHub {
#     owner = "thelounge";
#     repo = "lounge";
#     rev = "fc0af518c6dd5251123d71f54d702453ab08f6eb";
#     sha256 = "042kslxbwnsfcd3wchasxwfxyx1p7jssyyxjbw3413nla24ixdcn";
#   };
#
#   postBuild = ''
#     NODE_ENV=production ${nodejs}/bin/npm run build
#   '';
#
#   deps = [
#     nodePackages.by-version."bcryptjs"."2.4.3"
#     nodePackages.by-version."cheerio"."0.22.0"
#     nodePackages.by-version."colors"."1.1.2"
#     nodePackages.by-version."commander"."2.11.0"
#     nodePackages.by-version."express"."4.16.0"
#     nodePackages.by-version."express-handlebars"."3.0.0"
#     nodePackages.by-version."fs-extra"."4.0.2"
#     nodePackages.by-version."irc-framework"."2.9.1"
#     nodePackages.by-version."ldapjs"."1.0.1"
#     nodePackages.by-version."lodash"."4.17.4"
#     nodePackages.by-version."moment"."2.18.1"
#     nodePackages.by-version."package-json"."4.0.1"
#     nodePackages.by-version."read"."1.0.7"
#     nodePackages.by-version."request"."2.83.0"
#     nodePackages.by-version."semver"."5.4.1"
#     nodePackages.by-version."socket.io"."1.7.4"
#     nodePackages.by-version."spdy"."3.4.7"
#     nodePackages.by-version."ua-parser-js"."0.7.14"
#     nodePackages.by-version."urijs"."1.18.12"
#     nodePackages.by-version."web-push"."3.2.3"
#     nodePackages.by-version."npm-run-all"."4.1.1"
#   nodePackages.by-version."babel-core"."6.26.0"
#   nodePackages.by-version."babel-loader"."7.1.2"
#   nodePackages.by-version."babel-preset-env"."1.6.0"
#   nodePackages.by-version."chai"."4.1.2"
#   nodePackages.by-version."css.escape"."1.5.1"
#   nodePackages.by-version."emoji-regex"."6.5.1"
#   nodePackages.by-version."eslint"."4.8.0"
#   nodePackages.by-version."font-awesome"."4.7.0"
#   nodePackages.by-version."fuzzy"."0.1.3"
#   nodePackages.by-version."handlebars"."4.0.10"
#   nodePackages.by-version."handlebars-loader"."1.6.0"
#   nodePackages.by-version."intersection-observer"."0.4.2"
#   nodePackages.by-version."jquery"."3.2.1"
#   nodePackages.by-version."jquery-textcomplete"."1.8.4"
#   nodePackages.by-version."jquery-ui"."1.12.1"
#   nodePackages.by-version."mocha"."3.5.3"
#   nodePackages.by-version."mousetrap"."1.6.1"
#   nodePackages.by-version."nyc"."11.2.1"
#   nodePackages.by-version."socket.io-client"."1.7.4"
#   nodePackages.by-version."stylelint"."8.1.1"
#   nodePackages.by-version."stylelint-config-standard"."17.0.0"
#   (callPackage (import <nixpkgs/pkgs/development/node-packages/default-v6.nix>) {}).webpack # nodePackages.by-version."webpack"."3.6.0"
# ];

# peerDependencies = [];
#};



# { stdenv, fetchFromGitHub, callPackage, python, utillinux }:
#
# with stdenv.lib;
#
# let
#   nodePackages = callPackage (import ../../../../top-level/node-packages.nix) {
#     neededNatives = [ python ] ++ optional (stdenv.isLinux) utillinux;
#     self = nodePackages;
#     generated = ./package.nix;
#   };
#
# in nodePackages.buildNodePackage rec {
#   name = "shout-${version}";
#   version = "0.53.0";
#
#   src = fetchFromGitHub {
#     owner = "erming";
#     repo = "shout";
#     rev = "2cee0ea6ef5ee51de0190332f976934b55bbc8e4";
#     sha256 = "1kci1qha1csb9sqb4ig487q612hgdn5lycbcpad7m9r6chn835qg";
#   };
#
#   buildInputs = nodePackages.nativeDeps."shout" or [];
#
#   deps = [
#     nodePackages.by-version."bcrypt-nodejs"."0.0.3"
#     nodePackages.by-version."cheerio"."^0.17.0"
#     nodePackages.by-version."commander"."^2.3.0"
#     nodePackages.by-version."event-stream"."^3.1.7"
#     nodePackages.by-version."express"."^4.9.5"
#     nodePackages.by-version."lodash"."~2.4.1"
#     nodePackages.by-version."mkdirp"."^0.5.0"
#     nodePackages.by-version."moment"."~2.7.0"
#     nodePackages.by-version."read"."^1.0.5"
#     nodePackages.by-version."request"."^2.51.0"
#     nodePackages.by-version."slate-irc"."~0.7.3"
#     nodePackages.by-version."socket.io"."~1.0.6"
#   ];
#
#   peerDependencies = [];
#
#   meta = {
#     description = "Web IRC client that you host on your own server";
#     license = licenses.mit;
#     homepage = http://shout-irc.com/;
#     maintainers = with maintainers; [ benley ];
#     platforms = platforms.unix;
#   };
# }
#
