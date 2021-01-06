# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:
let
  callPackage = pkgs.callPackage;
  stdenv = pkgs.stdenv;

  gradlePkgs = pkgs.callPackage ./pkgs/gradle { };
  groovyPkgs = pkgs.callPackage ./pkgs/groovy { };
  groovy4Pkgs = pkgs.callPackage ./pkgs/groovy4 { };
  springBootCliPkgs = pkgs.callPackage ./pkgs/spring-boot-cli { };
  jbangPkgs = pkgs.callPackage ./pkgs/jbang { };
  mavenPkgs = pkgs.callPackage ./pkgs/apache-maven { };
  micronautPkgs = pkgs.callPackage ./pkgs/micronaut { };
  micronautCliPkgs = pkgs.callPackage ./pkgs/micronaut-cli { };

  adoptopenjdk-bin-8-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk8-linux.nix;
  adoptopenjdk-bin-8-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk8-darwin.nix;
  adoptopenjdk-bin-9-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk9-linux.nix;
  adoptopenjdk-bin-9-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk9-darwin.nix;
  adoptopenjdk-bin-10-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk10-linux.nix;
  adoptopenjdk-bin-10-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk10-darwin.nix;
  adoptopenjdk-bin-11-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk11-linux.nix;
  adoptopenjdk-bin-11-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk11-darwin.nix;
  adoptopenjdk-bin-12-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk12-linux.nix;
  adoptopenjdk-bin-12-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk12-darwin.nix;
  adoptopenjdk-bin-13-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk13-linux.nix;
  adoptopenjdk-bin-13-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk13-darwin.nix;
  adoptopenjdk-bin-14-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk14-linux.nix;
  adoptopenjdk-bin-14-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk14-darwin.nix;
  adoptopenjdk-bin-15-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk15-linux.nix;
  adoptopenjdk-bin-15-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk15-darwin.nix;
  adoptopenjdk-bin-16-packages-linux = import ./pkgs/adoptopenjdk-bin/jdk16-linux.nix;
  adoptopenjdk-bin-16-packages-darwin = import ./pkgs/adoptopenjdk-bin/jdk16-darwin.nix;
in rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  adoptopenjdk-hotspot-bin-8 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-8-packages-linux.jdk-hotspot {}
    else callPackage adoptopenjdk-bin-8-packages-darwin.jdk-hotspot {};
  adoptopenjdk-jre-hotspot-bin-8 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-8-packages-linux.jre-hotspot {}
    else callPackage adoptopenjdk-bin-8-packages-darwin.jre-hotspot {};
  adoptopenjdk-openj9-bin-8 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-8-packages-linux.jdk-openj9 {}
    else callPackage adoptopenjdk-bin-8-packages-darwin.jdk-openj9 {};
  adoptopenjdk-jre-openj9-bin-8 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-8-packages-linux.jre-openj9 {}
    else callPackage adoptopenjdk-bin-8-packages-darwin.jre-openj9 {};

  adoptopenjdk-hotspot-bin-10 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-10-packages-linux.jdk-hotspot {}
    else callPackage adoptopenjdk-bin-10-packages-darwin.jdk-hotspot {};
  adoptopenjdk-jre-hotspot-bin-10 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-10-packages-linux.jre-hotspot {}
    else callPackage adoptopenjdk-bin-10-packages-darwin.jre-hotspot {};

  adoptopenjdk-hotspot-bin-11 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-11-packages-linux.jdk-hotspot {}
    else callPackage adoptopenjdk-bin-11-packages-darwin.jdk-hotspot {};
  adoptopenjdk-jre-hotspot-bin-11 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-11-packages-linux.jre-hotspot {}
    else callPackage adoptopenjdk-bin-11-packages-darwin.jre-hotspot {};
  adoptopenjdk-openj9-bin-11 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-11-packages-linux.jdk-openj9 {}
    else callPackage adoptopenjdk-bin-11-packages-darwin.jdk-openj9 {};
  adoptopenjdk-jre-openj9-bin-11 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-11-packages-linux.jre-openj9 {}
    else callPackage adoptopenjdk-bin-11-packages-darwin.jre-openj9 {};

  adoptopenjdk-hotspot-bin-12 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-12-packages-linux.jdk-hotspot {}
    else callPackage adoptopenjdk-bin-12-packages-darwin.jdk-hotspot {};
  adoptopenjdk-jre-hotspot-bin-12 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-12-packages-linux.jre-hotspot {}
    else callPackage adoptopenjdk-bin-12-packages-darwin.jre-hotspot {};
  adoptopenjdk-openj9-bin-12 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-12-packages-linux.jdk-openj9 {}
    else callPackage adoptopenjdk-bin-12-packages-darwin.jdk-openj9 {};
  adoptopenjdk-jre-openj9-bin-12 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-12-packages-linux.jre-openj9 {}
    else callPackage adoptopenjdk-bin-12-packages-darwin.jre-openj9 {};

  adoptopenjdk-hotspot-bin-13 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-13-packages-linux.jdk-hotspot {}
    else callPackage adoptopenjdk-bin-13-packages-darwin.jdk-hotspot {};
  adoptopenjdk-jre-hotspot-bin-13 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-13-packages-linux.jre-hotspot {}
    else callPackage adoptopenjdk-bin-13-packages-darwin.jre-hotspot {};
  adoptopenjdk-openj9-bin-13 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-13-packages-linux.jdk-openj9 {}
    else callPackage adoptopenjdk-bin-13-packages-darwin.jdk-openj9 {};
  adoptopenjdk-jre-openj9-bin-13 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-13-packages-linux.jre-openj9 {}
    else callPackage adoptopenjdk-bin-13-packages-darwin.jre-openj9 {};

  adoptopenjdk-hotspot-bin-14 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-14-packages-linux.jdk-hotspot {}
    else callPackage adoptopenjdk-bin-14-packages-darwin.jdk-hotspot {};
  adoptopenjdk-jre-hotspot-bin-14 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-14-packages-linux.jre-hotspot {}
    else callPackage adoptopenjdk-bin-14-packages-darwin.jre-hotspot {};
  adoptopenjdk-openj9-bin-14 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-14-packages-linux.jdk-openj9 {}
    else callPackage adoptopenjdk-bin-14-packages-darwin.jdk-openj9 {};
  adoptopenjdk-jre-openj9-bin-14 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-14-packages-linux.jre-openj9 {}
    else callPackage adoptopenjdk-bin-14-packages-darwin.jre-openj9 {};

  adoptopenjdk-hotspot-bin-15 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-15-packages-linux.jdk-hotspot {}
    else callPackage adoptopenjdk-bin-15-packages-darwin.jdk-hotspot {};
  adoptopenjdk-jre-hotspot-bin-15 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-15-packages-linux.jre-hotspot {}
    else callPackage adoptopenjdk-bin-15-packages-darwin.jre-hotspot {};
  adoptopenjdk-openj9-bin-15 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-15-packages-linux.jdk-openj9 {}
    else callPackage adoptopenjdk-bin-15-packages-darwin.jdk-openj9 {};
  adoptopenjdk-jre-openj9-bin-15 = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-15-packages-linux.jre-openj9 {}
    else callPackage adoptopenjdk-bin-15-packages-darwin.jre-openj9 {};

  adoptopenjdk-hotspot-bin-16-nightly = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-16-packages-linux.jdk-hotspot {}
    else callPackage adoptopenjdk-bin-16-packages-darwin.jdk-hotspot {};
  adoptopenjdk-jre-hotspot-bin-16-nightly = if stdenv.isLinux
    then callPackage adoptopenjdk-bin-16-packages-linux.jre-hotspot {}
    else callPackage adoptopenjdk-bin-16-packages-darwin.jre-hotspot {};

  gradle-4_10_3 = gradlePkgs.gradle-4_10_3;
  gradle-5_6_4 = gradlePkgs.gradle-5_6_4;
  gradle-6_2_2 = gradlePkgs.gradle-6_2_2;
  gradle-6_3 = gradlePkgs.gradle-6_3;
  gradle-6_4 = gradlePkgs.gradle-6_4;
  gradle-6_7_1 = gradlePkgs.gradle-6_7_1;

  groovy-2_4_19 = groovyPkgs.groovy-2_4_19;
  groovy-2_4_21 = groovyPkgs.groovy-2_4_21;
  groovy-2_5_10 = groovyPkgs.groovy-2_5_10;
  groovy-2_5_11 = groovyPkgs.groovy-2_5_11;
  groovy-2_5_14 = groovyPkgs.groovy-2_5_14;
  groovy-3_0_2 = groovyPkgs.groovy-3_0_2;
  groovy-3_0_3 = groovyPkgs.groovy-3_0_3;
  groovy-3_0_7 = groovyPkgs.groovy-3_0_7;
  groovy-4_0_0-alpha-2 = groovy4Pkgs.groovy-4_0_0-alpha-2;

  jbang-0_58_0 = jbangPkgs.jbang-0_58_0;

  apache-maven-3_5_4 = mavenPkgs.apache-maven-3_5_4;
  apache-maven-3_6_3 = mavenPkgs.apache-maven-3_6_3;

  micronaut-1_3_4 = micronautPkgs.micronaut-1_3_4;
  micronaut-1_3_5 = micronautPkgs.micronaut-1_3_5;

  micronaut-cli-2_2_2 = micronautCliPkgs.micronaut-cli-2_2_2;

  netbeans-11_3 = callPackage ./pkgs/netbeans { };

  spring-boot-cli-2_2_6 = springBootCliPkgs.spring-boot-cli-2_2_6;
  spring-boot-cli-2_2_7 = springBootCliPkgs.spring-boot-cli-2_2_7;
  spring-boot-cli-2_4_1 = springBootCliPkgs.spring-boot-cli-2_4_1;

  stm32cubemx-4_27_0 = callPackage ./pkgs/stm32cubemx {};
}

