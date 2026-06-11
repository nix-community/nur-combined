/*
  This file is bootstrapped via manual changes made to the tetrio desktop client
  See the wiki on gitlab for instructions on performing these changes
  Not used on firefox
*/

const { app, BrowserWindow, protocol, ipcMain, dialog, webContents } = require('electron');
const crypto = require('crypto');
const https = require('https');
const path = require('path');
const fs = require('fs');

const manifest = require('../../desktop-manifest.js');

let getDataSourceForDomain; // loaded from sandbox below

let markTetrioPlusReady = null;
const tetrioPlusReady = new Promise(res => markTetrioPlusReady = res);

const Store = require('electron-store');
function storeGet(key) {
  if (!(/^[A-Za-z0-9\-_]+$/.test(key)))
    throw new Error("Invalid key: " + key);
  let val = new Store({
    name: 'tpkey-'+key,
    cwd: 'tetrioplus'
  }).get('value');
  return val;
}

const LEVELS = { verbose: 0, debug: 1, log: 2, warn: 3, error: 4, critical: 5 };
const LEVEL_NAMES = { verbose: 'VRB', debug: 'DBG', log: 'LOG', warn: 'WRN', error: 'ERR', critical: 'SEV' };
const LOGGERS = {
  'greenlog': { level: 'log', prefix: '\u001b[32m[TP $level $time] GL >' },
  'redlog':   { level: 'log', prefix: '\u001b[31m[TP $level $time] RL >' },
  'ipc':      { level: 'log', prefix: '\u001b[33m[TP $level $time] IPC>' }
}
const tplogger = (id, level, ...args) => {
  if (LEVELS[LOGGERS[id]?.level] > LEVELS[level]) return;

  let time = (new Date()).toISOString().split('T')[1].split('Z')[0];
  let prefix = LOGGERS[id].prefix
    .replace('$time', time)
    .replace('$level', LEVEL_NAMES[level]);
  console.log(prefix, ...args, "\u001b[37m");
}
const greenlog = (...args) => tplogger('greenlog', 'log', ...args);
const redlog = (...args) => tplogger('redlog', 'log', ...args);


const transparentBgEnabled = storeGet('transparentBgEnabled');
if (transparentBgEnabled) {
  // https://stackoverflow.com/a/53612021
  app.commandLine.appendSwitch('--enable-transparent-visuals');
  // doesn't seem to be necessary, but avoids startup delay, leaving it here for any future problems
  // app.commandLine.appendSwitch('--disable-gpu');
}
function modifyWindowSettings(settings) {
  // Needed to allow access to nodejs APIs like `require` for chaining our preload script and `fs`.
  // Why is this ridiculous sandbox even a thing? preload.js is already isolated >:C
  // https://www.electronjs.org/docs/latest/tutorial/sandbox#configuring-the-sandbox
  settings.webPreferences.sandbox = false;

  if (transparentBgEnabled) {
    settings.frame = false;
    settings.transparent = true;
    // This also seems to be necessary "sometimes", but I haven't really discovered
    // what those times are yet. leaving it here but disabled just in case.
    // https://www.electronjs.org/docs/latest/tutorial/window-customization#create-transparent-windows
    // settings.resizable = false;
    settings.backgroundColor = '#00000000';

    mainWindow.then(val => {
      // Mac workaround
      // Issue: https://github.com/electron/electron/issues/20357
      setInterval(() => {
        try {
          val.setBackgroundColor('#00FFFFFF');
        } catch(ex) {
          // lol whatever
        }
      }, 1000);
    });
  }

  greenlog("window settings", JSON.stringify(settings));

  return settings;
}

const mainWindow = new Promise(res => {
  module.exports = {
    // Used by packaging edits (see README)
    onMainWindow: res,
    modifyWindowSettings,
    handleWindowOpen,
    tetrioPlusReady
  }
});

// Called by many places from `main.js`, notably just before navigation from 'open-url' and 'second-instance' events.
// Also called by some other places which typically pass null.
// Returning true from this function aborts the call site's operation.
function handleWindowOpen(url) {
  if (url == null) return false;
  let root = 'tetrio://tetrioplus/tpse/';
  if (url.startsWith(root)) {
    let tpse = url.substring(root.length);
    let target = `https://tetr.io/?useContentPack=` + tpse;
    redlog('Opening', target);
    mainWindow.then(win => {
      win.webContents.loadURL(target)
    });
    return true;
  }
  return false;
}

for (let arg of process.argv)
  if (arg.startsWith('tetrio://'))
    handleWindowOpen(arg);

