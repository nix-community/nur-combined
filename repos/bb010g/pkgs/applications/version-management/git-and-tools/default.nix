{ lib, newScope
, python3Packages, pythonPkgsScope
}:
lib.makeScope newScope (self: let inherit (self) callPackage; in

{
  git-my = callPackage ./git-my { };

  git-revise = (python3Packages.overrideScope' pythonPkgsScope).callPackage
    ./git-revise { };
})
