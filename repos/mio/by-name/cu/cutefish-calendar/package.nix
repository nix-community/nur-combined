{
  callPackage,
  cutefish-toolkit,
  icu,
  libical,
  curl,
}:

(callPackage ../cutefish/mk.nix { }) {
  pname = "cutefish-calendar";

  extraBuildInputs = [
    cutefish-toolkit
    icu
    libical
    curl
  ];

  meta = {
    description = "Calendar for the Cutefish desktop";
    mainProgram = "cutefish-calendar";
  };
}
