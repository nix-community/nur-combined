const { app, BrowserWindow, Menu } = require("electron");
const path = require("path");

app.setName("degrees-of-lewdity");

const createWindow = () => {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    autoHideMenuBar: true,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      sandbox: true,
    },
  });
  Menu.setApplicationMenu(null);
  win.loadFile(path.join(__dirname, "index.html"));
};

app.whenReady().then(createWindow);
app.on("window-all-closed", () => {
  app.quit();
});
