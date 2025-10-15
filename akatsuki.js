(() => {
  const container = document.querySelector('.akatsuki-crows');
  if (!container) return;

  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
  const crows = [];
  const CROW_COUNT = 14;

  const randomBetween = (min, max) => Math.random() * (max - min) + min;

  const configureCrow = (crow) => {
    const top = randomBetween(-6, 96);
    const duration = randomBetween(22, 38);
    const delay = randomBetween(-duration, 0);
    const drift = randomBetween(-14, 14);
    const scale = randomBetween(0.35, 0.85);
    const leftToRight = Math.random() > 0.4; // favor gauche -> droite pour équilibrer
    const startX = leftToRight ? '-14vw' : '114vw';
    const endX = leftToRight ? '114vw' : '-14vw';
    const midX = `${randomBetween(28, 72)}vw`;
    const wingSpeed = Math.max(0.55, duration / randomBetween(12, 18));

    crow.style.setProperty('--top', `${top}%`);
    crow.style.setProperty('--duration', `${duration.toFixed(1)}s`);
    crow.style.setProperty('--delay', `${delay.toFixed(1)}s`);
    crow.style.setProperty('--drift', `${drift.toFixed(1)}vh`);
    crow.style.setProperty('--scale', scale.toFixed(2));
    crow.style.setProperty('--direction', leftToRight ? '1' : '-1');
    crow.style.setProperty('--start-x', startX);
    crow.style.setProperty('--mid-x', midX);
    crow.style.setProperty('--end-x', endX);
    crow.style.setProperty('--wing-speed', `${wingSpeed.toFixed(2)}s`);
  };

  const buildCrow = () => {
    const crow = document.createElement('span');
    crow.className = 'akatsuki-crow';
    crow.innerHTML = '<span class="akatsuki-crow__wing"></span><span class="akatsuki-crow__wing"></span>';
    configureCrow(crow);
    crow.addEventListener('animationiteration', () => configureCrow(crow));
    return crow;
  };

  const destroy = () => {
    while (crows.length) {
      const crow = crows.pop();
      crow.remove();
    }
  };

  const init = () => {
    if (crows.length || reduceMotion.matches) return;
    for (let i = 0; i < CROW_COUNT; i += 1) {
      const crow = buildCrow();
      crows.push(crow);
      container.appendChild(crow);
    }
  };

  const handleMotionChange = (event) => {
    if (event.matches) {
      destroy();
    } else {
      init();
    }
  };

  if (!reduceMotion.matches) {
    init();
  }

  if (typeof reduceMotion.addEventListener === 'function') {
    reduceMotion.addEventListener('change', handleMotionChange);
  } else if (typeof reduceMotion.addListener === 'function') {
    reduceMotion.addListener(handleMotionChange);
  }
})();
