//! Phorge: Accept and Next
//!
//! Adds review-queue keybindings to Phorge Differential:
//!   Shift+A  accept the current revision, then jump to the next in the queue
//!   Shift+N  view next (without accepting)
//!
//! HOW TO DEBUG:
//! 1. open a Differential page on $BASE_URI
//! 2. F12 to open the console (content-script logs appear here)
//! 3. press a hotkey; toasts appear bottom-right, errors log to console

(function () {
  'use strict';

  const TOKEN_KEY = 'conduitToken';
  const QUEUE_KEY = 'reviewQueue';

  // ---- storage (extension-isolated, async) ------------------------------
  const store = {
    get(key) {
      return new Promise((resolve) => {
        chrome.storage.local.get(key, (items) => resolve(items[key]));
      });
    },
    set(key, value) {
      return new Promise((resolve) => {
        chrome.storage.local.set({ [key]: value }, resolve);
      });
    },
  };

  function promptForToken() {
    const token = window.prompt(
      'Paste a Conduit API token (starts with "cli-").\n' +
      'Create one at /settings/panel/apitokens/');
    if (token && token.trim()) {
      store.set(TOKEN_KEY, token.trim());
      return token.trim();
    }
    return '';
  }

  async function getToken() {
    const token = await store.get(TOKEN_KEY);
    if (token) return token;
    return promptForToken();
  }

  // ---- conduit call ------------------------------------------------------
  function conduitAcceptRevision(revisionId, token) {
    const params = {
      objectIdentifier: revisionId,
      transactions: [{ type: 'accept', value: true }],
      __conduit__: { token },
    };
    const body = new URLSearchParams();
    body.set('output', 'json');
    body.set('params', JSON.stringify(params));

    return fetch(window.location.origin + '/api/differential.revision.edit', {
      method: 'POST',
      // credentials: 'omit' or else Phorge sees the session cookie before the api
      // token and rejects the request due to CSRF (?)
      credentials: 'omit',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body.toString(),
    })
      .then((r) => r.json())
      .then((json) => {
        if (json.error_code) {
          throw new Error(json.error_code + ': ' + (json.error_info || ''));
        }
        return json.result;
      });
  }

  // ---- review queue ------------------------------------------------------
  function currentRevisionId() {
    const m = location.pathname.match(/^\/(D\d+)(?:$|\/)/);
    return m ? m[1] : null;
  }

  function isListPage() {
    return currentRevisionId() === null;
  }

  async function harvestQueue() {
    const ids = [];
    const seen = new Set();
    document.querySelectorAll('a[href]').forEach((a) => {
      const m = a.getAttribute('href').match(/^\/(D\d+)$/);
      if (m && !seen.has(m[1])) { seen.add(m[1]); ids.push(m[1]); }
    });
    if (ids.length) await store.set(QUEUE_KEY, ids);
    return ids;
  }

  async function navigateRelative(offset) {
    const queue = (await store.get(QUEUE_KEY)) || [];
    const here = currentRevisionId();
    const idx = queue.indexOf(here);
    if (idx === -1) {
      if (offset > 0) { location.href = '/differential/'; return; }
      toast('Current revision is not in the captured queue.', 'warn');
      return;
    }
    const target = queue[idx + offset];
    if (target) {
      location.href = '/' + target;
    } else {
      toast(offset > 0 ? 'End of queue.' : 'Start of queue.', 'warn');
      location.href = '/differential/';
    }
  }

  // ---- toast -------------------------------------------------------------
  function toast(message, kind) {
    const el = document.createElement('div');
    el.textContent = message;
    const bg = kind === 'ok' ? '#1f6e2c' : kind === 'warn' ? '#8a6d00' : kind === 'err' ? '#7a1f1f' : '#333';
    Object.assign(el.style, {
      position: 'fixed', zIndex: 99999, right: '16px', bottom: '16px',
      background: bg, color: '#fff', padding: '10px 14px', borderRadius: '6px',
      font: '13px/1.4 sans-serif', maxWidth: '360px', boxShadow: '0 2px 8px rgba(0,0,0,.4)',
    });
    document.body.appendChild(el);
    setTimeout(() => el.remove(), 4000);
  }

  // ---- actions -----------------------------------------------------------
  async function acceptAndNext() {
    const id = currentRevisionId();
    if (!id) { toast('Not on a revision page.', 'warn'); return; }
    const token = await getToken();
    if (!token) { toast('No API token set.', 'err'); return; }

    toast('Accepting ' + id + '...');
    try {
      await conduitAcceptRevision(id, token);
      toast('Accepted ' + id + '. Moving on...', 'ok');
      setTimeout(() => navigateRelative(+1), 500);
    } catch (err) {
      toast('Accept failed: ' + err.message, 'err');
      if (/ERR-INVALID-AUTH|ERR-INVALID-SESSION/.test(err.message)) promptForToken();
    }
  }

  // ---- keybindings -------------------------------------------------------
  function isTyping(e) {
    const t = e.target;
    return t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.isContentEditable);
  }

  function onKeydown(e) {
    if (isTyping(e) || e.ctrlKey || e.metaKey || e.altKey) return;
    if (!e.shiftKey) return;
    switch (e.key) {
      case 'A': e.preventDefault(); acceptAndNext(); break;        // accept + next
      case 'N': e.preventDefault(); navigateRelative(+1); break;   // next rev
      // case 'P': e.preventDefault(); navigateRelative(-1); break;   // previous rev
      // case 'T': e.preventDefault(); promptForToken(); break;       // set token
      default: break;
    }
  }

  // ---- activation --------------------------------------------------------
  // to be generic and work on any phorge instance, the extension is enabled
  // globally but exits immediately if the page doesn't look like phabricator
  function isPhorgeSite() {
    return document.querySelector('.phabricator-standard-page, #phabricator-standard-page') !== null;
  }

  if (!isPhorgeSite()) return;

  document.addEventListener('keydown', onKeydown);
  if (isListPage()) harvestQueue();
})();
