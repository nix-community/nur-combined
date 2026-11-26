// Spotlight Interactive Showcase & Reveal Engine

const SIM_DATA = {
  calc: {
    query: '10 km to mi',
    rows: [
      { icon: '≈', title: '6.21371 mi', desc: '10 km → miles · Press Enter to copy', tag: 'Units' },
      { icon: 'ƒ', title: 'Calculator & Percentages', desc: 'Try: 25 * 48, sqrt(256), sin(pi/2), 100 USD to EUR', tag: 'Math' },
      { icon: '💱', title: 'Live Daily Currency (Frankfurter)', desc: 'Only currency codes sent · Amounts stay 100% local', tag: 'Currency' },
    ],
  },
  vault: {
    query: 'clip vault',
    rows: [
      { icon: '🔒', title: 'PROD_STRIPE_KEY=sk_live_••••••••8a9f', desc: 'Argon2id + XChaCha20-Poly1305 · Expires in 54m', tag: 'Encrypted' },
      { icon: '🖼', title: 'architecture-diagram-v2.png (412 KiB)', desc: 'Encrypted image pin · In-memory Paste Queue ready', tag: '41m left' },
      { icon: '📋', title: 'Start Paste Queue (3 pins)', desc: 'Press Ctrl+V repeatedly · Zero plaintext temp files', tag: 'Queue' },
    ],
  },
  workflow: {
    query: 'workflow run snap-translate',
    rows: [
      { icon: '⚡', title: '1. Screenshot → 2. OCR → 3. Translate → 4. Save Note', desc: 'Compiled binary .wasm · 0 host imports · 10k fuel budget', tag: 'WASM' },
      { icon: '🧩', title: 'Workflow Builder (No-Code Editor)', desc: 'Chain 1–12 typed actions visually · Save & Run', tag: 'Builder' },
      { icon: '📦', title: 'Extension Store (store)', desc: 'Install SHA-256 verified community WASM plugins', tag: 'Store' },
    ],
  },
  ai: {
    query: 'ai ask what should I work on next?',
    rows: [
      { icon: '🧠', title: 'Context-Aware Local AI (127.0.0.1 · NO_CLOUD=1)', desc: 'Includes Project: spotlight, 4 open windows, 3 todos', tag: 'Local Only' },
      { icon: '📝', title: 'ai summarize clipboard', desc: 'Summarizes clipboard text locally via verified Ollama', tag: 'Summary' },
      { icon: '👁', title: 'Review Exact Context Snapshot', desc: 'Nothing sent until you click Send locally', tag: 'Privacy' },
    ],
  },
  git: {
    query: 'git status',
    rows: [
      { icon: '🌿', title: 'spotlight (main) — 4 changes', desc: '~/Projects/spotlight · 2 modified, 1 staged, 1 untracked', tag: 'Dirty Repo' },
      { icon: '🐳', title: 'docker logs nginx-proxy', desc: 'Live-tail 200 lines + stream inside Spotlight', tag: 'Container' },
      { icon: '🌐', title: 'get https://api.github.com/user', desc: 'HTTP Scratch REST client · Pretty JSON · In-memory', tag: 'HTTP' },
    ],
  },
  pomodoro: {
    query: 'pomodoro 25m',
    rows: [
      { icon: '🍅', title: 'Start 25m Pomodoro Focus Session', desc: 'Auto-enables Caffeinate (Awake) · Survives restarts', tag: 'Focus' },
      { icon: '⏰', title: 'timer 5m  ·  alarm 7:30 am', desc: 'Persistent local timers and alarms with test sound', tag: 'Reminder' },
      { icon: '🪟', title: 'layout restore work', desc: 'Restores saved KDE KWin window positions across monitors', tag: 'KDE Layout' },
    ],
  },
  palette: {
    query: 'palette ~/Pictures/aurora-wallpaper.png',
    rows: [
      { icon: '🎨', title: '#62A0EA · #1E2436 · #38BDF8 · #A78BFA · #34D399', desc: '5 dominant colors extracted locally · Click to copy', tag: 'Palette' },
      { icon: '🗜', title: 'compress image 50%  ·  resize 1080p', desc: 'Saves quality-50 WebP while keeping original intact', tag: 'Image' },
      { icon: '🎵', title: 'music · pause · next track · play lofi', desc: 'Direct MPRIS player control over session D-Bus', tag: 'Music' },
    ],
  },
  event: {
    query: 'add event Dinner on July 13 2027 at 6pm',
    rows: [
      { icon: '📅', title: 'Dinner — Jul 13, 2027 at 18:00 (60m)', desc: 'Review form · Save to GNOME/Evolution or local iCal', tag: 'Calendar' },
      { icon: '🕒', title: 'meet in 2h  ·  meet in 30m for 45m', desc: 'Finds free slots from cached Akonadi calendars', tag: 'Free/Busy' },
      { icon: '📖', title: 'Built-in 103-Topic Guide (Press F1)', desc: 'Searchable walkthroughs, shortcuts, and live examples', tag: 'Guide' },
    ],
  },
};

