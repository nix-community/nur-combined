browser.storage.onChanged.addListener(async changes => {
	if (changes.tetrioPlusEnabled) {
		for (let { id } of await browser.tabs.query({ active: true })) {
			updateIcon(id);
		}
	}
});
browser.tabs.onActivated.addListener(tab => {
	updateIcon(tab.tabId);
});
browser.tabs.onUpdated.addListener(tabId => {
	updateIcon(tabId);
});

async function updateIcon(id) {
	console.log('Update icon for tab id', id);

	let { url } = await browser.tabs.get(id);
	// only populated on domains we have host perms for i.e. `tetr.io`
	if (!url) return;

	let { ok, reason } = await domainDataStatus(url);
	let icon = 'icons/tetrio-256.png';

	if (ok) icon = 'icons/tetrio-256-remote-content-pack.png';

	if (!ok && reason == 'TETR.IO PLUS is disabled')
		icon = 'icons/tetrio-256-disabled.png';

	if (!ok && reason == 'URL pack loading is disabled')
		icon = 'icons/tetrio-256-warning.png';

	if (!ok && reason.endsWith('not whitelisted'))
		icon = 'icons/tetrio-256-warning.png';

	if (!ok && reason == 'URL does not specify a content pack')
		icon = 'icons/tetrio-256.png';

	await browser.pageAction.setIcon({ tabId: id, path: icon });
}
