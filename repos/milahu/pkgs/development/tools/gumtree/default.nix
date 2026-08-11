# based on https://github.com/milahu/nur-packages/blob/master/pkgs/applications/blockchains/haveno/default.nix

{
  lib,
  fetchFromGitHub,
  gradle2nix,
  srcml,
  makeWrapper,
}:

gradle2nix.buildGradlePackage rec {
  pname = "gumtree";
  version = "4.0.0-beta4";

  src = fetchFromGitHub {
    owner = "GumTreeDiff";
    repo = "gumtree";
    rev = "v${version}";
    hash = "sha256-baBc3kLlJOHPhJ/5JcCAJyfN42zM0/Rc2d+v/MMgZDY=";
    fetchSubmodules = true;
  };

  # lockfile generated with
  /*
    git clone --depth=1 https://github.com/GumTreeDiff/gumtree
    cd gumtree
    nix-shell -p jre nur.repos.milahu.gradle2nix
    gradle2nix
  */
  lockFile = ./gradle.lock;

  nativeBuildInputs = [
    makeWrapper
  ];

  gradleBuildFlags = [
    # FIXME add missing dependency org.jacoco:org.jacoco.agent:0.8.13.
    /*
    > Task :core:test FAILED

    [Incubating] Problems report is available at: file:///build/source/build/reports/problems/problems-report.html

    FAILURE: Build failed with an exception.

    * What went wrong:
    Execution failed for task ':core:test'.
    > Could not resolve all files for configuration ':core:jacocoAgent'.
       > Could not find org.jacoco:org.jacoco.agent:0.8.13.
         Searched in the following locations:
           - file:/nix/store/mqrjyx9w236p7amk18mqz3afal7i77j1-gradle-maven-repo/org/jacoco/org.jacoco.agent/0.8.13/org.jacoco.agent-0.8.13.module
           - file:/nix/store/mqrjyx9w236p7amk18mqz3afal7i77j1-gradle-maven-repo/org/jacoco/org.jacoco.agent/0.8.13/org.jacoco.agent-0.8.13.pom
           - file:/nix/store/mqrjyx9w236p7amk18mqz3afal7i77j1-gradle-maven-repo/org/jacoco/org.jacoco.agent/0.8.13/org.jacoco.agent-0.8.13.jar
         Required by:
             project :core
    */
    "--exclude-task=:core:test"

    # FIXME Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0.
    #"--warning-mode" "all"

    # based on Makefile
    "build"
  ];

  # FIXME gumtree has no install target
  # https://github.com/GumTreeDiff/gumtree/issues/392
  /*
  gradleInstallFlags = [
    "installDist"
  ];
  */

  installPhase =
  # if true then "cp -r . $out" else # debug: install all files
  ''
    mkdir $out
    cp -r dist/build/install/gumtree/{bin,lib} $out
    rm $out/bin/gumtree.bat
    wrapProgram $out/bin/gumtree \
      --prefix PATH : ${lib.makeBinPath [ srcml ]}
  '';

  meta = {
    description = "syntax-aware diff tool";
    homepage = "https://github.com/GumTreeDiff/gumtree";
    changelog = "https://github.com/GumTreeDiff/gumtree/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gumtree";
    platforms = lib.platforms.all;
  };
}
