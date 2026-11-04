{
  lib,
  newScope,
}:

lib.makeScope newScope (self: {
  amlogic = lib.makeScope self.newScope (import ./amlogic);
})
