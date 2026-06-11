(async function setupMapUI() {
  let storage = await getDataSourceForDomain(window.location);
  let { tetrioPlusEnabled } = await storage.get('tetrioPlusEnabled');
  if (!tetrioPlusEnabled) return;
  let { enableCustomMaps } = await storage.get('enableCustomMaps');
  if (!enableCustomMaps) return;

  let roomConfigItem;
  while (true) { // wait for the element to load
    roomConfigItem = document.querySelector(
      "input[value=\"CUSTOM GAME\"].room_config_item"
    );
    if (roomConfigItem) break;
    await new Promise(res => setTimeout(res, 100));
  }
  let roomConfig = roomConfigItem.parentElement.parentElement;

  let row = document.createElement('div');
  row.classList.add('room_config_row', 'flex-row', 'ns');
  roomConfig.insertBefore(row, roomConfig.firstChild);

  let label = document.createElement('div');
  label.classList.add('room_config_label', 'flex-item', 'ns');
  label.innerText = 'Use custom map';
  row.appendChild(label);

  let check = document.createElement('input');
  check.classList.add('room_config_item', 'flex-item');
  check.type = 'checkbox';
  row.appendChild(check);

  let row2 = document.createElement('div');
  row2.classList.add('room_config_row', 'flex-row', 'ns');
  roomConfig.insertBefore(row2, row.nextSibling);

  let label2 = document.createElement('div');
  label2.classList.add('room_config_label', 'flex-item', 'ns');
  label2.innerText = 'Custom map string';
  row2.appendChild(label2);

  let mapInput = document.createElement('input');
  mapInput.classList.add('room_config_item', 'flex-item');
  mapInput.style.fontFamily = 'monospace';
  check.addEventListener('change', evt => {
    mapInput.setAttribute("data-index", check.checked ? "map" : "");
  });
  row2.appendChild(mapInput);

  let button = document.createElement('button');
  button.classList.add('room_config_item', 'flex_item');
  button.style.flexBasis = 'max-content';
  button.innerText = 'Open editor';
  window.addEventListener('click', (evt) => {
    if (evt.target == button) {
      let port = browser.runtime.connect({ name: 'info-channel' });
      port.postMessage({ type: 'openMapEditor', map: mapInput.value });
    }
  }, true);
  row2.appendChild(button);
})().catch(console.error).then(() => console.log("Done"));