const SCREENSHOTS = [
  {
    id: 'launcher',
    tab: 'Main Launcher',
    badge: 'Real GTK 4 Capture',
    img: 'images/spotlight.png',
    title: 'Instant, Clutter-Free Main Launcher',
    desc: 'Apps and commands stay front and center, while Search File and Recent stay pinned neatly below the search box. Hover or arrow-select with smooth accent-colored button glow.',
    bullets: [
      'Fuzzy app ranking with favorites (Ctrl+F) and usage memory',
      'Persistent Tab / Ctrl+K actions hint in the footer',
      'Zero Electron or GPU context overhead — native Rust + GTK 4 Cairo',
    ],
    cmds: ['Meta+Space', 'Tab / Ctrl+K', 'F1 Guide', 'Ctrl+, Settings'],
  },
  {
    id: 'files',
    tab: 'File Search',
    badge: 'Real GTK 4 Capture',
    img: 'images/spotlight-files.png',
    title: 'Dedicated File Search & Quick Actions',
    desc: 'Search File carries over text already typed in main search and indexes up to 25,000 home files lazily in a background thread with image thumbnails and ~/.spotlightignore support.',
    bullets: [
      'Press Tab on any file for Reveal in Dolphin, Copy Path, Open With, Info, or Trash',
      'Stream inside-file matches with ripgrep (rg rust, in: notes keyword)',
      'Recent view reads real XDG recently-used.xbel and KDE RecentDocuments',
    ],
    cmds: ['Search File', 'Recent', 'rg rust', 'in: notes TODO'],
  },
  {
    id: 'vault',
    tab: 'Clipboard Vault',
    badge: 'Argon2id + XChaCha20-Poly1305',
    img: 'images/spotlight-vault.png',
    title: 'Secure Clipboard Vault & Paste Queue',
    desc: 'Protect sensitive clipboard text and PNG images with a master password, automatic 1-hour pin expiry, sensitive clipboard metadata, and an ordered Paste Queue.',
    bullets: [
      'Authenticated encryption on disk (mode 0600) with zeroized in-memory keys',
      'Copied pins carry sensitive hints and auto-clear after 30 seconds',
      'Paste Queue streams over an in-memory pipe — zero plaintext temp files',
    ],
    cmds: ['vault', 'clip pinned', 'clip images', 'clip queue'],
  },
  {
    id: 'workflow',
    tab: 'WASM Workflows',
    badge: 'Visual No-Code Builder',
    img: 'images/spotlight-workflow.png',
    title: 'Visual No-Code WASM Workflow Builder',
    desc: 'Chain 1–12 typed actions visually — like Screenshot → OCR → Translate Locally → Save Note — and compile them into real, import-free binary WebAssembly modules.',
    bullets: [
      '8 built-in actions: Input, Clipboard, Screenshot, OCR, Translate, Summarize, Note, Copy',
      'Runs inside the Wasmi sandbox with 0 host imports and a 10,000-fuel budget',
      'Reuse any saved chain with workflow run <name>',
    ],
    cmds: ['workflow', 'workflow new', 'workflow run', 'store'],
  },
  {
    id: 'ai',
    tab: 'Local AI',
    badge: '100% Loopback Ollama',
    img: 'images/spotlight-ai.png',
    title: 'Context-Aware Local AI (Zero Cloud)',
    desc: 'Ask questions about your active project, open KDE windows, and todos.md using verified local-only Ollama — with an exact context preview before anything is sent.',
    bullets: [
      'Requires OLLAMA_NO_CLOUD=1 on 127.0.0.1 and refuses redirects or cloud endpoints',
      'Toggle Project, Open Windows, and todos.md sources individually',
      'Explicit Send locally, Copy Answer, and Save Answer as Note buttons',
    ],
    cmds: ['ai ask ...', 'ai summarize clipboard', 'ai models', 'project ~/Projects/app'],
  },
  {
    id: 'dev',
    tab: 'Dev & Git/Docker',
    badge: 'Developer Power Suite',
    img: 'images/spotlight-dev.png',
    title: 'Git Dashboard, Docker Logs & HTTP Scratch',
    desc: 'Jump into VS Code/JetBrains projects, inspect all dirty Git repos under ~/Projects, tail live Docker/Podman logs, test REST APIs, and diff .env files without leaving the keyboard.',
    bullets: [
      'git status lists all dirty repos with branch and change counts',
      'docker logs nginx streams live stdout/stderr; docker exec opens an interactive shell',
      'get https://... opens an in-memory REST client with pretty-printed JSON',
    ],
    cmds: ['git status', 'docker logs nginx', 'get https://...', 'dotenv diff'],
  },
  {
    id: 'media',
    tab: 'Media & Image/PDF',
    badge: 'Local File Toolkit',
    img: 'images/spotlight-media.png',
    title: 'Screenshot, Image, PDF & Music Toolkit',
    desc: 'Extract 5-color palettes, compress images to WebP, resize to 1080p, extract PDF text, run Tesseract OCR, decode QR codes, and control MPRIS music players over D-Bus.',
    bullets: [
      'Screenshot capture immediately offers Copy, OCR, QR Decode, Compress, Pin & Save',
      'All image conversions preserve original files and pick unused sibling filenames',
      'Direct MPRIS controls: music, pause, next track, and play lofi',
    ],
    cmds: ['palette', 'compress image 50%', 'pdf text', 'music'],
  },
  {
    id: 'desktop',
    tab: 'Calendar & KDE',
    badge: 'Plasma + Wayland Native',
    img: 'images/spotlight-desktop.png',
    title: 'Natural Calendar Events, Pomodoro & KDE Layouts',
    desc: 'Create GNOME/Evolution or local calendar events by typing natural text, launch Pomodoro sessions with auto-Caffeinate, and save/restore full KDE KWin window layouts.',
    bullets: [
      'Type add event Dinner on July 13 at 6pm and review before saving',
      'pomodoro 25m automatically keeps your screen awake and survives restarts',
      'layout save work / layout work arranges open apps across connected monitors',
    ],
    cmds: ['add event ...', 'pomodoro 25m', 'layout save work', 'color picker'],
  },
];

