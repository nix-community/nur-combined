use gpui::actions;

actions!(
    omnimux,
    [
        NewTab,
        CloseTab,
        FindInTerminal,
        ZoomIn,
        ZoomOut,
        ZoomReset,
        Copy,
        Paste,
        CloseOverlay,
        NextTab,
        PrevTab,
        HostListUp,
        HostListDown,
        SearchNext,
        SearchPrev,
    ]
);
