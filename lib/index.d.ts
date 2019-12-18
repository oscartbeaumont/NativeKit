export interface BrowserWindowOptions {
    width?: Number;
    height?: Number;
    title?: String;
    url?: String;
    center?: Boolean;
    rightClickDevtools?: Boolean;
}

export declare type MenuTemplate = SubMenuTemplate[];

export type MenuItemType = "separator" | "checkbox" | "radio";

export interface MenuItem {
    state: Boolean;
}

export interface SubMenuTemplate {
    visible?: Boolean;
    type?: MenuItemType;
    label?: String;
    checked?: Boolean; // TODO: Only if type is checkbox or radio
    click?: (menuItem: MenuItem) => void
    accelerator?: String; // TODO: Better checking
    submenu?: MenuTemplate
    enabled?: Boolean;
}

export declare type MenuReference = any;

declare global {
    class BrowserWindow {
        width: Number;
        height: Number;
        x: Number;
        y: Number;
        title: String;
        url: String;

        constructor(options: BrowserWindowOptions);
        emit(event: String, info: any): void;
        on(event: String, handler: (info?: any) => void): void;
        close(): void;
        // destroy(): void;
        // focus(): void;
        // blur(): void;
        show(): void;
        hide(): void;
        maximize(): void;
        minimize(): void;
        // setBounds(): void;
        setSize(width: Number, height: Number): void;
        // setResizable(enabled: Boolean): void;
        // setMovable(enabled: Boolean): void;
        setAlwaysOnTop(enabled: Boolean): void;
        moveTop(): void;
        center(): void;
        setPosition(x: Number, y: Number): void;
        setTitle(title: String): void;
        loadURL(url: String): void;
        loadFile(path: String): void;
        reload(): void;
    }
    const app: {
        on(event: String, handler: (info?: any) => void): void;
        emit(event: String, info: any): void;
        quit(): void
    }
    const Menu: {
        buildFromTemplate(template: MenuTemplate): MenuReference
        setApplicationMenu(menu: MenuReference): void
    }
    const config: {
        set(key: String, value: any): void;
        emit(key: String): any;
        delete(key: String): void;
        clear(): void;
    }
}