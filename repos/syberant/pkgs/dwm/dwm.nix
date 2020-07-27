{
  dwm, git, lib,
  patches ? [], configh ? null,
}:

with lib;

# Overall layout of patching pipeline
# - master contains the original unpatched code
# - modified is the branch where all patches succesively get patched in.
# - tmp is a branch that can be used by a patcher to temporarily store a commit in and merge it later.

let patchCmds = {
  git = { file, ... }: ''
    git checkout -b tmp master

    git apply --3way -C1 --exclude="config.def.h" ${file}
    git add -A
    git commit -m "Applied with 3way patch ${file}"

    function resolve_conflict {
      # Accept both changes
      # NOTE: This can lead to problems when some code like "}" gets "shared" by multiple patches
      sed '/<<<<<<</ d ; />>>>>>>/ d ; /=======/ d' dwm.c > both
      mv both dwm.c
      git add -A
      git commit -m "Resolved conflicts caused by patch ${file}"
    }
    git checkout modified
    git merge tmp --commit || resolve_conflict

    git branch -d tmp
  '';
  patch = { file, fixupPatch ? null, ... }: ''
    git checkout modified

    git apply -C0 --exclude="config.def.h" ${file}
    ${lib.optionalString (fixupPatch != null) ''
        echo Applying fixup patch \"${fixupPatch}\"
        git apply -C0 ${fixupPatch}
      ''}
    git add -A
    git commit -m "Applied patch ${file}"
  '';
};
callPatcher = { type ? "patch", file, ... } @ attrs: ''
  echo
  echo "Patching using patch '${file}' and patcher '${type}'"
  ${patchCmds."${type}" attrs}
'';
patch = arg:
  callPatcher (if builtins.isPath arg || lib.isDerivation arg then { file = arg; } else arg);
in dwm.overrideAttrs (old: {
  nativeBuildInputs = [ git ];

  patchPhase = ''
    eval "$prePatch"

    git init
    git config user.email "noreply@example.com"
    git config user.name "Nix Automated Build"

    git add -A
    git commit -m "Original dwm code, unmodified"
    git branch modified
  '' + builtins.toString (builtins.map patch patches) + ''
    git checkout modified
    git log --graph

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