const COMMANDS = [
  { cmd: 'firefox / vscode', desc: 'Fuzzy-launch any installed Linux app', cat: 'Everyday' },
  { cmd: 'Search File', desc: 'Search home files & folders with thumbnails + Tab actions', cat: 'Everyday' },
  { cmd: 'rg rust / in: notes TODO', desc: 'Stream ripgrep content matches with inline preview', cat: 'Everyday' },
  { cmd: '25 * 48 / 10 km to mi', desc: 'Instant calculator & offline unit conversion', cat: 'Everyday' },
  { cmd: '100 USD to EUR', desc: 'Daily currency conversion via Frankfurter', cat: 'Everyday' },
  { cmd: 'define serendipity', desc: 'English dictionary definitions & examples', cat: 'Everyday' },
  { cmd: 'translate en es cat', desc: 'Offline local dictd / FreeDict translation', cat: 'Everyday' },
  { cmd: 'tldr tar / cheat curl', desc: 'Copyable command cheat sheets inline', cat: 'Everyday' },
  { cmd: 'note call Alex', desc: 'Quick note capture (auto-connects Obsidian vault)', cat: 'Everyday' },
  { cmd: 'todo add buy milk', desc: 'Append Markdown checkbox to todos.md', cat: 'Everyday' },
  { cmd: 'vault / clip pinned', desc: 'Argon2id + XChaCha20-Poly1305 encrypted clipboard vault', cat: 'Security' },
  { cmd: 'clip queue', desc: 'Ordered text & PNG paste queue over in-memory pipe', cat: 'Security' },
  { cmd: 'pass github', desc: 'Copy passwords via rbw or KeePassXC (30s auto-clear)', cat: 'Security' },
  { cmd: 'encrypt file / checksum file', desc: 'Local GPG encryption, SHA-256 checksum & shredder', cat: 'Security' },
  { cmd: 'workflow / workflow new', desc: 'Visual no-code WASM workflow builder & runner', cat: 'AI' },
  { cmd: 'ai ask ...', desc: 'Context-aware local Ollama AI with exact preview', cat: 'AI' },
  { cmd: 'ai summarize clipboard', desc: 'Summarize clipboard text locally (OLLAMA_NO_CLOUD=1)', cat: 'AI' },
  { cmd: 'code myproject', desc: 'Reopen recent VS Code / VSCodium / JetBrains projects', cat: 'Dev' },
  { cmd: 'git status', desc: 'Dashboard of all dirty Git repos under ~/Projects', cat: 'Dev' },
  { cmd: 'docker logs nginx', desc: 'Live-tail Docker/Podman logs inside Spotlight', cat: 'Dev' },
  { cmd: 'docker exec nginx', desc: 'Open interactive container shell in terminal', cat: 'Dev' },
  { cmd: 'get https://api.github.com/user', desc: 'In-memory HTTP Scratch REST client with pretty JSON', cat: 'Dev' },
  { cmd: 'dotenv diff', desc: 'Compare .env against .env.example safely', cat: 'Dev' },
  { cmd: 'ssh myserver', desc: 'Search ~/.ssh/config aliases & launch in Konsole', cat: 'Dev' },
  { cmd: 'gh pr list / gh issue bug', desc: 'Search open GitHub PRs & issues for current project', cat: 'Dev' },
  { cmd: 'uuid / hash / base64 / qr', desc: 'Offline text, checksum, JSON, case & QR generators', cat: 'Dev' },
  { cmd: 'screenshot / ocr', desc: 'Desktop portal capture with OCR, QR, Compress & Pin', cat: 'Media' },
  { cmd: 'compress image 50%', desc: 'Save quality-50 WebP (keeps original)', cat: 'Media' },
  { cmd: 'palette / pdf text', desc: 'Extract 5 dominant colors or PDF text locally', cat: 'Media' },
  { cmd: 'music / pause / next track', desc: 'Direct MPRIS media player controls over D-Bus', cat: 'Desktop' },
  { cmd: 'history / bookmark / tabs', desc: 'Search local Firefox, Chrome, Chromium & Brave data', cat: 'Desktop' },
  { cmd: 'add event Dinner on July 13 at 6pm', desc: 'Create GNOME/Evolution or local calendar event', cat: 'Desktop' },
  { cmd: 'pomodoro 25m / keep awake', desc: 'Focus timer with automatic Caffeinate', cat: 'Desktop' },
  { cmd: 'layout save work / layout work', desc: 'Save & restore KDE KWin window positions', cat: 'Desktop' },
  { cmd: 'color picker / measure', desc: 'Wayland eyedropper (HEX/RGB/HSL) & pixel ruler', cat: 'Desktop' },
  { cmd: 'wifi / bluetooth / dnd / dark mode', desc: 'Instant KDE desktop & audio controls', cat: 'Desktop' },
];

