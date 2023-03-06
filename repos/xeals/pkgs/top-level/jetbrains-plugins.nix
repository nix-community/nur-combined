{ lib
, newScope
, stdenv
, fetchzip

, variant
}:

let

  mkJetbrainsPlugins = import ../applications/editors/jetbrains/common-plugins.nix {
    inherit lib stdenv fetchzip;
  };

  mkIdeaPlugins = import ../applications/editors/jetbrains/idea-plugins.nix {
    inherit lib stdenv fetchzip;
  };

  jetbrainsWithPlugins = import ../applications/editors/jetbrains/wrapper.nix {
    inherit lib;
  };

in
lib.makeScope newScope (self: lib.makeOverridable
  ({ jetbrainsPlugins ? mkJetbrainsPlugins self
   , ideaPlugins ? mkIdeaPlugins self
   }: ({ }
    // jetbrainsPlugins // { inherit jetbrainsPlugins; }
    // ideaPlugins // { inherit ideaPlugins; }
    // {
    inherit variant;
    jetbrainsWithPlugins = jetbrainsWithPlugins self variant;
  })
  )
{ })
