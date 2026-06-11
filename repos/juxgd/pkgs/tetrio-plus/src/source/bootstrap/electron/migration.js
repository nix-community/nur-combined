greenlog("running migrations");
await migrate(browser.storage.local);