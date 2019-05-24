self: super: {
  pythonOverrides = self.buildPythonOverrides (pyself: pysuper: {
    buildbot-plugins = pysuper.buildbot-plugins // {
      buildslist = self.python3PackagesPlus.buildbot-plugins.buildslist;
    };
    buildbot-full = pysuper.buildbot-full.withPlugins [ pyself.buildbot-plugins.buildslist ];
  }) super.pythonOverrides;
}
