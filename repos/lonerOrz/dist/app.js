const root = document.documentElement;
const themeToggle = document.getElementById("theme-toggle");
const themeColor = document.querySelector('meta[name="theme-color"]');

const applyTheme = (theme) => {
  root.dataset.theme = theme;
  themeColor.content = theme === "dark" ? "#0a0e17" : "#f7f9fc";
  themeToggle.setAttribute(
    "aria-label",
    theme === "dark" ? "Switch to light theme" : "Switch to dark theme",
  );
};

applyTheme(root.dataset.theme || "dark");

themeToggle.addEventListener("click", () => {
  const next = root.dataset.theme === "dark" ? "light" : "dark";
  applyTheme(next);
  refreshPalette();
  try {
    localStorage.setItem("theme", next);
  } catch {
    // Storage may be unavailable; the theme still applies for this session.
  }
});

const darkQuery = matchMedia("(prefers-color-scheme: dark)");
darkQuery.addEventListener("change", (e) => {
  try {
    if (localStorage.getItem("theme")) return;
  } catch {
    return;
  }
  applyTheme(e.matches ? "dark" : "light");
  refreshPalette();
});

const canvas = document.getElementById("particles");
const ctx = canvas.getContext("2d");
const particleColors = () =>
  ["--particle-a", "--particle-b"].map((name) =>
    getComputedStyle(root).getPropertyValue(name).trim(),
  );

const parseColor = (value) => {
  const parts = value.match(/[\d.]+/g) || [];
  return parts.slice(0, 3).map(Number);
};
const COUNT = 36;
const LINK_DIST = 120;
const REPEL_DIST = 100;

let particles = [];
let palette = [];
let pointer = { x: -1e4, y: -1e4 };
let paused = false;

function resize() {
  canvas.width = innerWidth;
  canvas.height = innerHeight;
}

function makeParticle() {
  return {
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    vx: (Math.random() - 0.5) * 0.14,
    vy: (Math.random() - 0.5) * 0.14,
    r: Math.random() * 1.2 + 0.6,
    a: Math.random() * 0.16 + 0.1,
    color: Math.floor(Math.random() * palette.length),
  };
}

function refreshPalette() {
  palette = particleColors().map(parseColor);
  for (const p of particles) {
    p.color = Math.floor(Math.random() * palette.length);
  }
}

function init() {
  resize();
  palette = particleColors().map(parseColor);
  particles = Array.from({ length: COUNT }, makeParticle);
}

