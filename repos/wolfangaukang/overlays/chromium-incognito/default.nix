self: super:
{
   chromium = super.chromium.override {
     commandLineArgs = "--incognito";
   };
}
