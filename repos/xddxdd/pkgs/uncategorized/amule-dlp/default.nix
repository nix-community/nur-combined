{
  fetchFromGitHub,
  lib,
  amule,
}:
amule.overrideAttrs (old: {
  pname = "amule-dlp";
  version = "2.3.2-dlp";
  src = fetchFromGitHub {
    owner = "persmule";
    repo = "amule-dlp";
    rev = "7b3a07ab554d95267cca0c4a819b26d8474d6b3b";
    hash = "sha256-aZ+BjBNKHbHP44L7iOK9t1n/4l4U+R/pZYfTSBjFOA4=";
  };
  patches = [ ];

  cmakeFlags = (old.cmakeFlags or [ ]) ++ [
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    "-DENABLE_BOOST=FALSE"
  ];

  postPatch = (old.postPatch or "") + ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail '${"\${CMAKE_COMMAND}"}' '${"\${CMAKE_COMMAND}"} -DCMAKE_POLICY_VERSION_MINIMUM=3.5'
    sed -i 's/if (ENABLE_BOOST)/find_package (Threads REQUIRED)\nif (ENABLE_BOOST)/' CMakeLists.txt
  '';

  meta = old.meta // {
    mainProgram = "amule";
    maintainers = with lib.maintainers; [ xddxdd ];
    homepage = "https://github.com/persmule/amule-dlp";
    description = old.meta.description + " (with Dynamic Leech Protection)";
  };
})
