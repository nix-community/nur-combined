{ pkgs, ... }:
let
  inherit (pkgs.custom) colors;
  inherit (colors.colors) base00 base01 base02 base03 base04 base05 base06 base07 base08 base09 base0A base0B base0C base0D base0E base0F;
in {
  home.file."Downloads/theme.tdesktop-theme" = {
    source = pkgs.stdenv.mkDerivation {
      # borrowed from https://gitlab.com/theova/base16-telegram-desktop/-/blob/master/templates/default.mustache
      name = "base16.tdesktop-theme";
      nativeBuildInputs = with pkgs; [
        imagemagick
        zip
      ];
      dontUnpack = true;
      themeTemplate = ''
base00: #${base00};
base01: #${base01};
base02: #${base02};
base03: #${base03};
base04: #${base04};
base05: #${base05};
base06: #${base06};
base07: #${base07};
base08: #${base08};
base09: #${base09};
base0A: #${base0A};
base0B: #${base0B};
base0C: #${base0C};
base0D: #${base0D};
base0E: #${base0E};
base0F: #${base0F};

// base16 with transparency
base00T: #${base00}cc;
base01T: #${base01}cc;
base02T: #${base02}cc;
base03T: #${base03}cc;
base04T: #${base04}cc;
base05T: #${base05}cc;
base06T: #${base06}cc;
base07T: #${base07}cc;
base08T: #${base08}cc;
base09T: #${base09}cc;
base0AT: #${base0A}cc;
base0BT: #${base0B}cc;
base0CT: #${base0C}cc;
base0DT: #${base0D}cc;
base0ET: #${base0E}cc;
base0FT: #${base0F}cc;

// Color Pallete
pBg: base00;
pSelection: base02;
pFg: base05;
pComment: base03;
pCyan: base0C;
pGreen: base0B;
pOrange: base09;
pPink: base0E;
pPurple: base0D;
pRed: base08;
pYellow: base0A;
pAnthracite: base03;


// Color Vars
rippleBgHeavy: base00;
rippleBgLight: base01;
cBlack: base00;
cWhite: base05;
cTransparent: #00000000;

windowBg: pBg; // Main bg
windowFg: pFg; // Text color etc.
windowBgOver: pSelection; // Generic bg hover color (random bits and pieces) & Search bar bg
windowBgRipple: rippleBgLight; // Ripple color (on hover colored items) [te]
windowFgOver: windowFg; // Text color on hover
windowSubTextFg: pComment; // Minor text and some labels (version number, last seen, etc.)
windowSubTextFgOver: pPurple; // Hotkey hover text color?
windowBoldFg: pYellow; // Bolded text (headers) [te]
windowBoldFgOver: windowBoldFg; // windowBoldFg but on hover (idk where used)
windowBgActive: pGreen; // Checked radio and checkbox color
windowFgActive: pBg; // Button Text [te]
windowActiveTextFg: pCyan; // Hyperlink text color (and text input active labels)
windowShadowFg: #000000f0; // [te]
windowShadowFgFallback: cBlack; // [te]
shadowFg: cTransparent; // [te]
slideFadeOutBg: windowBg; // ???
slideFadeOutShadowFg: cTransparent; // ??? [te]
imageBg: cBlack; // ???
imageBgTransparent: cWhite; // ???
activeButtonBg: pComment; // Raised Button bg
activeButtonBgOver: pPurple;  // Raised Button hover bg
activeButtonBgRipple: rippleBgHeavy; // Raised Button ripple color (and slected chat contact ripple?)
activeButtonFg: windowBg; // Raised Button text color
activeButtonFgOver: activeButtonFg; // Raised Button hover text color
activeButtonSecondaryFg: pFg; // Numbers (badges) text color on raised buttons
activeButtonSecondaryFgOver: activeButtonSecondaryFg; // activeButtonSecondaryFg on hover
activeLineFg: windowActiveTextFg; // Active text input bottom border color
activeLineFgError: pRed; // activeLineFg but on error
lightButtonBg: windowBg; // Flat button bg color
lightButtonBgOver: pSelection; // Flat button bg color on hover
lightButtonBgRipple: rippleBgLight; // Flat button ripple color
lightButtonFg: pComment; // Flat button text color [te]
lightButtonFgOver: activeButtonBgOver; // Flat button text color on hover
attentionButtonFg: pRed; // Warning button text color
attentionButtonFgOver: attentionButtonFg; // Warning button text color hover
attentionButtonBgOver: base08T; // Warning button bg color hover !!(pRed with transparency)!! [te]
attentionButtonBgRipple: rippleBgLight; // Warning button ripple color
// Outline buttons are flat btns that get a little indicator when hovered
outlineButtonBg: windowBg; // Outline Button bg
outlineButtonBgOver: pSelection; // Outline Button bg on hover [te]
outlineButtonOutlineFg: windowActiveTextFg; // Outline Button indicator color
outlineButtonBgRipple: rippleBgLight;  // Outline Button ripple color
menuBg: windowBg; // Menu bg color
menuBgOver: windowBgOver; // Menu bg color on hover
menuBgRipple: windowBgRipple; // Icon ripple color
// Menu Icons are icons that appear popup windows
menuIconFg: pComment; // Menu Icon text color
menuIconFgOver: pPurple; // Menu Icon text color on hover
menuSubmenuArrowFg: pComment; // ???
menuFgDisabled: pSelection; // Disabled menu text color
menuSeparatorFg: base06T; // [te]
scrollBarBg: pComment; // Scroll Bar current slider color (indicator)
scrollBarBgOver: pPurple; // Scroll Bar current slider color on hover
scrollBg: pSelection; // Scroll Bar track bg color
scrollBgOver: scrollBg; // Scroll Bar track bg color on hover
smallCloseIconFg: pComment; // Small menu close button color (its tiny)
smallCloseIconFgOver: pRed; // smallCloseIconFg on hover [te]
radialFg: pPink; // ??? [te]
radialBg: pSelection; // ??? [te]
placeholderFg: pSelection; //windowSubTextFg; [te]
placeholderFgActive: pComment;
inputBorderFg: pComment; // Input text field undeline when not active
filterInputBorderFg: pComment; // Search box active border
checkboxFg: pComment; // checkbox inactive border [te]
sliderBgInactive: pSelection; // windowBgActive;
sliderBgActive: pGreen; // A slider is the bottom border on tabs that slides around
tooltipBg: base01T; // [te]
tooltipFg: pFg; // [te]
tooltipBorderFg: cTransparent; // [te]
titleBg: pBg; // Window top bar bg color
titleShadow: cTransparent;
titleButtonFg: pSelection; // [te]
titleButtonBgOver: cTransparent; // ??? [te]
titleButtonFgOver: pOrange; // ??? [te]
titleButtonCloseBgOver: cTransparent; // ??? [te]
titleButtonCloseFgOver: pRed; // ??? [te]
titleFgActive: pPurple; // Window Title color when active [te]
titleFg: pComment; // Window Title color
trayCounterBg: pRed; // Tray icon counter background for unread messages
trayCounterBgMute: pBg; // ??? [te]
trayCounterFg: pFg; // ??? [te]
trayCounterBgMacInvert: pComment; // ??? [te]
trayCounterFgMacInvert: pFg; // ??? [te]
layerBg: base01T; // bg overlay when menu is up [te]
cancelIconFg: menuIconFg; // Main close menu color (like option close)
cancelIconFgOver: pRed; // & on hover [te]
boxBg: windowBg;
boxTextFg: windowFg;
boxTextFgGood: pGreen;
boxTextFgError: pRed;
boxTitleFg: cWhite;
boxSearchBg: boxBg;
boxSearchCancelIconFg: cancelIconFg;
boxSearchCancelIconFgOver: cancelIconFgOver;
boxTitleAdditionalFg: pCyan; // [te]
boxTitleCloseFg: cancelIconFg;
boxTitleCloseFgOver: cancelIconFgOver;
membersAboutLimitFg: pRed; // [te]
contactsBg: windowBg; // Contact bg color on contacts page
contactsBgOver: windowBgOver;
contactsNameFg: pYellow; // Contact name color on contacts page [te]
contactsStatusFg: windowSubTextFg; // Contact status color on contacts page
contactsStatusFgOver: windowSubTextFgOver;
contactsStatusFgOnline: windowActiveTextFg;
photoCropFadeBg: layerBg;
photoCropPointFg: pComment;
introBg: windowBg;
introTitleFg: windowBoldFg;
introDescriptionFg: windowSubTextFg;
introErrorFg: pRed; // [te]
introCoverTopBg: pBg; // [te]
introCoverBottomBg: pBg; // [te]
introCoverIconsFg: pComment; // [te]
introCoverPlaneTrace: pCyan; // [te]
introCoverPlaneInner: pCyan; // [te]
introCoverPlaneOuter: pCyan; // [te]
introCoverPlaneTop: pCyan; // [te]
dialogsMenuIconFg: menuIconFg; // menu hamburger color
dialogsMenuIconFgOver: menuIconFgOver;
dialogsBg: windowBg;
dialogsNameFg: windowBoldFg; // Chat names color
dialogsChatIconFg: pOrange; // [te]
dialogsDateFg: windowSubTextFg;
dialogsTextFg: windowSubTextFg;
dialogsTextFgService: windowActiveTextFg;
dialogsDraftFg: pRed; // Draft label color
dialogsVerifiedIconBg: pCyan; // verified icon bg [te]
dialogsVerifiedIconFg: pBg; // verified icon text color [te]
dialogsSendingIconFg: pOrange; // ??? little clock icon on chat contact (the ones on left sidebar) when sending
dialogsSentIconFg: pGreen;
dialogsUnreadBg: pComment; // [te]
dialogsUnreadBgMuted: pSelection; // [te]
dialogsUnreadFg: pFg; // [te]
dialogsBgOver: windowBgOver;
dialogsNameFgOver: windowBoldFgOver;
dialogsChatIconFgOver: dialogsChatIconFg;
dialogsDateFgOver: windowSubTextFgOver;
dialogsTextFgOver: windowSubTextFgOver;
dialogsTextFgServiceOver: dialogsTextFgService;
dialogsDraftFgOver: dialogsDraftFg;
dialogsVerifiedIconBgOver: dialogsVerifiedIconBg;
dialogsVerifiedIconFgOver: dialogsVerifiedIconFg;
dialogsSendingIconFgOver: dialogsSendingIconFg;
dialogsSentIconFgOver: dialogsSentIconFg;
dialogsUnreadBgOver: dialogsUnreadBg;
dialogsUnreadBgMutedOver: dialogsUnreadBgMuted;
dialogsUnreadFgOver: dialogsUnreadFg;
dialogsBgActive: pSelection;
dialogsNameFgActive: pPink;
dialogsChatIconFgActive: pPurple;
dialogsDateFgActive: windowActiveTextFg;
dialogsTextFgActive: windowActiveTextFg;
dialogsTextFgServiceActive: pOrange; // [te]
dialogsDraftFgActive: dialogsDraftFg;
dialogsVerifiedIconBgActive: dialogsVerifiedIconBg;
dialogsVerifiedIconFgActive: dialogsVerifiedIconFg;
dialogsSendingIconFgActive: dialogsSendingIconFg;
dialogsSentIconFgActive: dialogsSentIconFg;
dialogsUnreadBgActive: dialogsUnreadBg;
dialogsUnreadBgMutedActive: dialogsUnreadBgMuted;
dialogsUnreadFgActive: dialogsUnreadFg;
dialogsForwardBg: dialogsBgActive;
dialogsForwardFg: pCyan; // [te]
searchedBarBg: pBg; // Results & 'no msgs found' msg in search results [te]
searchedBarBorder: cTransparent; // [te]
searchedBarFg: pPink; // Text 'Search for messages' in search results. [te]
topBarBg: windowBg;
emojiPanBg: windowBg; // Emoji window bg
emojiPanCategories: emojiPanBg;
emojiPanHeaderFg: windowSubTextFg;
emojiPanHeaderBg: emojiPanBg;
stickerPanDeleteBg: base08T; // [te]
stickerPanDeleteFg: pRed; // windowFgActive; [te]
stickerPreviewBg: cTransparent;
historyTextInFg: windowFg;
historyTextOutFg: windowFg;
historyCaptionInFg: historyTextInFg;
historyCaptionOutFg: historyTextOutFg;
historyFileNameInFg: historyTextInFg;
historyFileNameOutFg: historyTextOutFg;
historyOutIconFg: pGreen;
historyOutIconFgSelected: pGreen;
historyIconFgInverted: pGreen; // [te]
historySendingOutIconFg: pOrange; // [te]
historySendingInIconFg: pOrange; // [te]
historySendingInvertedIconFg: pOrange; // little 'eye' icon on some media msgs (ie sticker, image) to indicate views? [te]
historySystemBg: pYellow; // [te]
historySystemBgSelected: pOrange; // [te]
historySystemFg: pBg; // windowFgActive; [te]
historyUnreadBarBg: pSelection;
historyUnreadBarBorder: pSelection;
historyUnreadBarFg: cWhite;
historyForwardChooseBg: pComment;
historyForwardChooseFg: cWhite;
historyPeer1NameFg: pRed; // [te]
historyPeer1UserpicBg: pRed; // [te]
historyPeer2NameFg: pGreen; // [te]
historyPeer2UserpicBg: pGreen; // [te]
historyPeer3NameFg: pYellow; // [te]
historyPeer3UserpicBg: pYellow; // [te]
historyPeer4NameFg: pCyan; // [te]
historyPeer4UserpicBg: pCyan; // [te]
historyPeer5NameFg: pPurple; // [te]
historyPeer5UserpicBg: pPurple; // [te]
historyPeer6NameFg: pPink; // [te]
historyPeer6UserpicBg: pPink; // [te]
historyPeer7NameFg: pAnthracite; // [te]
historyPeer7UserpicBg: pAnthracite; // [te]
historyPeer8NameFg: pOrange; // [te]
historyPeer8UserpicBg: pOrange; // [te]
historyPeerUserpicFg: pBg; //  [te]
historyScrollBarBg: scrollBarBg;
historyScrollBarBgOver: scrollBarBgOver;
historyScrollBg: scrollBg;
historyScrollBgOver: scrollBgOver;
msgInBg: pComment;
msgInBgSelected: pPink;
msgOutBg: pSelection;
msgOutBgSelected: pPurple;
msgSelectOverlay: base01T;
msgStickerOverlay: rippleBgHeavy;
msgInServiceFg: windowActiveTextFg; // Chat name color when system message in (ie the computer... Forwarded by, Channels, etc)
msgInServiceFgSelected: windowActiveTextFg; // msgInServiceFg when selected
msgOutServiceFg: windowActiveTextFg; // msgInServiceFg but out instead
msgOutServiceFgSelected: windowActiveTextFg; // msgOutServiceFg when selected
msgInShadow: cTransparent;
msgInShadowSelected: cTransparent;
msgOutShadow: cTransparent;
msgOutShadowSelected: cTransparent;
msgInDateFg: base05; // Date in IN msg (text color) [ie time recieved] [te]
msgInDateFgSelected: base04; // msgInDateFG but when msg is selected [te]
msgOutDateFg: base05; // Date in OUT msg (text color) [ie time sent] [te]
msgOutDateFgSelected: base04; // msgOutDateFG but when msg is selected [te]
msgServiceFg: base01; // [te]
msgServiceBg: base0DT; // Sticker reply, dates in chat history, bot buttons [te]
msgServiceBgSelected: base0ET; // [te]
msgInReplyBarColor: activeLineFg;
msgInReplyBarSelColor: activeLineFg;
msgOutReplyBarColor: activeLineFg;
msgOutReplyBarSelColor: activeLineFg;
msgImgReplyBarColor: activeLineFg;
msgInMonoFg: pOrange; // [te]
msgOutMonoFg: pOrange; // [te]
msgDateImgFg: windowFg;
msgDateImgBg: windowBg;
msgDateImgBgOver: windowBgOver;
msgDateImgBgSelected: windowBgOver;
msgFileThumbLinkInFg: pYellow; // [te]
msgFileThumbLinkInFgSelected: pComment; // [te]
msgFileThumbLinkOutFg: pYellow; // [te]
msgFileThumbLinkOutFgSelected: pComment; // [te]
msgFileInBg: pPink; // [te]
msgFileInBgOver: pFg; // [te]
msgFileInBgSelected: pComment; // [te]
msgFileOutBg: base0D; // [te]
msgFileOutBgOver: pFg; // [te]
msgFileOutBgSelected: pSelection; //  [te]
msgFile1Bg: pCyan; // [te]
msgFile1BgDark: base0D; // [te]
msgFile1BgOver: base0D; // [te]
msgFile1BgSelected: base0D; // [te]
msgFile2Bg: pGreen; // [te]
msgFile2BgDark: base0B; // [te]
msgFile2BgOver: base0B; // [te]
msgFile2BgSelected: base0B; // [te]
msgFile3Bg: pRed; // [te]
msgFile3BgDark: base08; // [te]
msgFile3BgOver: base08; // [te]
msgFile3BgSelected: base08; // [te]
msgFile4Bg: pYellow; // [te]
msgFile4BgDark: base0A; // [te]
msgFile4BgOver: base0A; // [te]
msgFile4BgSelected: base0A; // [te]
msgWaveformInActive: pGreen; // Waveforms for audio messages (active is the played part)
msgWaveformInActiveSelected: pGreen;
msgWaveformInInactive: windowBg;
msgWaveformInInactiveSelected: windowBg;
msgWaveformOutActive: pGreen;
msgWaveformOutActiveSelected: pGreen;
msgWaveformOutInactive: windowBg;
msgWaveformOutInactiveSelected: windowBg;
msgBotKbOverBgAdd: rippleBgLight; // [te]
msgBotKbIconFg: pBg; //  [te]
msgBotKbRippleBg: activeButtonBgRipple; //menuBgRipple; // Bot (system) chat buttons [ie theme like/dislike]
mediaInFg: pOrange; // [te]
mediaInFgSelected: pOrange; // [te]
mediaOutFg: pOrange; // [te]
mediaOutFgSelected: pOrange; // [te]
youtubePlayIconBg: pRed;
youtubePlayIconFg: pFg;
videoPlayIconBg: pComment; // [te]
videoPlayIconFg: pFg; // [te]
toastBg: pComment; // [te]
toastFg: cWhite;
reportSpamBg: emojiPanHeaderBg;
reportSpamFg: windowFg;
historyToDownShadow: cTransparent;
historyComposeAreaBg: windowBg;
historyComposeAreaFg: historyTextInFg;
historyComposeAreaFgService: pFg; // [te]
historyComposeIconFg: menuIconFg; // Bottom chat icons (Attach File, Emoji, Microphone)
historyComposeIconFgOver: menuIconFgOver;
historySendIconFg: menuIconFg; // Paper plane icon that shows when text is typed (click to send)
historySendIconFgOver: pGreen; // [te]
historyPinnedBg: windowBg;
historyReplyBg: historyComposeAreaBg;
historyReplyCancelFg: cancelIconFg;
historyReplyCancelFgOver: pRed; // [te]
historyComposeButtonBg: historyComposeAreaBg;
historyComposeButtonBgOver: windowBgOver;
historyComposeButtonBgRipple: windowBgRipple;
overviewCheckBg: cTransparent; // [te]
overviewCheckFg: windowBg;
overviewCheckFgActive: windowBg;
overviewPhotoSelectOverlay: rippleBgHeavy; // [te]
profileStatusFgOver: pPurple;
notificationsBoxMonitorFg: windowFg;
notificationsBoxScreenBg: pSelection; // [te]
notificationSampleUserpicFg:  pCyan; // [te]
notificationSampleCloseFg: pRed; // [te]
notificationSampleTextFg: pFg; // [te]
notificationSampleNameFg: pYellow; // [te]
mainMenuBg: windowBg;
mainMenuCoverBg: pSelection; // [te]
mainMenuCoverFg:  pGreen; // [te]
mediaPlayerBg:  pBg; //  [te]
mediaPlayerActiveFg: pGreen; // [te]
mediaPlayerInactiveFg: pComment; // [te]
mediaPlayerDisabledFg: pSelection; // [te]
mediaviewFileBg: pSelection; //  [te]
mediaviewFileNameFg: windowFg;
mediaviewFileSizeFg: pOrange; //windowSubTextFg; [te]
mediaviewFileRedCornerFg: base08; // [te]
mediaviewFileYellowCornerFg: base0A; // [te]
mediaviewFileGreenCornerFg: base0B; // [te]
mediaviewFileBlueCornerFg: base0D; // [te]
mediaviewFileExtFg: pBg; // [te]
mediaviewMenuBg: pBg; // [te]
mediaviewMenuBgOver: pSelection; // [te]
mediaviewMenuBgRipple: rippleBgLight; // [te]
mediaviewMenuFg: pFg; // windowFgActive; [te]
mediaviewBg: base01T; // [te]
mediaviewVideoBg: imageBg;
mediaviewControlBg: pBg; //  [te]
mediaviewControlFg: pComment; // windowFgActive; [te]
mediaviewCaptionBg: pBg; //  [te]
mediaviewCaptionFg: cWhite;
mediaviewTextLinkFg: pCyan; // [te]
mediaviewSaveMsgBg: toastBg;
mediaviewSaveMsgFg: toastFg;
mediaviewPlaybackActive: pGreen; // [te]
mediaviewPlaybackInactive: pSelection; //windowSubTextFg; [te]
mediaviewPlaybackActiveOver: pGreen; // [te]
mediaviewPlaybackInactiveOver: pComment; //windowSubTextFgOver; [te]
mediaviewPlaybackProgressFg: pFg; // [te]
mediaviewPlaybackIconFg: pComment; // [te]
mediaviewPlaybackIconFgOver: mediaviewPlaybackActiveOver;
mediaviewTransparentBg: cBlack; // [te]
mediaviewTransparentFg: base03; // [te]
notificationBg: windowBg;
titleButtonBg: cTransparent; // [te]
titleButtonBgActive: cTransparent; // [te]
titleButtonBgActiveOver: pSelection; // [te]
titleButtonFgActiveOver: pOrange; // [te]
titleButtonFgActive: pOrange; // [te]
titleButtonCloseBg: cTransparent; // [te]
titleButtonCloseFg: pSelection; // [te]
titleButtonCloseBgActive: cTransparent; // [te]
titleButtonCloseFgActive: pRed; // [te]
titleButtonCloseBgActiveOver: pSelection; // [te]
titleButtonCloseFgActiveOver: titleButtonCloseFgOver;
filterInputInactiveBg: base01T; // [te]
profileVerifiedCheckBg: pCyan; // [te]
historyReplyIconFg: windowBgActive;
historyToDownBg: base01; // [te]
titleBgActive: pBg; //  [te]
      '';
      buildPhase = ''
        echo "$themeTemplate" > colors.tdesktop-theme
        convert -size 1x1 xc:"#${base00}" background.png
      '';
      installPhase = ''
        zip "$out" colors.tdesktop-theme background.png
      '';
    };
  };
}
