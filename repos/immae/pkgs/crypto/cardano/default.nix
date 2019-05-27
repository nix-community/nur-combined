{ runCommand, mylibs }:
runCommand "empty" { preferLocalBuild = true; } "mkdir -p $out"
