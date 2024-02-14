{ lib }: {
  # Hacky but works
  isEncrypted = str: !lib.hasInfix " " str;
}
