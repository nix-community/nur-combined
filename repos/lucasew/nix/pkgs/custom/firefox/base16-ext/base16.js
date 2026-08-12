
(function() {
    'use strict';
    console.time("base16")
    const colors = %COLORS%
    Object.keys(colors.colors).forEach(k => {
        document.body.style.setProperty(`--${k}`, `#${colors.colors[k]}`)
    })
    console.timeEnd("base16")
    console.log("base16 kicked in")
})();
