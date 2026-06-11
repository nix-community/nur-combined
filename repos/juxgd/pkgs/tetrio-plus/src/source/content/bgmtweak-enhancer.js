(async () => {
  let storage = await getDataSourceForDomain(window.location);
  let cfg = await storage.get(['enableAllSongTweaker', 'tetrioPlusEnabled']);
  if (!cfg.enableAllSongTweaker) return;
  if (!cfg.tetrioPlusEnabled) return;

  const bgmtweak = document.getElementById('bgmtweak');
  const observer = new MutationObserver((list, observer) => {
    if (!document.getElementById('tetrioplus-tweakall-ct'))
      reinject();
  });
  observer.observe(bgmtweak, { childList: true });
  reinject();

  function reinject() {
    let ct = document.createElement('div');
    ct.innerHTML = `
      <div class="control_group flex-row bgmtweaking" id="tetrioplus-tweakall-ct">
        <h1 class="bgmtweak_header rg_target_pri">
          All songs
        </h1>
        <div class="control_button flex-item bgmtweak_option tetrioplus-tweakall" data-option="ban">
          BAN
        </div>
        <div class="control_button flex-item bgmtweak_option tetrioplus-tweakall" data-option="minmin">
          --
        </div>
        <div class="control_button flex-item bgmtweak_option tetrioplus-tweakall" data-option="min">
          -
        </div>
        <div class="control_button flex-item bgmtweak_option tetrioplus-tweakall" data-option="base">
          =
        </div>
        <div class="control_button flex-item bgmtweak_option tetrioplus-tweakall" data-option="plus">
          +
        </div>
        <div class="control_button flex-item bgmtweak_option tetrioplus-tweakall" data-option="plusplus">
          ++
        </div>
      </div>
    `;
    bgmtweak.prepend(ct);

    for (let elem of ct.querySelectorAll('.tetrioplus-tweakall')) {
      elem.addEventListener('click', () => {
        document.querySelectorAll(
          `.bgmtweak_option` +
          `[data-option="${elem.getAttribute('data-option')}"]` +
          `:not(.tetrioplus-tweakall)`
        ).forEach(el => el.click());
      });
    }
  }
})().catch(console.error);
