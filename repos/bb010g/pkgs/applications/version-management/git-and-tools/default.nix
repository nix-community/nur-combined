{ newScope
# helpers
, lib
# other packages
, python3Packages
}:
lib.makeScope newScope (self: let inherit (self) callPackage; in

{
  git-my = callPackage ./git-my { };

  git-revise = python3Packages.callPackage ./git-revise { };

  # githooks = callPackage ./githooks { };
})
