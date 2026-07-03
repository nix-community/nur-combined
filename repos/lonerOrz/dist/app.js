/* ─────────────────────────────────────────────────────────────────────────────
   loneros-nur · app.js
   Particle background + package table with search, sort, and animations
───────────────────────────────────────────────────────────────────────────── */

// ── Particle System ──────────────────────────────────────────────────────────

const canvas = document.getElementById("particles-canvas");
const ctx = canvas.getContext("2d");

let particles = [];
let connections = [];
let animFrame;
let particlesPaused = false;
let mouse = { x: -9999, y: -9999 };

const PARTICLE_COUNT = 70;
const CONNECTION_DIST = 140;
const MOUSE_REPEL_DIST = 120;
const COLORS = [
  [88, 166, 255],   // blue
  [126, 231, 135],  // green
  [188, 140, 255],  // purple
];

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
  const color = COLORS[Math.floor(Math.random() * COLORS.length)];
  return {
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    vx: (Math.random() - 0.5) * 0.18,
    vy: (Math.random() - 0.5) * 0.18,
    size: Math.random() * 1.8 + 0.4,
    alpha: Math.random() * 0.35 + 0.08,
    color,
    pulse: Math.random() * Math.PI * 2,
    pulseSpeed: 0.012 + Math.random() * 0.012,
  };
}

function initParticles() {
  resizeCanvas();
  particles = Array.from({ length: PARTICLE_COUNT }, createParticle);
}

function animateParticles() {
  if (particlesPaused) {
    animFrame = requestAnimationFrame(animateParticles);
    return;
  }

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // Update and draw particles
  particles.forEach((p) => {
    p.pulse += p.pulseSpeed;
    const pAlpha = p.alpha + Math.sin(p.pulse) * 0.06;

    // Mouse repulsion
    const dx = p.x - mouse.x;
    const dy = p.y - mouse.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    if (dist < MOUSE_REPEL_DIST && dist > 0) {
      const force = (1 - dist / MOUSE_REPEL_DIST) * 0.4;
      p.vx += (dx / dist) * force * 0.05;
      p.vy += (dy / dist) * force * 0.05;
    }

    // Dampen velocity
    p.vx *= 0.998;
    p.vy *= 0.998;

    p.x += p.vx;
    p.y += p.vy;

    // Wrap edges
    if (p.x < -10) p.x = canvas.width + 10;
    if (p.x > canvas.width + 10) p.x = -10;
    if (p.y < -10) p.y = canvas.height + 10;
    if (p.y > canvas.height + 10) p.y = -10;

    ctx.beginPath();
    ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
    ctx.fillStyle = `rgba(${p.color[0]}, ${p.color[1]}, ${p.color[2]}, ${pAlpha})`;
    ctx.fill();
  });

  // Draw connections
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const a = particles[i];
      const b = particles[j];
      const dx = a.x - b.x;
      const dy = a.y - b.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < CONNECTION_DIST) {
        const alpha = (1 - dist / CONNECTION_DIST) * 0.12;
        // Blend the two particle colors
        const r = Math.round((a.color[0] + b.color[0]) / 2);
        const g = Math.round((a.color[1] + b.color[1]) / 2);
        const bv = Math.round((a.color[2] + b.color[2]) / 2);

        ctx.beginPath();
        ctx.moveTo(a.x, a.y);
        ctx.lineTo(b.x, b.y);
        ctx.strokeStyle = `rgba(${r}, ${g}, ${bv}, ${alpha})`;
        ctx.lineWidth = 0.8;
        ctx.stroke();
      }
    }
  }

  animFrame = requestAnimationFrame(animateParticles);
}

initParticles();
animateParticles();

window.addEventListener("resize", debounce(() => {
  resizeCanvas();
  initParticles();
}, 200));

document.addEventListener("visibilitychange", () => {
  particlesPaused = document.hidden;
});

document.addEventListener("mousemove", (e) => {
  mouse.x = e.clientX;
  mouse.y = e.clientY;
});

document.addEventListener("mouseleave", () => {
  mouse.x = -9999;
  mouse.y = -9999;
});

// ── Data Loading ─────────────────────────────────────────────────────────────

async function loadPackages() {
  const tbody = document.getElementById("packages-body");

  const loadingRow = document.createElement("tr");
  loadingRow.id = "loading-row";
  loadingRow.innerHTML =
    `<td colspan="6" style="text-align:center;padding:60px 0;border:none">
       <div class="spinner"></div>
       <div style="margin-top:18px;color:var(--muted);font-size:13px;letter-spacing:0.04em">Loading packages…</div>
     </td>`;
  tbody.appendChild(loadingRow);

  try {
    const response = await fetch("./packages.json");

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();
    document.getElementById("loading-row")?.remove();
    return data;
  } catch (err) {
    document.getElementById("loading-row")?.remove();
    console.error("Failed to load packages:", err);

    const empty = document.getElementById("empty-state");
    empty.style.display = "block";
    empty.textContent = "Failed to load packages.json";
    return [];
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

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
    const original = btn.innerHTML;
    btn.innerHTML = `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"></polyline></svg> Copied!`;
    btn.style.cssText = "background:rgba(63,185,80,0.28);border-color:rgba(63,185,80,0.6);color:#56d364;";
    setTimeout(() => {
      btn.innerHTML = original;
      btn.style.cssText = "";
    }, 1600);
  }).catch(() => {
    /* clipboard API unavailable */
  });
}