let tpWindow = null;
async function createTetrioPlusWindow() {
  if (tpWindow) return;
  tpWindow = new BrowserWindow({
    width: 432,
    height: 600,
    webPreferences: {
      // needed to allow access to node APIs like `fs`
      sandbox: false,
      // this is the default, but it doesn't hurt to specify
      nodeIntegration: false,
      // needed for `electron-browser-polyfill` to set `window.browser`
      contextIsolation: false,
      preload: path.join(app.getAppPath(), 'tetrioplus/source/electron/electron-browser-polyfill.js')
    }
  });
  tpWindow.loadURL(`tetrio-plus-internal://source/popup/index.html`);
  greenlog("TETR.IO PLUS window opened");
  setupWindowIpcChannelBroadcasting(tpWindow);
  tpWindow.on('closed', () => {
    greenlog("TETR.IO PLUS window closed");
    tpWindow = null;
  });
  let mainWin = await mainWindow;
  mainWin.on('closed', () => {
    greenlog("Main window closed");
    if (tpWindow) tpWindow.close();
  });
  mainWin.webContents.on('did-finish-load', () => {
    if (tpWindow && tpWindow.webContents)
      tpWindow.webContents.send('client-navigated', mainWin.getURL())
  });
}

function showError(title, ...lines) {
  dialog.showMessageBoxSync(null, {
    type: 'error',
    title: title,
    message: lines.join('\n')
  });
}

// Discord Rich Presence
ipcMain.on('presence', async (e, arg) => {
  let mainWin = await mainWindow;
  if (mainWin) {
    mainWin.setTitle('TETR.IO'); // this will conflict if tetrio ever decides to switch the title itself. oh well
    if (arg.state && storeGet('windowTitleStatus')) mainWin.setTitle(`TETR.IO - ${arg.state}`);
  }
});

// A brief summary of how the TETR.IO <-> Music Graph IPC works:
// There's no automated disconnect event when no connection is made in the first
// place, so when TETR.IO doesn't recieve a protocol-level acknowledgement, it
// continually attempts to reconnect.
// Window reload/close will automatically fire actual disconnect events once
// either side has started 'listening' which is announced from the browser api
// polyfill when onMessage.addListener is called.
// TETR.IO also manually closes the channel when it reloads the music graph,
// then restarts connection attempts afterwards.

let windows = new Set();
let channels = new Map(); // webContents id -> { nonce }[]
function addChannel(windowId, nonce) {
  let subchannels = channels.get(windowId);
  if (subchannels.some(channel => channel.nonce == nonce))
    return;
  subchannels.push({ nonce });
}
function setupWindowIpcChannelBroadcasting(window) {
  tplogger('ipc', 'log', "Set up window", window.webContents.id);
  const webContents = window.webContents;
  const id = window.webContents.id;
  windows.add(webContents);
  channels.set(id, []);

  window.webContents.on('did-start-navigation', (_, url, isInPlace, isMainFrame) => {
    if (isInPlace || !isMainFrame) return;
    tplogger('ipc', 'log', `Window ${id} started navigation (${url})`);
    for (let channel of channels.get(id).splice(0)) {
      tplogger('ipc', 'log', 'killing channel', channel.nonce);
      ipcBroadcast(window.webContents.id, 'tetrio-plus-close-channel', channel.nonce);
    }
  });
  window.on('closed', () => {
    tplogger('ipc', 'log', `Window ${id} closed`);
    windows.delete(webContents);
    for (let channel of channels.get(id).splice(0))
      ipcBroadcast(id, 'tetrio-plus-close-channel', channel.nonce);
    channels.delete(id);
  });
}
mainWindow.then(window => setupWindowIpcChannelBroadcasting(window));
function ipcBroadcast(excludeId, channel, ...args) {
  tplogger('ipc', 'verbose', `ipc broadcast`, channel, ...args);
  for (let window of windows) {
    if (excludeId == window.id) continue;
    window.send(channel, ...args);
  }
}

