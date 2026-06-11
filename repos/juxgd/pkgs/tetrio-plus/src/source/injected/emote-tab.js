/* Added by Jabster28 | MIT Licensed */
/* Modified by UniQMG */
(async () => {
  // Injected @ filters/emote-tab-tetriojs-filter.js, content/emote-tab.js
  while (!window.emoteMap || !localStorage.chTetrioUser)
    await new Promise(res => setTimeout(res, 100));

  const user = JSON.parse(localStorage.chTetrioUser);
  const emotes = window.emoteMap;
  const emoteList = [];

  // Access level 4 has only one emote (:wifeheart:)
  // I'm assuming sysop is the only role that has that access level, since as far as I know only osk has it
  let accesslevels = { 1: true, 2: user.supporter, 3: user.staff, 4: user.sysop };
  console.log("Emote tab: access levels:", accesslevels);
  for (let { id, type, src, access } of Object.values(emotes))
    if (!emoteList.some(emote => emote.name == id))
      emoteList.push({ name: id, url: src + type, allowed: accesslevels[access] });

  const picker = document.createElement('div');
  picker.classList.add('tetrioplus-emote-picker');
  picker.classList.add('chat-message');
  for (let { name, url, allowed } of emoteList) {
    let el = document.createElement('div');
    el.classList.add('emote');
    el.classList.toggle('disallowed', !allowed);
    el.setAttribute('data-emote', name);
    el.title = `:${name}:`;
    el.alt = `:${name}:`;

    if (allowed) {
      el.addEventListener('click', (evt) => {
        let chatInput = picker.parentElement.id == 'room_chat'
          ? document.getElementById('chat_input')
          : document.getElementById('ingame_chat_input');
        autocomplete(name, evt.shiftKey, chatInput, picker.parentElement);
      });
    }

    let img = document.createElement('img');
    img.src = url;
    el.appendChild(img);

    let label = document.createElement('span');
    label.classList.add('label');
    label.innerText = `:${name}:`;
    if (!allowed)
      label.innerText += ` (can't use)`;
    el.appendChild(label);

    picker.appendChild(el);
  }

  let elements = [
    ['chat_input', 'room_chat'],
    ['ingame_chat_input', 'ingame_chat']
  ].map(list => list.map(id => document.getElementById(id)));

  for (let [chatInput, chatHistory] of elements) {
    chatInput.addEventListener('input', () => updateEmotes(chatInput, chatHistory));
    chatInput.addEventListener('keydown', (evt) => {
      if (!picker.isConnected) return;
      let pickable = [...picker.querySelectorAll('.match:not(.disallowed)')];
      let currentPick = picker.querySelector('.match.active') || pickable[0];
      if (evt.key == 'ArrowUp' || evt.key == 'ArrowDown') {
        let delta = evt.key == 'ArrowUp' ? -1 : 1;
        let newIndex = pickable.indexOf(currentPick) + delta;
        newIndex = (newIndex % pickable.length + pickable.length) % pickable.length;
        currentPick.classList.remove('active');
        pickable[newIndex].classList.add('active');
        evt.stopImmediatePropagation();
        evt.preventDefault();
      }
      if (evt.key == 'Enter') {
        if (!currentPick) return;
        let name = currentPick.getAttribute('data-emote');
        autocomplete(name, evt.shiftKey, chatInput, chatHistory);
        evt.stopImmediatePropagation();
        evt.preventDefault();
      }
    })
  }

  function autocomplete(name, shiftKey, chatInput, chatHistory) {
    let pre = chatInput.value.slice(0, chatInput.selectionStart+1);
    let post = chatInput.value.slice(chatInput.selectionStart);
    let completed = `:${name}:`;
    // start another emote, reusing last one as prefix to maintain list
    if (shiftKey) completed += `:$1`;
    chatInput.value = pre.replace(/:([^:]*)$/, completed) + post;
    chatInput.scrollLeft = chatInput.scrollWidth
    updateEmotes(chatInput, chatHistory);
  }

  function updateEmotes(input, anchor) {
    let sliced = input.value.slice(0, input.selectionStart+1);

    let match = /(?::[^:]+)?:([^:]*)$/.exec(sliced);
    if (match == null) {
      picker.remove();
      return;
    }

    let [fullMatch, partialEmote] = match;
    if (fullMatch != ':' && partialEmote == "") {
      picker.remove();
      return;
    }

    anchor.appendChild(picker);

    let count = 0;
    for (let img of picker.children) {
      let match = img.getAttribute('data-emote').toLowerCase().startsWith(partialEmote.toLowerCase());
      if (!match) img.classList.remove('active');
      img.classList.toggle('match', match);
      if (match) count++;
    }

    if (!picker.querySelector('.match:not(.disallowed).active'))
      picker.querySelector('.match:not(.disallowed)')?.classList?.add?.('active');
    picker.classList.toggle('list', count <= 18); // 18 = # of ranks
  }
})()
