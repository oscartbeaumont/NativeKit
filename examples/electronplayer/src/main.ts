import menuGenerator from './menu';
import services from './services';

var mainWindow: (BrowserWindow | null);

// TODO:
// - Esc to close fullscreen or green maximised -> Built into NativeKit
// - NativeKit default handlers (Hide, Quit, Copy, Paste, Cmd+A)
// - Picture in picture support -> Inject Pipifier extention maybe
// - Frameless window, etc
// - Transparent Window

// Create and show broswer window
function createWindow() {
  // Create window
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    center: true,
    title: "[BETA] ElectronPlayer",
    rightClickDevtools: true
  });

  // Create and display menu
  var menu = Menu.buildFromTemplate(menuGenerator(mainWindow))
  Menu.setApplicationMenu(menu);

  // Open menu interface and send services to display
  mainWindow.loadFile("interface/index.html");
  mainWindow.on('ready', () => {
    if (mainWindow !== null) mainWindow.emit("services", JSON.stringify(services()).toString())
  });

  // Handle window change event
  mainWindow.on('open-url', (url: String) => {
    console.log("Changing to url", url)
    if (mainWindow !== null) mainWindow.loadURL(url);
  });

  mainWindow.on('closed', () => mainWindow = null)
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
  // On macOS it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') app.quit()
})

// TODO: mainWindow should go null when closed
app.on('activate', () => {
  if (mainWindow === null) createWindow()
})