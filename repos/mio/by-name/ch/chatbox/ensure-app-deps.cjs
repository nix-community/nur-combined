// beforePack would run `npm ci` on the network; the nested app's runtime deps
// are already installed offline in buildPhase.
const path = require("path");
const { verifyInstalledRuntimeDeps } = require("./runtime-deps.cjs");

exports.default = async function ensureAppDeps() {
  verifyInstalledRuntimeDeps(path.join(__dirname, "..", "..", "release", "app"));
};
