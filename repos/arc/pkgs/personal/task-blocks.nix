{ stdenvNoCC, fetchFromGitHub, makeWrapper, taskwarrior, jq }: with stdenvNoCC.lib; let
  package = stdenvNoCC.mkDerivation rec {
    name = "task-blocks";

    src = fetchFromGitHub {
      owner = "arcnmx";
      repo = name;
      rev = "189d6fc94647b7c8cab509a785edcf5bf7763f31";
      sha256 = "0yw5313q5jg5bpxkvsk6jdhlx2fahm039aawlrx3f4sq88lz5qqn";
    };

    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ taskwarrior jq ];

    makeFlags = ["TASKDATA=$(out)"];

    taskHooks = [ "on-exit" "on-add" "on-modify" ];
    wrapperPath = makeBinPath buildInputs;
    preFixupPhases = ["wrapInstall"];
    wrapInstall = ''
      for f in $taskHooks; do
        wrapProgram $out/hooks/$f.$name --prefix PATH : $wrapperPath
      done
    '';

    passthru = listToAttrs (map (hook: nameValuePair hook "${package}/hooks/${hook}.${name}") taskHooks);
  };
in package
