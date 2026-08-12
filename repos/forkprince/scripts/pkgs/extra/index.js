const { Glob } = require("bun");

module.exports = async (file, { config }) => {
  const location = `${__dirname}/pkgs`;
  const glob = new Glob("*.js");

  for await (const script of glob.scan(location))
    await require(`${location}/${script}`)(file, { config });
};
