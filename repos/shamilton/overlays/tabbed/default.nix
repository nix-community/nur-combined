self: super:
{
  tabbed = super.tabbed.override {
    patches = [ ./keys.patch ];
  };
}
