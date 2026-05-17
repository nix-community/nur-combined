const canvas = document.getElementById("particles-canvas");
const ctx = canvas.getContext("2d");

let particles = [];
let particlesPaused = false;

function debounce(fn, delay) {
  let timer = null;
  return function (...args) {
    clearTimeout(timer);
    timer = setTimeout(() => fn.apply(this, args), delay);
  };
}

function resizeCanvas() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}

function createParticle() {
  return {
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    vx: (Math.random() - 0.5) * 0.2,
    vy: (Math.random() - 0.5) * 0.2,
    size: Math.random() * 2 + 0.5,
    alpha: Math.random() * 0.4 + 0.1,
  };
}

function initParticles() {
  resizeCanvas();
  particles = Array(50).fill(null).map(createParticle);
}

function animateParticles() {
  if (particlesPaused) {
    requestAnimationFrame(animateParticles);
    return;
  }
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  particles.forEach((p) => {
    p.x += p.vx;
    p.y += p.vy;

    if (p.x < 0) p.x = canvas.width;
    if (p.x > canvas.width) p.x = 0;
    if (p.y < 0) p.y = canvas.height;
    if (p.y > canvas.height) p.y = 0;

    ctx.beginPath();
    ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
    ctx.fillStyle = `rgba(88, 166, 255, ${p.alpha})`;
    ctx.fill();
  });

  requestAnimationFrame(animateParticles);
}

initParticles();
animateParticles();
window.addEventListener("resize", resizeCanvas);
document.addEventListener("visibilitychange", () => {
  particlesPaused = document.hidden;
});

async function loadPackages() {
  const tbody = document.getElementById("packages-body");
  const loadingRow = document.createElement("tr");
  loadingRow.id = "loading-row";
  loadingRow.innerHTML =
    '<td colspan="6" style="text-align:center;padding:48px 0"><div class="spinner"></div><div style="margin-top:16px;color:var(--muted);font-size:14px">Loading packages...</div></td>';
  tbody.appendChild(loadingRow);

  try {
    const response = await fetch("./packages.json");

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();
    const lr = document.getElementById("loading-row");
    if (lr) lr.remove();
    return data;
  } catch (err) {
    const lr = document.getElementById("loading-row");
    if (lr) lr.remove();
    console.error("Failed to load packages:", err);

    const empty = document.getElementById("empty-state");

    empty.style.display = "block";

    empty.textContent = "Failed to load packages.json";

    return [];
  }
}

function escapeHtml(text) {
  return String(text)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function getInstallCommand(name) {
  return `nix run github:lonerOrz/loneros-nur#${name}`;
}

function copyToClipboard(text, btn) {
  navigator.clipboard.writeText(text).then(() => {
    const originalHTML = btn.innerHTML;
    btn.innerHTML = "Copied!";
    btn.style.background = "rgba(126, 231, 135, 0.3)";
    btn.style.borderColor = "#7ee787";
    setTimeout(() => {
      btn.innerHTML = originalHTML;
      btn.style.background = "";
      btn.style.borderColor = "";
    }, 1500);
  });
}

function normalizeLicense(license) {
  if (!license) {
    return "unknown";
  }

  if (typeof license === "string") {
    return license;
  }

  if (Array.isArray(license)) {
    return license.map(normalizeLicense).join(", ");
  }

  return license.shortName || license.spdxId || license.fullName || "unknown";
}

function renderTable(packages) {
  const tbody = document.getElementById("packages-body");

  tbody.innerHTML = packages
    .map(
      (pkg) => `
        <tr>
          <td data-label="Package">
            <code>${escapeHtml(pkg.name)}</code>
          </td>

          <td data-label="Version" class="version">${escapeHtml(pkg.version || "unknown")}</td>

          <td data-label="License">
            <span class="license-badge">${escapeHtml(normalizeLicense(pkg.license))}</span>
          </td>

          <td data-label="Description" class="description">${escapeHtml(pkg.description || "")}</td>

          <td data-label="Usage">
            <button
              class="install-btn"
              onclick="copyToClipboard('${escapeHtml(getInstallCommand(pkg.name))}', this)"
            >
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
              </svg>
              nix run
            </button>
          </td>

          <td data-label="Links">
            ${
              pkg.homepage
                ? `<a href="${escapeHtml(pkg.homepage)}" target="_blank" class="homepage-link">Homepage</a>`
                : ""
            }
          </td>
        </tr>
      `,
    )
    .join("");

  document.getElementById("package-count").textContent = packages.length;

  document.getElementById("empty-state").style.display =
    packages.length === 0 ? "block" : "none";
}

async function main() {
  const packages = await loadPackages();

  let filteredPackages = [...packages];

  let sortState = {
    key: "name",
    direction: 1,
  };

  function sortPackages(key, direction) {
    sortState = {
      key,
      direction,
    };

    document.querySelectorAll("th[data-sort]").forEach((th) => {
      th.classList.remove("sorted");
      const indicator = th.querySelector(".sort-indicator");
      if (indicator) {
        indicator.textContent = "↕";
      }
    });

    const activeTh = document.querySelector(`th[data-sort="${key}"]`);
    if (activeTh) {
      activeTh.classList.add("sorted");
      const indicator = activeTh.querySelector(".sort-indicator");
      if (indicator) {
        indicator.textContent = direction === 1 ? "↑" : "↓";
      }
    }

    filteredPackages.sort((a, b) => {
      const av = String(a[key] || "").toLowerCase();

      const bv = String(b[key] || "").toLowerCase();

      return av.localeCompare(bv) * direction;
    });

    renderTable(filteredPackages);
  }

  function filterPackages(query) {
    const q = query.toLowerCase().trim();

    filteredPackages = packages.filter((pkg) => {
      return [pkg.name, pkg.version, pkg.description]
        .join(" ")
        .toLowerCase()
        .includes(q);
    });

    sortPackages(sortState.key, sortState.direction);
  }

  // initial render
  sortPackages("name", 1);

  const searchInput = document.getElementById("search-input");

  const debouncedFilter = debounce((value) => filterPackages(value), 150);
  searchInput.addEventListener("input", (e) => {
    debouncedFilter(e.target.value);
  });

  document.querySelectorAll("th[data-sort]").forEach((th) => {
    th.addEventListener("click", () => {
      const key = th.dataset.sort;

      let direction = 1;

      if (sortState.key === key) {
        direction = sortState.direction * -1;
      }

      sortPackages(key, direction);
    });
  });
}

main();
