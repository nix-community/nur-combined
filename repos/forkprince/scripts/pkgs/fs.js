const fs = require("fs/promises");

async function exists(dir) {
  try {
    await fs.access(dir);
    return true;
  } catch {
    return false;
  }
}

module.exports = {
  exists
}
