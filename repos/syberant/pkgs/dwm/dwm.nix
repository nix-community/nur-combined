{
  dwm, git, lib,
  patches ? [], configh ? null
}:

with lib;

dwm.overrideAttrs (old: {
  nativeBuildInputs = [ git ];

  patchPhase = ''
    eval "$prePatch"
  '' + builtins.toString (builtins.map (file: ''
    echo "Patching using patch ${file}"
    git apply -C0 --exclude="config.h" --exclude="config.def.h" ${file}
  '') patches) + ''
    eval "$postPatch"
  '';

  postPatch = optionalString (configh != null) ''
    echo "Using ${configh} as config.h"
    cp ${configh} config.h
  '' + ''
    echo "Rule is declared as follows, make sure your config.h matches!"
    printf "\n"
    sed -n '/const Layout \*lt\[2\];/,+100p ; /} Rule;/q' dwm.c | sed 1,3d
    printf "\n"
  '';
})