// Rebroadcast channels for implementing the browser.runtime.connect API
ipcMain.on('tetrio-plus-listening-on-channel', async (evt, nonce) => {
  tplogger('ipc', 'debug', "Window", evt.sender.id, "listening on channel", nonce);
  // indicates this sender is listening on this channel and that it
  // should be automatically closed when its not doing that anymore.
  addChannel(evt.sender.id, nonce);
})
ipcMain.on('tetrio-plus-create-channel', async (evt, nonce, ...args) => {
  tplogger('ipc', 'debug', "Window", evt.sender.id, "created channel", nonce);
  // this sender *created* this channel, so close it when its gone.
  addChannel(evt.sender.id, nonce);
  ipcBroadcast(null, 'tetrio-plus-create-channel', nonce, ...args);
});
ipcMain.on('tetrio-plus-close-channel', async (evt, nonce, ...args) => {
  tplogger('ipc', 'debug', "Window", evt.sender.id, "closed channel", nonce);
  // this channel was closed by a sender or a reciever
  for (let [key, subchannels] of channels.entries())
    channels.set(key, subchannels.filter(channel => channel.nonce != nonce));
  // channel close messages shouldn't be rebroadcasted to the original window
  // because it causes issues with the music graph event broadcaster when it
  // closes itself (since having loopbacks differs from Firefox)
  // OTOH loopbacks are required for content-script-communicator.js since that
  // lives in the same window as everything using it, but it doesn't care about
  // disconnections so its safe to do this. (Also there'll never be a memory
  // leak since the TETR.IO window can't be reopened).
  // This may cause ISSUES in the future
  ipcBroadcast(evt.sender.id, 'tetrio-plus-close-channel', nonce, ...args);
});
ipcMain.on('tetrio-plus-channel-message', async (evt, nonce, ...args) => {
  ipcBroadcast(null, 'tetrio-plus-channel-message', nonce, ...args);
});



ipcMain.on('tetrio-plus-cmd', async (evt, arg, arg2) => {
  switch(arg) {
    case 'uninstall':
      try {
        const asarPath = app.getAppPath();
        if (path.basename(asarPath) !== 'app.asar') {
          throw new Error(
            'App path isn\'t an asar file. Are you running tetrio unpacked?\n' +
            'Path: ' + asarPath
          );
        }

        const vanillaPath = path.join(asarPath, 'app.asar.vanilla');
        greenlog("Vanilla asar path: " + vanillaPath);
        const vanillaAppAsar = fs.readFileSync(vanillaPath);

        const hash = crypto.createHash('sha1');
        hash.setEncoding('hex');
        hash.write(vanillaAppAsar);
        hash.end();

        const targetHash = manifest
          .browser_specific_settings
          .desktop_client
          .vanilla_hash;
        const actualHash = hash.read();
        if (actualHash.toLowerCase() !== targetHash.toLowerCase()) {
          throw new Error(
            'Hash mismatch.' +
            '\nStored app.asar.vanilla hash: ' + actualHash +
            '\nExpected hash: ' + targetHash
          );
        }

        greenlog("Installing", vanillaAppAsar);
        require('original-fs').writeFileSync(asarPath, vanillaAppAsar);
        app.relaunch();
        app.exit();
      } catch(ex) {
        dialog.showMessageBoxSync(null, {
          type: 'error',
          title: 'Uninstall TETR.IO PLUS',
          message: ex.toString()
        });
        greenlog("Uninstall error:", ex);
      }
      break;

    case 'get-cwd':
      evt.returnValue = app.getPath('userData');
      break;

    case 'tetrio-plus-open-browser-window':
      tplogger('ipc', 'log', 'Open browser window: ' + JSON.stringify(arg2));
      let panel = new BrowserWindow({
        width: arg2.width,
        height: arg2.height,
        webPreferences: {
          // needed to allow access to node APIs like `fs` for the electron browser polyfill
          sandbox: false,
          nodeIntegration: false,
          // needed for `electron-browser-polyfill` to set `window.browser`
          contextIsolation: false,
          preload: path.join(__dirname, 'electron-browser-polyfill.js')
        }
      });
      setupWindowIpcChannelBroadcasting(panel);
      panel.loadURL(arg2.url);
      panel.on('closed', () => {
        if (tpWindow) tpWindow.reload();
      });
      break;

    case 'destroy everything':
      BrowserWindow.getAllWindows().forEach(window => window.destroy());
      process.exit();
      break;

    case 'create tetrio plus window':
      createTetrioPlusWindow();
      break;

    case 'super force reload':
      (await mainWindow).webContents.reloadIgnoringCache()
      break;

    case 'reset location':
      (await mainWindow).loadURL(`https://tetr.io/`);
      break;
  }
})

if (protocol) {
  protocol.registerSchemesAsPrivileged([{
    scheme: 'tetrio-plus',
    privileges: {
      secure: true,
      supportFetchAPI: true,
      bypassCSP: true,
      corsEnabled: true
    }
  }, {
    scheme: 'tetrio-plus-internal',
    privileges: {
      secure: true,
      supportFetchAPI: true,
      corsEnabled: true
    }
  }]);
}

