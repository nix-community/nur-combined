{lib}:
if lib.licenses ? WITH
then lib.licenses.WITH lib.licenses.agpl3Only lib.licenses.classpathException20
else
  lib.licenses.agpl3Only
  // {
    fullName = "GNU Affero General Public License v3.0 only with Classpath exception 2.0";
    spdxId = "AGPL-3.0-only WITH Classpath-exception-2.0";
    url = "https://tangled.org/okami.mom/albedo/blob/ff9d6dc0b83d4ee917f0e4b4dbf365a42684364d/LICENSE";
  }
