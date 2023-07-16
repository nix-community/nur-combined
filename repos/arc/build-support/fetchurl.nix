{ self, super, lib, ... }: let
  builders = {
    # A replacement for pkgs.fetchurl that uses the builtin if possible
    # because fetchurl is a derivation that calls into curl and that makes nix sad :(
    nixFetchurl = { lib, path, fetchurl }: with lib; let
      nix-fetchurl = builtins.tryEval (import <nix/fetchurl.nix>);
      notAllowed = [
        "postFetch" "downloadToTemp" "netrcPhase" "curlOpts" "showURLs"
      ];
      allowed = attrNames (functionArgs (nix-fetchurl.value));
      allowedUnused = [
        "urls" "meta" "passthru" "preferLocalBuild" "recursiveHash"
      ];
      unusedWarn = args: let
        unused = removeAttrs args (allowed ++ allowedUnused);
        in if unused != {}
          then builtins.trace "WARN: fetchurl unused attributes ${toString (attrNames unused)}" args
          else args;
      needsNixpkgs = args: any (k: args ? ${k}) notAllowed;
      /*needWarn = args: let
        needed = filter (k: args ? ${k}) notAllowed;
      in builtins.trace "WARN: fetchurl doesn't support attrs ${toString needed} for ${args.name or args.url or "?"}" args;*/
      # handle mirror:// urls
      mirrors = import (path + "/pkgs/build-support/fetchurl/mirrors.nix");
      mirrorUrl = url: let
        m = builtins.match "mirror://([a-z]+)/(.*)" url;
      in if m != null
        then head (mirrors.${elemAt m 0}) + (elemAt m 1)
        else url;
      filterArgs = args: let
        url = if args ? urls && ! args ? url then head args.urls else args.url;
      in retainAttrs (unusedWarn args) allowed // {
        url = mirrorUrl url;
      } // optionalAttrs (!(args.showURLs or false || args ? name)) {
        name = strings.sanitizeDerivationName (baseNameOf url);
      } // optionalAttrs (args ? name) {
        name = strings.sanitizeDerivationName args.name;
      } // optionalAttrs (args ? recursiveHash) { unpack = args.recursiveHash; };
      nixFetchurl = { meta ? {}, passthru ? {}, ... }@args:
        if !nix-fetchurl.success || needsNixpkgs args
        then fetchurl args
        else extendDerivation true ({
          overrideAttrs = f: nixFetchurl (args // (f args));
          inherit meta passthru;
        } // passthru) (nix-fetchurl.value (filterArgs args));
    in nixFetchurl;
  };
in builders