function normalizeLicense(license) {
  if (!license) return "unknown";
  if (typeof license === "string") return license;
  if (Array.isArray(license)) return license.map(normalizeLicense).join(", ");
  return license.shortName || license.spdxId || license.fullName || "unknown";
}

// ── Render ────────────────────────────────────────────────────────────────────

function renderTable(packages) {
  const tbody = document.getElementById("packages-body");

  tbody.innerHTML = packages
    .map(
      (pkg, i) => `
        <tr style="animation-delay:${Math.min(i * 22, 400)}ms">
          <td data-label="Package">
            <code>${escapeHtml(pkg.name)}</code>
          </td>

          <td data-label="Version" class="version">${escapeHtml(pkg.version || "—")}</td>

          <td data-label="License">
            <span class="license-badge">${escapeHtml(normalizeLicense(pkg.license))}</span>
          </td>

          <td data-label="Description" class="description">${escapeHtml(pkg.description || "")}</td>

          <td data-label="Usage">
            <button
              class="install-btn"
              onclick="copyToClipboard('${escapeHtml(getInstallCommand(pkg.name))}', this)"
              title="Copy install command"
              id="copy-btn-${escapeHtml(pkg.name)}"
            >
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
              </svg>
              nix run
            </button>
          </td>

          <td data-label="Links">
            ${
              pkg.homepage
                ? `<a href="${escapeHtml(pkg.homepage)}" target="_blank" rel="noopener" class="homepage-link">Homepage</a>`
                : `<span style="color:var(--muted);font-size:12px">—</span>`
            }
          </td>
        </tr>
      `,
    )
    .join("");

  // Animate counter
  animateCounter(
    document.getElementById("package-count"),
    packages.length,
  );

  document.getElementById("empty-state").style.display =
    packages.length === 0 ? "block" : "none";
}

function animateCounter(el, target) {
  const duration = 500;
  const start = performance.now();
  const from = parseInt(el.textContent) || 0;

  function tick(now) {
    const t = Math.min((now - start) / duration, 1);
    const eased = 1 - Math.pow(1 - t, 3);
    el.textContent = Math.round(from + (target - from) * eased);
    if (t < 1) requestAnimationFrame(tick);
  }

  requestAnimationFrame(tick);
}

// ── Main ──────────────────────────────────────────────────────────────────────

async function main() {
  const packages = await loadPackages();

  let filteredPackages = [...packages];

  let sortState = { key: "name", direction: 1 };

  function sortPackages(key, direction) {
    sortState = { key, direction };

    document.querySelectorAll("th[data-sort]").forEach((th) => {
      th.classList.remove("sorted");
      const indicator = th.querySelector(".sort-indicator");
      if (indicator) indicator.textContent = "↕";
    });

    const activeTh = document.querySelector(`th[data-sort="${key}"]`);
    if (activeTh) {
      activeTh.classList.add("sorted");
      const indicator = activeTh.querySelector(".sort-indicator");
      if (indicator) indicator.textContent = direction === 1 ? "↑" : "↓";
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
    filteredPackages = packages.filter((pkg) =>
      [pkg.name, pkg.version, pkg.description, normalizeLicense(pkg.license)]
        .join(" ")
        .toLowerCase()
        .includes(q),
    );
    sortPackages(sortState.key, sortState.direction);
  }

  // Initial render
  sortPackages("name", 1);

  // Search
  const searchInput = document.getElementById("search-input");
  const debouncedFilter = debounce((value) => filterPackages(value), 120);
  searchInput.addEventListener("input", (e) => debouncedFilter(e.target.value));

  // Clear search on Escape
  searchInput.addEventListener("keydown", (e) => {
    if (e.key === "Escape") {
      searchInput.value = "";
      filterPackages("");
    }
  });

  // Column sort
  document.querySelectorAll("th[data-sort]").forEach((th) => {
    th.addEventListener("click", () => {
      const key = th.dataset.sort;
      const direction = sortState.key === key ? sortState.direction * -1 : 1;
      sortPackages(key, direction);
    });
  });

  // Keyboard shortcut: "/" to focus search
  document.addEventListener("keydown", (e) => {
    if (e.key === "/" && document.activeElement !== searchInput) {
      e.preventDefault();
      searchInput.focus();
    }
  });
}

main();
