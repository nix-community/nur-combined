{ pkgs, lib }:
let
  callPackage = pkgs.python3.pkgs.callPackage;
in
lib.makeScope pkgs.newScope (
  self: {
    darkdetect = callPackage ./darkdetect { };
    customtkinter = callPackage ./customtkinter { };
  }
)
