const oldSvgPath =
  "M 12.99 16.5 L 9 20.5 l 3.99 4 v -3 H 20 v -2 H 12.99 v -3 z M 27 14.5 l -3.99 -4 v 3 H 16 v 2 h 7.01 v 3 L 27 14.5 z";

const mirror = {
  state: false,
  videoButton: null,
  shortButton: null,
  styleSheet: null,
  embedVideoButton() {
    const isNewUI = document.querySelector(".ytp-right-controls-left");
    if (isNewUI) {
      this.embedVideoButtonNew();
    } else {
      this.embedVideoButtonOld();
    }
  },
  embedVideoButtonOld() {
    mirror.videoButton = document.createElement("button");
    mirror.videoButton.classList.add("ytp-button");
    mirror.videoButton.style.height = "100%";
    mirror.videoButton.style.width = "56px";
    mirror.videoButton.title = "YT Mirror";
    mirror.videoButton.addEventListener("click", mirror.toggle);
    mirror.videoButton.innerHTML = `
    <svg height="100%" version="1.1" viewBox="0 0 36 36" width="100%" fill-opacity="1">
      <use class="ytp-svg-shadow" href="#ytp-mirror-button-path"></use>
      <path d="${oldSvgPath}" fill="${
      mirror.state ? "#fbff12" : "white"
    }" id="ytp-mirror-button-path"></path>
    </svg>
    `;
    document.querySelector(".ytp-right-controls").prepend(mirror.videoButton);
  },
  embedVideoButtonNew() {
    mirror.videoButton = document.createElement("button");
    mirror.videoButton.classList.add("ytp-button");
    mirror.videoButton.title = "YT Mirror";
    mirror.videoButton.setAttribute("data-tooltip-title", "YT Mirror");
    mirror.videoButton.setAttribute("aria-expanded", "false");
    mirror.videoButton.setAttribute("aria-haspopup", "false");
    mirror.videoButton.addEventListener("click", mirror.toggle);
    mirror.videoButton.innerHTML = `
    <svg fill="none" height="24" viewBox="0 0 24 24" width="24">
      <path d="M5.32 10.1429L0 15.5714L5.32 21V16.9286H14.6667V14.2143H5.32V10.1429ZM24 7.42857L18.68 2V6.07143H9.33333V8.78571H18.68V12.8571L24 7.42857Z" fill="${
        mirror.state ? "#fbff12" : "white"
      }"></path>
    </svg>
    `;
    document
      .querySelector(".ytp-right-controls")
      .querySelector(".ytp-right-controls-left")
      .prepend(mirror.videoButton);
  },
  embedShortButton() {
    const navigationButton = document.createElement("div");
    navigationButton.classList.add(
      "navigation-button",
      "style-scope",
      "ytd-shorts"
    );
    navigationButton.style.position = "absolute";
    navigationButton.style.top = "unset";
    navigationButton.style.bottom = "30px";

    mirror.shortButton = document.createElement("button");
    mirror.shortButton.classList.add(
      "yt-spec-button-shape-next",
      "yt-spec-button-shape-next--tonal",
      "yt-spec-button-shape-next--mono",
      "yt-spec-button-shape-next--size-xl",
      "yt-spec-button-shape-next--icon-button"
    );
    mirror.shortButton.title = "YT Mirror";
    mirror.shortButton.addEventListener("click", mirror.toggle);
    mirror.shortButton.innerHTML = `
    <svg height="100%" version="1.1" viewBox="0 0 36 36" width="100%" fill-opacity="1">
      <use class="ytp-svg-shadow" href="#ytp-mirror-button-path"></use>
      <path d="M 12.99 16.5 L 9 20.5 l 3.99 4 v -3 H 20 v -2 H 12.99 v -3 z M 27 14.5 l -3.99 -4 v 3 H 16 v 2 h 7.01 v 3 L 27 14.5 z" fill="${
        mirror.state ? "#fbff12" : "#FFFFFF"
      }" id="ytp-mirror-button-path"></path>
    </svg>
    `;

    navigationButton.appendChild(mirror.shortButton);
    document.querySelector(".navigation-container").prepend(navigationButton);
  },
  changeButtonColor() {
    if (mirror.state) {
      if (mirror.videoButton)
        mirror.videoButton.querySelector("svg path").style.fill = "#FFFFFF";
      if (mirror.shortButton)
        mirror.shortButton.querySelector("svg path").style.fill = "#FFFFFF";
    } else {
      if (mirror.videoButton)
        mirror.videoButton.querySelector("svg path").style.fill = "#fbff12";
      if (mirror.shortButton)
        mirror.shortButton.querySelector("svg path").style.fill = "#fbff12";
    }
  },
  flipPlayer() {
    if (mirror.state) {
      document.head.removeChild(mirror.styleSheet);
    } else {
      let styles = `
        .html5-video-container {
          transform: rotateY(180deg);
        }
      `;
      mirror.styleSheet = document.createElement("style");
      mirror.styleSheet.type = "text/css";
      mirror.styleSheet.innerText = styles;
      document.head.appendChild(mirror.styleSheet);
    }
  },
  toggle() {
    mirror.changeButtonColor();
    mirror.flipPlayer();
    mirror.state = !mirror.state;
  },
};

window.addEventListener("yt-page-data-updated", checkWatchUrl);

function checkWatchUrl() {
  if (window.location.pathname == "/watch") {
    mirror.embedVideoButton();
    window.removeEventListener("yt-page-data-updated", checkWatchUrl);
  }
}

window.addEventListener("yt-page-data-updated", checkShortsUrl);

function checkShortsUrl() {
  if (window.location.pathname.includes("/shorts/")) {
    mirror.embedShortButton();
    window.removeEventListener("yt-page-data-updated", checkShortsUrl);
  }
}
