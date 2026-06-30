{
  sources,
  lib,
  amule,
}:
amule.overrideAttrs (old: {
  inherit (sources.amule-dlp) pname version src;
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
