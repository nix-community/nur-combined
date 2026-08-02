// Adapted from the Electron tutorial:
// https://www.electronjs.org/docs/latest/tutorial/tutorial-first-app
// Boilerplate required to run the web application with Electron.

'use strict';

const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { app, BrowserWindow, net, protocol, shell } = require('electron');

// These placeholders are replaced with immutable Nix store paths at install time.
const gameDir = '@gameDir@';
// Keep browser storage independent of the changing Nix store path.
const gameOrigin = 'pokeclicker://game';

// Give the custom scheme normal web capabilities for relative URLs and fetches.
protocol.registerSchemesAsPrivileged([
  {
    scheme: 'pokeclicker',
    privileges: {
      standard: true,
      secure: true,
      supportFetchAPI: true,
      corsEnabled: true,
    },
  },
]);

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    // Use the website favicon for the native window decoration.
    icon: '@icon@',
  });

  // The website provides its own interface, so hide Electron's application menu.
  mainWindow.setMenuBarVisibility(false);
  // Send links requesting a new window to the system browser instead.
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith('https://') || url.startsWith('http://')) {
      shell.openExternal(url);
    }
    return { action: 'deny' };
  });
  // Load through the stable origin instead of a store path dependent file URL.
  mainWindow.loadURL(`${gameOrigin}/index.html`);
}

app.whenReady().then(() => {
  // Resolve custom scheme requests to immutable game files without allowing
  // paths to escape the packaged game directory.
  protocol.handle('pokeclicker', (request) => {
    const url = new URL(request.url);
    if (url.host !== 'game') {
      return new Response('Not found', { status: 404 });
    }

    const filePath = path.resolve(gameDir, `.${decodeURIComponent(url.pathname)}`);
    if (!filePath.startsWith(`${gameDir}${path.sep}`)) {
      return new Response('Not found', { status: 404 });
    }

    // Make missing optional resources behave like ordinary web-server 404s.
    return net.fetch(pathToFileURL(filePath).toString())
      .catch(() => new Response('Not found', { status: 404 }));
  });

  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

// This package supports Linux only, where closing all windows exits the app.
app.on('window-all-closed', () => {
  app.quit();
});
