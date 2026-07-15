const { Terminal } = require('xterm');
const { Unicode11Addon } = require('xterm-addon-unicode11');

const term = new Terminal();
const addon = new Unicode11Addon();
term.loadAddon(addon);
try {
  term.unicode.activeVersion = '11';
  console.log("Success");
} catch (e) {
  console.error("Error:", e);
}
