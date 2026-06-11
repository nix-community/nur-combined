#!node
// To be used by pack-electron.sh
const fs = require('fs');
const crypto = require('crypto');

const manifest = require('../desktop-manifest.js');
const vanillaHash = manifest.browser_specific_settings.desktop_client.vanilla_hash;

const hash = crypto.createHash('sha1');
hash.setEncoding('hex');
hash.write(fs.readFileSync('app.asar'));
hash.end();
const actualHash = hash.read();

if (actualHash.toLowerCase() != vanillaHash.toLowerCase()) {
  console.error("TETR.IO app.asar hash does not match");
  console.error("TETR.IO Desktop was probably updated");
  console.log("Expected:", vanillaHash);
  console.log("Got:", actualHash);
  process.exit(1);
}

let main = fs.readFileSync('out/main.js');
let preload = fs.readFileSync('out/preload.js');

fs.writeFileSync(
  'out/main.js',
  fs.readFileSync('out/main.js', 'utf8').replace(
    /^/,
`const {
  onMainWindow,
  modifyWindowSettings,
  handleWindowOpen,
  tetrioPlusReady
} = require('./tetrioplus/source/electron/electron-main');
`
  ).replace(
    /(new BrowserWindow\()({[\S\s]+?})(\))/,
    '$1modifyWindowSettings($2)$3'
  ).replace(
    /(\S+\.loadFile\([^\)]+\))/g,
    'tetrioPlusReady.then(() => $1)'
  ).replace(
    /(if \(mainWindow)/g,
    '$1 && !handleWindowOpen(typeof url !== "undefined" ? url : (typeof arg !== "undefined" ? arg : null))'
  ).replace(
    /(mainWindow = win;)/,
    '$1 onMainWindow(mainWindow);'
  ).replace(
    'createWindow();', // TODO: check if still necessary
    // https://stackoverflow.com/a/53612021
    'setTimeout(() => createWindow(), 1000);'
  )
);

fs.writeFileSync(
  'out/preload.js',
  fs.readFileSync('out/preload.js', 'utf8') +
  "\nrequire('./tetrioplus/source/electron/preload');"
);
