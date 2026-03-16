{
  buildGoModule,
  go_latest,
}:

buildGoModule.override { go = go_latest; }