function matchesGlob(glob, string) {
  return new RegExp(
    '^' +
    glob
      .split('*')
      .map(seg => seg.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'))
      .join('.*') +
    '$'
  ).test(string);
}

// https://stackoverflow.com/a/53786254
// remove so we can register each time as we run the app.
app.removeAsDefaultProtocolClient('tetrio-plus');
// If we are running a non-packaged version of the app && on windows
if(process.env.NODE_ENV === 'development' && process.platform === 'win32') {
  // Set the path of electron.exe and your app.
  // These two additional parameters are only available on windows.
  app.setAsDefaultProtocolClient('tetrio-plus', process.execPath, [path.resolve(process.argv[0])]);
} else {
  app.setAsDefaultProtocolClient('tetrio-plus');
}

app.whenReady().then(initialize).catch(greenlog);
async function initialize() {
  greenlog("starting primarily tetrio plus initialization");
  let rewriteHandlers = [];
  protocol.registerBufferProtocol('tetrio-plus', (req, callback) => {
    (async () => {
      greenlog("tetrio plus request", req.method, req.url);
      const originalUrl = 'https://tetr.io/' + req.url.substring('tetrio-plus://tetrio-plus/'.length);
      const bypassed = null != new URL(originalUrl).searchParams.get('bypass-tetrio-plus');
      // query params break some stuffs (why? what stuff?) ((possibly some filters not expecting url parameters?))
      const url = originalUrl.split('?')[0];

      let contentType = null;
      let data = null;

      // Used to fetch data from the source (https://tetr.io/) later on
      // if data isn't already provided internally.
      async function fetchData() {
        greenlog("Fetching data", originalUrl);

        function fetchDirect() {
          return new Promise((resolve, reject) => {
            greenlog("fetch ", originalUrl);
            https.get(originalUrl, { headers: req.headers }, response => {
              contentType = response.headers['content-type'];
              greenlog("http response ", contentType);
              let raw = [];

              let utf8 = !/^(image|audio|application\/rsd)/.test(contentType);
              if (utf8) response.setEncoding('utf8');

              response.on('data', chunk => raw.push(chunk))
              response.on('end', async () => {
                let joined = typeof raw[0] == 'string'
                  ? raw.join('')
                  : Buffer.concat(raw);
                let cloudflare = (
                  contentType.startsWith('text/html') && (
                    // old cloudflare captcha page, left in just in case
                    joined.includes("Please verify you're not a bot") ||
                    // new cloudflare captcha page
                    joined.includes("needs to review the security of your connection before proceeding")
                  )
                );

                if (cloudflare) {
                  redlog(`Received Cloudflare interstitial`);
                  fetchIPC().then(data => resolve(data));
                } else {
                  if (response.headers['content-length']) {
                    let byteLength = typeof joined == 'string'
                      ? (new TextEncoder().encode(joined)).length
                      : joined.length;
                    if (byteLength < +response.headers['content-length']) {
                      redlog(
                        "Response length is shorter than Content-Length header, possibly truncated: " +
                        `${byteLength} < ${response.headers['content-length']}`
                      );
                    }
                  }

                  resolve(joined);
                }
              });
            }).on('error', error => {
              redlog("Failed to fetch ", originalUrl, ": ", error);
              reject(error);
            });
          });
        }

        async function fetchDirectWithRetries() {
          for (let i = 0; i < 5; i++) {
            try {
              return await fetchDirect();
            } catch(ex) {
              let delay = i * 2000 + 500;
              redlog(`Retrying fetch in ${delay}ms (retry ${i+1} of 5)`);
              await new Promise(res => setTimeout(res, delay));
            }
          }
          return await fetchDirect();
        }

        async function fetchIPC() {
          greenlog(`Fetching`, originalUrl, `via ipc...`);
          let url = new URL(originalUrl);
          url.searchParams.set('bypass-tetrio-plus', true);
          let file = url.pathname + url.search;
          (await mainWindow).webContents.send('renderspace-fetch-file', file);
          return await new Promise(resolve => {
            ipcMain.once(
              `renderspace-fetch-file-result-${file}`,
              (_evt, filecontents) => {
                if (filecontents instanceof ArrayBuffer)
                  filecontents = Buffer.from(filecontents);
                resolve(filecontents)
              }
            );
          })
        }

        data = storeGet('forceIPCFetch') ? await fetchIPC() : await fetchDirectWithRetries();
        greenlog("Fetched", typeof data, data?.slice(0, 100)?.replace?.(/[^a-zA-Z0-9!@#$%^&*\(\)_=,./{}\[\]`~'";:\|\\\-+]/g, '_') ?? data);
      }

      function filterCallback(response) {
        let { type, data: newData, encoding } = response;
        if (type) contentType = type;

        switch(encoding || 'text') {
          case 'text':
            data = newData;
            break;

          case 'base64-data-url':
            data = Buffer.from(newData.split('base64,')[1], 'base64');
            greenlog("Rewrote b64 data url to", data);
            break;
            
          case 'arraybuffer':
            data = Buffer.from(newData, 0, newData.byteLength);
            greenlog("packing", newData, "into buffer", data);
            break;

          default:
            throw new Error('Unknown encoding');
        }
      };

      const dataSource = await getDataSourceForDomain(originalUrl);

      let handlers = rewriteHandlers.filter(handler => {
        if (bypassed) return false;
        return matchesGlob(handler.url, url) || matchesGlob(handler.url, originalUrl);
      });

      greenlog("Num handlers:", handlers.length)

      for (let handler of handlers) {
        greenlog("Testing handler", handler.name);

        if (!await handler.options.enabledFor(dataSource, originalUrl)) {
          greenlog("Not enabled!");
          continue;
        }

        if (handler.options.onStart) {
          greenlog("Start-handling it!", handler.name);
          // If data is a Buffer, it has a 'buffer' property which is an
          // Uint8Array-like. Offer that for browser compatibility.
          await handler.options.onStart(
            dataSource,
            originalUrl,
            (data && data.buffer) || data,
            filterCallback
          );
        }

        if (handler.options.onStop) {
          // 'onStart' is run before data is fetched in the browser, so data
          // isn't fetched until an onStop is ran. If a handler ran before that,
          // there'll already be generated data, so no need to fetch from source.
          if (!data) await fetchData();
          greenlog("Stop-handling it!", handler.name);
          await handler.options.onStop(
            dataSource,
            originalUrl,
            data.buffer || data,
            filterCallback
          );
        }
      }

      // If there's no handlers at all, no data will have been fetched
      // Fetch it now if that's the case
      if (!data) await fetchData();
      let finalWrite = typeof data == 'string'
        ? Buffer.from(data, 'utf8')
        : data;
      greenlog("Writing data", contentType, typeof data)//, finalWrite);
      callback({
        data: finalWrite,
        mimeType: contentType
      });
      greenlog("Wrote data!");
    })().catch(greenlog);
  });
  protocol.registerFileProtocol('tetrio-plus-internal', (req, callback) => {
    // greenlog("tetrio plus internal request", req.method, req.url);
    // greenlog(filepath);
    let relpath = req.url.substring('tetrio-plus-internal://'.length).split('?')[0];
    let filepath = path.join(__dirname, '../..', relpath);
    callback({ path: filepath });
  });
  
  // TETR.IO PLUS loads scripts with the expectation that they'll be evaluated in a shared context.
  // This expectation was originally inherited from the way web extension background scripts work.
  // This used to be implemented via `vm.runInContext(...)` with a large set of polyfills, but was
  // reimplemented as a simple eval for scoping benefits (no need to pass in every single api anymore)
  // and proper debugging (vm messes with the chrome debugger pretty hard).
  
  // remaining polyfills, used in various scripts
  greenlog("waiting for tetrio main window creation");
  const electronMainWindow = await mainWindow;
  greenlog("tetrio main window creation complete");
  const image_size = require('image-size');
  const browser = require('./electron-browser-polyfill.js');
  
  greenlog("loading tetrio plus scripts");
  let megascript = [];
  megascript.push('(async function() {')
  for (let script of manifest.browser_specific_settings.desktop_client.scripts) {
    greenlog("js: " + script);
    let fullpath = path.join(__dirname, '../..', script);
    megascript.push(`// Script file: ${JSON.stringify(fullpath)}\n`);
    megascript.push(fs.readFileSync(fullpath, 'utf8'));
    megascript.push(';\n');
  }
  megascript.push('return { getDataSourceForDomain };');
  megascript.push("})();");
  greenlog("evaluating concatenated tetrio plus megascript");
  try {
    let res = await eval(megascript.join(''));
    getDataSourceForDomain = res.getDataSourceForDomain;
  } catch(ex) {
    redlog("error evaluating megascript: " + ex);
  }

  if (!storeGet('hideTetrioPlusOnStartup')) {
    createTetrioPlusWindow();
  }
  
  greenlog("done initializing custom protocols and running scripts, marking tetrioplus as ready");
  markTetrioPlusReady();

  if (storeGet('openDevtoolsOnStart')) {
    let mainContents = (await mainWindow).webContents;
    mainContents.on('dom-ready', async evt => {
      mainContents.openDevTools();
    });
  }
}
