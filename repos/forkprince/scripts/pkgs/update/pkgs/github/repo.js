const { check } = require("../../../github");
const getHash = require("../../../hash");
const update = require("../../../file");

module.exports = async (file, { config, force }) => {
  const { version } = await check(file, { config, force });
  if (!version) return;

  const prefix = config.source.tag_prefix || "";
  const repo = config.source.repo;

  const url = `https://github.com/${repo}/archive/${prefix}${version}.tar.gz`;

  console.log(`Downloading ${url}`);

  const hash = await getHash(url, true);

  await update.single(file, { version, hash });

  console.log(`Updated to version ${version}`);
}
