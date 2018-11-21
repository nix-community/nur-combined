This repository provides an overlay which adds support for running Haskell
plugins via nix.

There are three new elements to the nixpkgs API.

1. A new function `haskell.lib.addPlugin` which adds a plugin to a package.
2. A new attribute `haskell.plugins` which is parameterised by
a Haskell package set and contains a set of plugins.
3. A new `with*` function, `haskellPackages.withPlugin` which takes a function
  expecting two arguments, the first being a set of plugins for that package set
  and the second being a list of packages for that package set. The
  result of the function should be a Haskell package.

## Example

See `example.nix`:

```
let
  plugin-overlay-git = builtins.fetchGit
   { url = https://github.com/mpickering/haskell-nix-plugin.git;}  ;
  plugin-overlay = import "${plugin-overlay-git}/overlay.nix";
  nixpkgs = import <nixpkgs> { overlays = [plugin-overlay]; };

  hl = nixpkgs.haskell.lib;
  hp = nixpkgs.haskellPackages;
in
  (hp.withPlugin(plugs: ps: hl.addPlugin plugs.dump-core ps.either)).DumpCore
```

## The plugin set

The `haskell.plugins` attribute is a set of plugins parameterised by a normal
Haskell package set. It is designed in this manner so the same plugin definitions
can be used with different compilers.

```nix
hp:
{
dump-core = { ... };
graphmod-plugin = { ... };
}
```

Each attribute is a different plugin which we might want to use with our program.


## A plugin

A plugin is a Haskell package which provides the plugin with four additional
attributes which describe how to run it. For example, here is the definition
for the `dump-core` plugin.

```nix
dump-core = { pluginPackage = hp.dump-core ;
              pluginName = "DumpCore";
              pluginOpts = ({outpath, pkg}: [outpath]);
              pluginDepends = [];
              initPhase = _: "";
              finalPhase = _: "";
              } ;
```

`pluginPackage`
: The Haskell package which provides the plugin.

`pluginName`
: The module name where the plugin is defined.

`pluginOpts`
: Additional options to pass to the plugin. The path where it places its output
is passed as an argument.

`pluginDepends`
: Any additional system dependencies the plugin needs for the finalPhase.

`initPhase`
: An action to run in the `preBuild` phase, after the plugin has run. The standard
arguments are passed.

`finalPhase`
: An action to run in the `postBuild` phase, after the plugin has run. The standard
arguments are passed.

The standard arguments are the output path and the current package being
overriden with attributes `outpath` and `pkg`.

In most cases, `pluginDepends` and `finalPhase` can be omitted (they then take
these default values) but they are useful for when a plugin emits information
as it compiles each module which is then summarised at the end.

An example of this architecture is the [`graphmod-plugin`](https://github.com/mpickering/graphmod-plugin). As each module is
compiled, the import information is serialised. Then, at the end we read all
the serialised files and create a dot graph of the module import structure.
Here is how we specify the final phase of the plugin:

```nix
graphmod = { pluginPackage = hp.graphmod-plugin;
             pluginName = "GraphMod";
             pluginOpts = ({outpath,...}: ["${outpath}/output"]);
             pluginDepends = [ nixpkgs.graphviz ];
             finalPhase = {outpath,...}: ''
                graphmod-plugin --indir ${outpath}/output > ${outpath}/out.dot
                cat ${outpath}/out.dot | tred | dot -Tpdf > ${outpath}/modules.pdf
              ''; } ;
```

The first three fields are standard, however we now populate the final two
arguments as well. We firstly add a dependency on `graphviz` which we will
use to render the module graph and then specify the invocations needed
to firstly summarise and then render the information.

In this architecture, the plugin package provides a library interface which
exposes the plugin and an executable which is invoked to collect the information
output by the plugin. This is what the call to `graphmod-plugin` achieves.

## `withPlugin`

We also provide the `withPlugin` attribute which supplies both the
plugins and packages already applied to a specific package set. The reason
for this is that **a plugin and a package must be both compiled by the same
compiler**. Thus, unrestricted usage of `addPlugin` can lead to confusing errors
if the plugin and package are compiled with different compilers.
The `withPlugin` attribute ensures that the versions align
correctly.

```
core-either =
  haskellPackages.withPlugin
    (plugins: packages: addPlugin plugins.dump-core packages.either)
```

## How can I use it?

This infrastructure is provided as an overlay. Install the overlay as you would
normally, one suggested method can be see in the [`example.nix`](https://github.com/mpickering/haskell-nix-plugin/blob/master/example.nix) file.

```
let
  plugin-overlay-git = builtins.fetchGit
    { url = https://github.com/mpickering/haskell-nix-plugin.git;}  ;
  plugin-overlay = import "${plugin-overlay-git}/overlay.nix";
  nixpkgs = import <nixpkgs> { overlays = [plugin-overlay]; };
in ...
```

### Using NUR

The overlay is also distributed using [NUR](https://github.com/nix-community/NUR). Here is an example of how to use it:

```
overlay = (import <nixpkgs> {}).nur.repos.mpickering.overlays.haskell-plugins;
nixpkgs = import <nixpkgs> { overlays = [ overlay ]; };
```

