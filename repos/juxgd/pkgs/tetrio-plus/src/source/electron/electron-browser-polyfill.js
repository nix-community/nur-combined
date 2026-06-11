(() => {
  const electron = typeof window != 'undefined' && window?.process?.versions?.electron;
  const node = typeof module != 'undefined' && module.exports;
  if (electron || node) {
    console.log("[TETR.IO PLUS] Running under electron - polyfilling browser");

    const { promisify } = require('util');
    const electron = require('electron');
    const path = require('path');
    const fs = require('fs');
    const https = require('https');
    const os = require('os');

    // Only necessary in render process
    if (typeof window != 'undefined') {
      let appdir = electron.ipcRenderer.sendSync('tetrio-plus-cmd', 'get-cwd');
      electron.app = {
        getPath(path) {
          switch (path) {
            case 'userData': return appdir;
            default: throw new Error('unimplemented monkey patch');
          }
        }
      }
      // electron.ipcRenderer.on('tetrio-plus-channel-message', (...args) => {
      //   console.log('[TETR.IO PLUS] tetrio-plus-channel-message debug', ...args);
      // });
    }

    // provided by tetrio desktop
    const Store = require('electron-store');
    const keystore = new Store({
      name: 'key-index',
      cwd: 'tetrioplus',
      defaults: { keys: [] }
    });

    function createPort(nonce, name="") {
      const listeners = [];
      const port = {
        name,
        postMessage(...args) {
          electron.ipcRenderer.send('tetrio-plus-channel-message', nonce, ...args);
        },
        disconnect() {
          electron.ipcRenderer.send('tetrio-plus-close-channel', nonce);
        },
        onDisconnect: {
          addListener(listener) {
            let disconnected = false; // May fire multiple times, only want handler called once
            let wrappedlistener = (evt, msgnonce) => {
              // if (disconnected) return;
              disconnected = true;
              if (nonce != msgnonce) return;
              listener();
            };
            electron.ipcRenderer.on('tetrio-plus-close-channel', wrappedlistener);
            listeners.push(['tetrio-plus-close-channel', wrappedlistener]);
          }
        },
        onMessage: {
          addListener(listener) {
            // Jankyness warning: I don't know how firefox actually detects channel
            // closing, but assuming something is listening for messages on it
            // is probably close enough
            let wrappedlistener = (evt, msgnonce, ...args) => {
              if (nonce != msgnonce) return;
              listener(...args);
            };
            electron.ipcRenderer.on('tetrio-plus-channel-message', wrappedlistener);
            listeners.push(['tetrio-plus-channel-message', wrappedlistener]);
            electron.ipcRenderer.send('tetrio-plus-listening-on-channel', nonce);
          }
        }
      };
      port.onDisconnect.addListener(() => {
        setTimeout(() => {
          for (let [channel, handler] of listeners)
            electron.ipcRenderer.removeListener(channel, handler);
        });
      });
      return port;
    }

    const browser = {
      electron: true,
      management: {
        async uninstallSelf() {
          if (!confirm(
            "Are you sure you want to uninstall TETR.IO PLUS? " +
            "The application will quit after uninstalling."
          )) throw new Error('Uninstall cancelled');
          electron.ipcRenderer.send('tetrio-plus-cmd', 'uninstall');
        }
      },
      runtime: {
        getURL(relative) {
          let absolute = 'tetrio-plus-internal://' + relative;
          return absolute;
        },
        getManifest() {
          return require('../../desktop-manifest.js');
        },
        async getBrowserInfo() {
          return {
            name: 'TETR.IO Desktop',
            vendor: 'osk',
            version: '¯\\_(ツ)_/¯',
            buildId: '¯\\_(ツ)_/¯'
          }
        },
        onConnect: {
          addListener(callback) {
            electron.ipcRenderer.on('tetrio-plus-create-channel', (evt, nonce, name) => {
              callback(createPort(nonce, name));
            });
          }
        },
        connect(param) {
          let name = param?.name;
          const nonce = Math.floor(Math.random() * 1e15);
          electron.ipcRenderer.send('tetrio-plus-create-channel', nonce, name);
          return createPort(nonce);
        }
      },
      theme: {
        async getCurrent() {
          return null;
        },
        onUpdated: {
          addListener() { /* /dev/null */},
          removeListener() { /* /dev/null */ }
        }
      },
      extension: {
        getURL(relative) {
          return browser.runtime.getURL(relative);
        }
      },
      windows: {
        create({ _type, url, width, height }) {
          console.log('Sent open request', url, width, height);
          require('electron').ipcRenderer.send(
            'tetrio-plus-cmd',
            'tetrio-plus-open-browser-window',
            { url, width, height }
          );
        }
      },
      tabs: {
        create({ url, active }) {
          browser.windows.create({ type: null, url, width: 800, height: 800 });
        },
        openExternal(url) {
          console.log('Opening', url, 'externally');
          require('electron').shell.openExternal(url);
        },
        electronOnMainNavigate(callback) {
          require('electron').ipcRenderer.on('client-navigated', (event, url) => {
            callback(url);
          });
        },
        electronClearPack() {
          require('electron').ipcRenderer.send('tetrio-plus-cmd', 'reset location');
        }
      },
      storage: {
        local: {
          async get(keys) {
            if (typeof keys == 'string') keys = [keys];

            let values = {};
            for (let key of keys) {
              if (!(/^[A-Za-z0-9\-_]+$/.test(key)))
                throw new Error("Invalid key: " + key);
              values[key] = new Store({
                name: 'tpkey-' + key,
                cwd: 'tetrioplus'
              }).get('value');
            }

            // Prevent infinite loops in some users that don't expect
            // the promise to resolve syncronously
            await new Promise(r => setTimeout(r, 100));
            return values;
          },
          async set(vals) {
            for (let [key, value] of Object.entries(vals)) {
              if (!(/^[A-Za-z0-9\-_]+$/.test(key)))
                throw new Error("Invalid key: " + key);

              let keys = keystore.get('keys');
              if (keys.indexOf(key) == -1)
                keys.push(key);
              keystore.set({ keys });

              new Store({
                name: 'tpkey-' + key,
                cwd: 'tetrioplus'
              }).set({ value: value ?? null });
            }
          },
          async remove(keys) {
            if (typeof keys == 'string') keys = [keys];
            for (let key of keys) {
              if (!(/^[A-Za-z0-9\-_]+$/.test(key)))
                throw new Error("Invalid key: " + key);

              let keys = keystore.get('keys');
              if (keys.indexOf(key) !== -1)
                keys.splice(keys.indexOf(key), 1);
              keystore.set({ keys });

              let {path} = new Store({ name: 'tpkey-'+key, cwd: 'tetrioplus' });
              try {
                await promisify(fs.unlink)(path);
              } catch(ex) {
                console.warn("Failed to delete file: ", ex);
              }
            }
          },
          async clear() {
            await browser.storage.local.remove(keystore.get('keys'));
          }
        }
      },
      permissions: {
        async request() {
          return true;
        }
      },
      downloads: {
        async download({ filename, url }) {
          let data = new Uint8Array(await fetch(url).then(res => res.arrayBuffer()));
          let segments = ['Downloads', ...filename.split('/')];
          for (let i = 1; i < segments.length; i++) {
            let dir = path.join(os.homedir(), ...segments.slice(0, i));
            if (!fs.existsSync(dir)) {
              console.log('mkdir', dir);
              fs.mkdirSync(dir);
            }
          }
          console.log('saving file to ', path.join(os.homedir(), ...segments));
          fs.writeFileSync(path.join(os.homedir(), ...segments), data);
        }
      }
    };

    if (typeof module != 'undefined' && module.exports)
      module.exports = browser;
    if (typeof window != 'undefined') {
      window.browser = browser;
      window.openInBrowser = href => {
        electron.shell.openExternal(href);
      }
      window.fetchGitlabReleasesJson = async function() {
        const url = 'https://gitlab.com/UniQMG/tetrio-plus/-/releases.json';
        let text = await new Promise((res, rej) => https.get(url, response => {
          const chunks = [];
          response.on('data', chunk => chunks.push(chunk));
          response.on('end', () => {
            if (response.statusCode != 200) {
              rej('Unexpected status code: ' + response.statusCode);
              return;
            }
            res(chunks.join(''));
          });
          response.on('error', err => rej(err));
        }));
        return JSON.parse(text);
      }
      console.log("set up window", window);
    }
  }
})();
