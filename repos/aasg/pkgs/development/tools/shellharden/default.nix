{ lib, callPackage, defaultCrateOverrides }:

(callPackage ./Cargo.nix { }).workspaceMembers.shellharden.build.override {
  crateOverrides = defaultCrateOverrides // {
    shellharden = attrs: {
      meta = with lib; {
        description = "The corrective bash syntax highlighter";
        homepage = "https://github.com/anordal/shellharden";
        license = licenses.mpl20;
        maintainers = with maintainers; [ AluisioASG ];
        platforms = platforms.all;
      };
    };
  };
}
