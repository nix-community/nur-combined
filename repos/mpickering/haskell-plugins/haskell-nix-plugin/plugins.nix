# Plugin definitions
hp # The Haskell package set we want to define the plugin set for
:
{ # The dump-core plugin outputs HTML of the core of a module.
  dump-core = { pluginPackage = hp.dump-core ;
                pluginName = "DumpCore";
                pluginOpts = (args: [args.outpath]); } ;
}