const DISTROS = {
  ubuntu: {
    label: 'Ubuntu / Mint / Debian',
    deps: `sudo apt update\nsudo apt install build-essential git curl ca-certificates pkg-config libgtk-4-dev libsqlite3-dev`,
  },
  arch: {
    label: 'Arch / EndeavourOS / Manjaro',
    deps: `sudo pacman -Syu --needed base-devel git curl ca-certificates pkgconf gtk4 sqlite`,
  },
  fedora: {
    label: 'Fedora Workstation / KDE',
    deps: `sudo dnf install gcc git curl ca-certificates pkgconf-pkg-config gtk4-devel sqlite-devel`,
  },
  opensuse: {
    label: 'openSUSE Tumbleweed',
    deps: `sudo zypper refresh\nsudo zypper install gcc git curl ca-certificates pkgconf-pkg-config gtk4-devel sqlite3-devel`,
  },
  nix: {
    label: 'Nix / NixOS (1-Command)',
    deps: `nix profile install github:danny19862025/spotlight`,
  },
};

document.addEventListener('DOMContentLoaded', () => {
  // 1. Cursor-tracking Spotlight Beam
  const root = document.documentElement;
  window.addEventListener('pointermove', (e) => {
    root.style.setProperty('--mx', `${e.clientX}px`);
    root.style.setProperty('--my', `${e.clientY}px`);
  }, { passive: true });

  // Card hover glow coordinates
  document.querySelectorAll('.feature-card').forEach((card) => {
    card.addEventListener('pointermove', (e) => {
      const r = card.getBoundingClientRect();
      card.style.setProperty('--cx', `${e.clientX - r.left}px`);
      card.style.setProperty('--cy', `${e.clientY - r.top}px`);
    });
  });

  // 2. Scroll Progress Beam
  const scrollBeam = document.getElementById('scrollBeam');
  window.addEventListener('scroll', () => {
    const h = document.documentElement;
    const pct = (h.scrollTop / (h.scrollHeight - h.clientHeight || 1)) * 100;
    scrollBeam.style.width = `${Math.min(100, Math.max(0, pct))}%`;
  }, { passive: true });

  // 3. IntersectionObserver Reveal Animations
  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const delay = entry.target.dataset.delay || '0';
          entry.target.style.transitionDelay = `${delay}ms`;
          entry.target.classList.add('is-visible');
          revealObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.02, rootMargin: '0px 0px -10px 0px' }
  );
  document.querySelectorAll('.reveal').forEach((el) => revealObserver.observe(el));

  // Safety check on scroll so no revealed section ever stays hidden
  function checkVisibleReveals() {
    const vh = window.innerHeight || 900;
    document.querySelectorAll('.reveal:not(.is-visible)').forEach((el) => {
      const rect = el.getBoundingClientRect();
      if (rect.top < vh * 0.98 && rect.bottom > 0) {
        el.classList.add('is-visible');
        revealObserver.unobserve(el);
      }
    });
  }
  window.addEventListener('scroll', checkVisibleReveals, { passive: true });
  setTimeout(checkVisibleReveals, 350);

  // 4. Interactive Hero Launcher Simulator
  const simInput = document.getElementById('simInput');
  const simResults = document.getElementById('simResults');
  const simChips = document.querySelectorAll('.sim-chip');

  function renderSim(key) {
    const data = SIM_DATA[key] || SIM_DATA.calc;
    simInput.value = data.query;
    simChips.forEach((c) => c.classList.toggle('active', c.dataset.sim === key));
    simResults.innerHTML = data.rows
      .map(
        (r) => `
      <div class="sim-row">
        <div class="sim-row-left">
          <div class="sim-icon">${r.icon}</div>
          <div>
            <div class="sim-title">${r.title}</div>
            <div class="sim-desc">${r.desc}</div>
          </div>
        </div>
        <span class="sim-tag">${r.tag}</span>
      </div>`
      )
      .join('');
  }

  simChips.forEach((chip) => {
    chip.addEventListener('click', () => renderSim(chip.dataset.sim));
  });

  simInput.addEventListener('input', () => {
    const q = simInput.value.trim().toLowerCase();
    if (!q) return renderSim('calc');
    const matchedKey =
      Object.keys(SIM_DATA).find(
        (k) =>
          q.includes(k) ||
          SIM_DATA[k].query.toLowerCase().includes(q)
      ) || null;
    if (matchedKey) {
      const data = SIM_DATA[matchedKey];
      simChips.forEach((c) => c.classList.toggle('active', c.dataset.sim === matchedKey));
      simResults.innerHTML = data.rows
        .map(
          (r) => `
        <div class="sim-row">
          <div class="sim-row-left">
            <div class="sim-icon">${r.icon}</div>
            <div>
              <div class="sim-title">${r.title}</div>
              <div class="sim-desc">${r.desc}</div>
            </div>
          </div>
          <span class="sim-tag">${r.tag}</span>
        </div>`
        )
        .join('');
    } else {
      const filtered = COMMANDS.filter(
        (c) => c.cmd.toLowerCase().includes(q) || c.desc.toLowerCase().includes(q)
      ).slice(0, 3);
      simResults.innerHTML = filtered.length
        ? filtered
            .map(
              (c) => `
          <div class="sim-row">
            <div class="sim-row-left">
              <div class="sim-icon">⌘</div>
              <div>
                <div class="sim-title">${c.cmd}</div>
                <div class="sim-desc">${c.desc}</div>
              </div>
            </div>
            <span class="sim-tag">${c.cat}</span>
          </div>`
            )
            .join('')
        : `<div class="sim-row"><div class="sim-row-left"><div class="sim-icon">🔎</div><div><div class="sim-title">Search Web for "${simInput.value}"</div><div class="sim-desc">Press Ctrl+Enter to open in your default browser</div></div></div><span class="sim-tag">Web</span></div>`;
    }
  });
  renderSim('vault');

  // 5. 8-Screenshot Interactive Stage + Bento Gallery + Lightbox
  let activeShotIndex = 0;
  const stageTabs = document.getElementById('stageTabs');
  const stageFrame = document.getElementById('stageFrame');
  const stageImg = document.getElementById('stageImg');
  const stageBadge = document.getElementById('stageBadge');
  const stageTitle = document.getElementById('stageTitle');
  const stageDesc = document.getElementById('stageDesc');
  const stageBullets = document.getElementById('stageBullets');
  const stageCmds = document.getElementById('stageCmds');
  const galleryGrid = document.getElementById('galleryGrid');

  SCREENSHOTS.forEach((shot, idx) => {
    const btn = document.createElement('button');
    btn.className = `stage-tab${idx === 0 ? ' active' : ''}`;
    btn.textContent = shot.tab;
    btn.addEventListener('click', () => selectShot(idx));
    stageTabs.appendChild(btn);

    const card = document.createElement('div');
    card.className = 'gallery-card reveal reveal-tilt';
    card.dataset.delay = String((idx % 4) * 70);
    card.innerHTML = `
      <img src="${shot.img}" alt="${shot.title}" loading="lazy" />
      <div class="gallery-card-body">
        <div class="gallery-card-title">${shot.tab}</div>
        <div class="gallery-card-sub">${shot.badge}</div>
      </div>
    `;
    card.addEventListener('click', () => {
      selectShot(idx);
      openLightbox(idx);
    });
    galleryGrid.appendChild(card);
    revealObserver.observe(card);
  });

  function selectShot(idx) {
    activeShotIndex = idx;
    const shot = SCREENSHOTS[idx];
    stageTabs.querySelectorAll('.stage-tab').forEach((b, i) => b.classList.toggle('active', i === idx));
    stageFrame.classList.remove('switching');
    void stageFrame.offsetWidth;
    stageImg.src = shot.img;
    stageImg.alt = shot.title;
    stageFrame.classList.add('switching');
    stageBadge.textContent = shot.badge;
    stageTitle.textContent = shot.title;
    stageDesc.textContent = shot.desc;
    stageBullets.innerHTML = shot.bullets.map((b) => `<li>${b}</li>`).join('');
    stageCmds.innerHTML = shot.cmds.map((c) => `<span class="cmd-pill">${c}</span>`).join('');
  }
  selectShot(0);

  // Lightbox
  const lightbox = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightboxImg');
  const lightboxCaption = document.getElementById('lightboxCaption');

  function openLightbox(idx) {
    activeShotIndex = (idx + SCREENSHOTS.length) % SCREENSHOTS.length;
    const shot = SCREENSHOTS[activeShotIndex];
    lightboxImg.src = shot.img;
    lightboxImg.alt = shot.title;
    lightboxCaption.textContent = `${shot.title} — ${shot.badge}`;
    lightbox.classList.add('open');
  }

  stageFrame.addEventListener('click', () => openLightbox(activeShotIndex));
  document.getElementById('lbClose').addEventListener('click', () => lightbox.classList.remove('open'));
  document.getElementById('lbPrev').addEventListener('click', () => openLightbox(activeShotIndex - 1));
  document.getElementById('lbNext').addEventListener('click', () => openLightbox(activeShotIndex + 1));
  lightbox.addEventListener('click', (e) => {
    if (e.target === lightbox) lightbox.classList.remove('open');
  });
  window.addEventListener('keydown', (e) => {
    if (!lightbox.classList.contains('open')) return;
    if (e.key === 'Escape') lightbox.classList.remove('open');
    if (e.key === 'ArrowLeft') openLightbox(activeShotIndex - 1);
    if (e.key === 'ArrowRight') openLightbox(activeShotIndex + 1);
  });

  // 6. Feature Category Filters
  const featureFilters = document.querySelectorAll('#featureFilters .stage-tab');
  const featureCards = document.querySelectorAll('.feature-card');
  featureFilters.forEach((btn) => {
    btn.addEventListener('click', () => {
      const cat = btn.dataset.cat;
      featureFilters.forEach((b) => b.classList.toggle('active', b === btn));
      featureCards.forEach((card) => {
        const show = cat === 'all' || card.dataset.cat === cat;
        card.classList.toggle('hidden', !show);
      });
    });
  });

  // 7. Interactive Command Cheat Sheet
  const cheatGrid = document.getElementById('cheatGrid');
  const cheatSearch = document.getElementById('cheatSearch');
  const toast = document.getElementById('toast');
  let toastTimer = null;

  function showToast(msg) {
    toast.textContent = msg;
    toast.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove('show'), 2100);
  }

  function renderCommands(filter = '') {
    const q = filter.trim().toLowerCase();
    const list = COMMANDS.filter(
      (c) => !q || c.cmd.toLowerCase().includes(q) || c.desc.toLowerCase().includes(q) || c.cat.toLowerCase().includes(q)
    );
    cheatGrid.innerHTML = list
      .map(
        (c) => `
      <div class="cheat-item" data-copy="${c.cmd.split('/')[0].trim()}">
        <span class="cheat-cmd">${c.cmd}</span>
        <span class="cheat-desc">${c.desc}</span>
      </div>`
      )
      .join('');
    cheatGrid.querySelectorAll('.cheat-item').forEach((item) => {
      item.addEventListener('click', () => {
        navigator.clipboard?.writeText(item.dataset.copy).catch(() => {});
        showToast(`Copied: ${item.dataset.copy}`);
      });
    });
  }
  renderCommands();
  cheatSearch.addEventListener('input', () => renderCommands(cheatSearch.value));

  // 8. Distro Quick Start Tabs & Copy Buttons
  const distroTabs = document.getElementById('distroTabs');
  const depsCode = document.getElementById('depsCode');
  const buildStep = document.getElementById('buildStep');

  Object.entries(DISTROS).forEach(([key, info], idx) => {
    const btn = document.createElement('button');
    btn.className = `stage-tab${idx === 0 ? ' active' : ''}`;
    btn.textContent = info.label;
    btn.addEventListener('click', () => {
      distroTabs.querySelectorAll('.stage-tab').forEach((b) => b.classList.remove('active'));
      btn.classList.add('active');
      depsCode.textContent = info.deps;
      buildStep.style.display = key === 'nix' ? 'none' : 'block';
    });
    distroTabs.appendChild(btn);
  });
  depsCode.textContent = DISTROS.ubuntu.deps;

  document.querySelectorAll('.copy-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
      const target = document.getElementById(btn.dataset.target);
      if (!target) return;
      navigator.clipboard?.writeText(target.textContent.trim()).catch(() => {});
      btn.textContent = 'Copied!';
      showToast('Command copied to clipboard');
      setTimeout(() => (btn.textContent = 'Copy'), 1600);
    });
  });
});
