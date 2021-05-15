{ lib, stdenv, callPackage, fetchFromGitHub}:
let
  buildGradle = callPackage ./gradle-env.nix {};
in
buildGradle rec {
  envSpec = ./gradle-env.json;

  pname = "dynmap";
  version = "3.1-beta-7";

  src = fetchFromGitHub {
    owner = "webbukkit";
    repo = pname;
    rev = "v${version}";
    sha256 = "0skaqldpzz7yjslw77rgfykj8lb237lyir42sp6h4rwsj8m73rg6";
  };

  gradleFlags = [ "installDist" ];

  installPhase = ''
    mkdir -p $out
    cp -r app/build/install/myproject $out
  '';

  meta = with lib; {
    homepage = "https://github.com/webbukkit/dynmap";
    description =
    " A set of Minecraft mods that provide a real time web-based map system for various Minecraft server implementations.";
    license = licenses.asl20;
    broken = true;
    # maintainers = with maintainers; [ zeratax ];
  };
}
