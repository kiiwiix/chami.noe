(() => {
  const canvas = document.getElementById('code-rain');
  if (!canvas) return;

  const context = canvas.getContext('2d');
  if (!context) return;

  const characters = '0123456789<>[]{}/*#=+-_%$ABCDEF';
  const reduceMotionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');

  let width = 0;
  let height = 0;
  let fontSize = 16;
  let columns = 0;
  let drops = [];
  let animationId = null;
  let lastTimestamp = 0;

  const getStyles = () => {
    const styles = getComputedStyle(document.documentElement);
    const color = styles.getPropertyValue('--code-rain-color') || 'rgba(211, 43, 43, 0.52)';
    const trail = styles.getPropertyValue('--code-rain-trail') || 'rgba(5, 5, 5, 0.08)';
    return { color: color.trim(), trail: trail.trim() };
  };

  const resize = () => {
    const rect = canvas.getBoundingClientRect();
    width = Math.max(1, rect.width);
    height = Math.max(1, rect.height);
    const deviceRatio = window.devicePixelRatio || 1;

    canvas.width = Math.round(width * deviceRatio);
    canvas.height = Math.round(height * deviceRatio);
    context.setTransform(deviceRatio, 0, 0, deviceRatio, 0, 0);

    fontSize = Math.max(14, Math.round(width / 90));
    columns = Math.max(1, Math.floor(width / fontSize));
    drops = new Array(columns).fill(0).map(() => Math.random() * -20);
    context.clearRect(0, 0, width, height);
  };

  const renderFrame = (timestamp) => {
    if (reduceMotionQuery.matches) {
      drawStatic();
      return;
    }

    const delta = timestamp - lastTimestamp;
    lastTimestamp = timestamp;

    const { color, trail } = getStyles();
    context.fillStyle = trail || 'rgba(5, 5, 5, 0.08)';
    context.fillRect(0, 0, width, height);

    if (delta > 0) {
      context.font = `${fontSize}px "Fira Code", "Source Code Pro", monospace`;
      context.textBaseline = 'top';
      context.fillStyle = color || 'rgba(211, 43, 43, 0.52)';
      for (let i = 0; i < columns; i += 1) {
        const text = characters.charAt(Math.floor(Math.random() * characters.length));
        const x = i * fontSize;
        const y = drops[i] * fontSize;
        context.fillText(text, x, y);
        if (y > height && Math.random() > 0.962) {
          drops[i] = 0;
        } else {
          drops[i] += 1;
        }
      }
    }

    animationId = window.requestAnimationFrame(renderFrame);
  };

  const drawStatic = () => {
    cancelAnimationFrame(animationId);
    animationId = null;
    const { color, trail } = getStyles();
    context.fillStyle = trail || 'rgba(5, 5, 5, 0.08)';
    context.fillRect(0, 0, width, height);
    context.font = `${fontSize}px "Fira Code", "Source Code Pro", monospace`;
    context.textBaseline = 'top';
    context.fillStyle = color || 'rgba(211, 43, 43, 0.52)';
    for (let i = 0; i < columns; i += 3) {
      let y = Math.random() * height;
      for (let step = 0; step < 6; step += 1) {
        const char = characters.charAt(Math.floor(Math.random() * characters.length));
        context.globalAlpha = 0.4 - step * 0.06;
        context.fillText(char, i * fontSize, y);
        y -= fontSize;
      }
    }
    context.globalAlpha = 1;
  };

  const start = () => {
    cancelAnimationFrame(animationId);
    animationId = null;
    lastTimestamp = performance.now();
    if (reduceMotionQuery.matches) {
      drawStatic();
    } else {
      animationId = window.requestAnimationFrame(renderFrame);
    }
  };

  const handleVisibility = () => {
    if (document.hidden) {
      if (animationId) {
        cancelAnimationFrame(animationId);
        animationId = null;
      }
    } else {
      start();
    }
  };

  resize();
  start();

  window.addEventListener('resize', () => {
    resize();
    start();
  });

  document.addEventListener('visibilitychange', handleVisibility);
  reduceMotionQuery.addEventListener('change', start);
})();
