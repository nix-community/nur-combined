{ pkgs ? import <nixpkgs> {} }:

let
  nur = pkgs.callPackage ./../.. {};
  inherit (nur) dnd;
in

with dnd.macroTools;

let
  exclaim = chant: mkTemplate {
    values = [
      "name=Arthur Exclaims!"
      "=${chant}"
    ];
  };
in mkMacros [
  (mkMacro {
    name = "Cantrips";
    actions = [
      (exclaim (mkSelect "Select a spell" {
        "Mending" = toString dnd.chants.mending;
        "Mage Hand" = toString dnd.chants.mageHand;
        "Poison Spray" = toString dnd.chants.poisonSpray;
        "Ray of Frost" = toString dnd.chants.rayOfFrost;
      }))
    ];
    showMacrobar = true;
  })
]
