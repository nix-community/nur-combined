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
        /// Overrides gpui-component Tab (focus cycle) when a terminal is focused.
        PassthroughTab,
        /// Overrides gpui-component TabPrev (focus cycle) when a terminal is focused.
        PassthroughShiftTab,
    ]
);