function frame() {
  if (!paused) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    for (const p of particles) {
      const dx = p.x - pointer.x;
      const dy = p.y - pointer.y;
      const d = Math.hypot(dx, dy);
      if (d < REPEL_DIST && d > 0) {
        const f = (1 - d / REPEL_DIST) * 0.014;
        p.vx += (dx / d) * f;
        p.vy += (dy / d) * f;
      }
      p.vx *= 0.997;
      p.vy *= 0.997;
      p.x = (p.x + p.vx + canvas.width) % canvas.width;
      p.y = (p.y + p.vy + canvas.height) % canvas.height;

      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(${palette[p.color]},${p.a})`;
      ctx.fill();
    }

    for (let i = 0; i < particles.length; i++) {
      for (let j = i + 1; j < particles.length; j++) {
        const a = particles[i];
        const b = particles[j];
        const d = Math.hypot(a.x - b.x, a.y - b.y);
        if (d > LINK_DIST) continue;
        ctx.beginPath();
        ctx.moveTo(a.x, a.y);
        ctx.lineTo(b.x, b.y);
        ctx.strokeStyle = `rgba(${palette[a.color]},${(1 - d / LINK_DIST) * 0.07})`;
        ctx.lineWidth = 0.6;
        ctx.stroke();
      }
    }
  }
  requestAnimationFrame(frame);
}

init();
requestAnimationFrame(frame);

addEventListener("resize", () => {
  resize();
  init();
});

addEventListener("pointermove", (e) => {
  pointer.x = e.clientX;
  pointer.y = e.clientY;
});

addEventListener("pointerleave", () => {
  pointer = { x: -1e4, y: -1e4 };
});

document.addEventListener("visibilitychange", () => {
  paused = document.hidden;
});

const esc = (value) =>
  String(value).replace(
    /[&<>"']/g,
    (c) =>
      ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
      })[c],
  );

const licenseName = (license) => {
  if (!license) return "unknown";
  if (typeof license === "string") return license;
  if (Array.isArray(license)) return license.map(licenseName).join(", ");
  return license.shortName || license.spdxId || license.fullName || "unknown";
};

const toast = document.getElementById("copy-toast");
let toastTimer;

const showToast = (message, isError = false) => {
  clearTimeout(toastTimer);
  toast.textContent = message;
  toast.toggleAttribute("data-error", isError);
  toast.classList.add("visible");
  toastTimer = setTimeout(() => toast.classList.remove("visible"), 1800);
};

const copyCommand = async (name) => {
  const command = `nix run github:lonerOrz/loneros-nur#${name}`;
  try {
    await navigator.clipboard.writeText(command);
    showToast(`Copied ${name}`);
  } catch {
    showToast("Copy failed", true);
  }
};

const columns = [
  "Package",
  "Version",
  "License",
  "Description",
  "Usage",
  "Links",
];

function render(rows) {
  const body = document.getElementById("packages-body");
  body.innerHTML = rows
    .map((pkg) => {
      const cells = [
        `<code>${esc(pkg.name)}</code>`,
        `<span class="version">${esc(pkg.version || "—")}</span>`,
        `<span class="badge">${esc(licenseName(pkg.license))}</span>`,
        `<span class="description">${esc(pkg.description || "")}</span>`,
        `<button class="install" type="button" data-name="${esc(pkg.name)}">nix run</button>`,
        pkg.homepage
          ? `<a class="link" href="${esc(pkg.homepage)}" target="_blank" rel="noopener">Homepage</a>`
          : `<span class="description">—</span>`,
      ];
      return `<tr>${cells.map((c, i) => `<td data-label="${columns[i]}">${c}</td>`).join("")}</tr>`;
    })
    .join("");

  document.getElementById("empty-state").hidden = rows.length > 0;
  document.getElementById("package-count").textContent = rows.length;
}

async function main() {
  let all = [];
  let shown = [];
  let sortKey = "name";
  let ascending = true;

  try {
    const res = await fetch("./packages.json");
    if (!res.ok) throw new Error(String(res.status));
    all = await res.json();
  } catch {
    const empty = document.getElementById("empty-state");
    empty.hidden = false;
    empty.textContent =
      "Failed to load packages.json. Serve this directory over HTTP.";
    return;
  }

  const apply = () => {
    const query = document
      .getElementById("search-input")
      .value.toLowerCase()
      .trim();
    shown = all
      .filter((pkg) =>
        [pkg.name, pkg.version, pkg.description, licenseName(pkg.license)]
          .join(" ")
          .toLowerCase()
          .includes(query),
      )
      .sort((a, b) => {
        const av = String(a[sortKey] ?? "").toLowerCase();
        const bv = String(b[sortKey] ?? "").toLowerCase();
        return av.localeCompare(bv) * (ascending ? 1 : -1);
      });
    render(shown);
  };

  const headers = [...document.querySelectorAll("th[data-sort]")];
  for (const th of headers) {
    th.addEventListener("click", () => {
      const key = th.dataset.sort;
      ascending = key === sortKey ? !ascending : true;
      sortKey = key;
      for (const h of headers) {
        h.removeAttribute("aria-sort");
        h.querySelector(".sort-indicator").textContent = "↕";
      }
      th.setAttribute("aria-sort", ascending ? "ascending" : "descending");
      th.querySelector(".sort-indicator").textContent = ascending ? "↑" : "↓";
      apply();
    });
  }

  const input = document.getElementById("search-input");
  let timer;
  input.addEventListener("input", () => {
    clearTimeout(timer);
    timer = setTimeout(apply, 120);
  });
  input.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      input.value = "";
      apply();
    }
  });
  addEventListener("keydown", (e) => {
    if (e.key === "/" && e.target !== input) {
      e.preventDefault();
      input.focus();
    }
  });

  document.getElementById("packages-body").addEventListener("click", (e) => {
    const button = e.target.closest(".install");
    if (button) copyCommand(button.dataset.name);
  });

  headers[0].setAttribute("aria-sort", "ascending");
  headers[0].querySelector(".sort-indicator").textContent = "↑";
  apply();
}

main();
