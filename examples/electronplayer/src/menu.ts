export default (mainWindow) => [
    {
        label: 'ElectronPlayer',
        submenu: [
            {
                label: '[BETA] ElectronPlayer',
                enabled: false

            },
            {
                label: 'Created By Oscar Beaumont',
                enabled: false

            },
            {
                label: 'Hide ElectronPlayer',
                accelerator: 'CmdOrCtrl+H',
                click: () => mainWindow.hide()
            },
            {
                label: 'Quit ElectronPlayer',
                accelerator: 'CmdOrCtrl+Q',
                click: () => app.quit()
            }
        ]
    }
    {
        label: 'Services',
        submenu: [
            {
                label: 'Home',
                accelerator: 'Cmd+~',
                click: () => mainWindow.loadFile("interface/index.html")
            },
        ]
    }
]