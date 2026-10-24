{
  callPackage,
  cutefish-toolkit,
  icu,
  pcre2,
}:

(callPackage ../cutefish/mk.nix { }) {
  pname = "cutefish-text-editor";

  extraBuildInputs = [
    cutefish-toolkit
    icu
    pcre2
  ];

  meta = {
    description = "Plain-text editor for the Cutefish desktop";
    mainProgram = "cutefish-text-editor";
  };
}
