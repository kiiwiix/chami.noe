(function(){
  const root = document.documentElement;
  const toggle = document.querySelector('[data-theme-toggle]');
  const storageKey = 'preferred-theme';
  const label = theme => theme === 'dark' ? 'Passer en mode clair' : 'Passer en mode sombre';

  const applyTheme = theme => {
    const isDark = theme === 'dark';
    if (isDark) {
      root.removeAttribute('data-theme');
    } else {
      root.setAttribute('data-theme', 'light');
    }
    if (toggle) {
      toggle.setAttribute('aria-pressed', isDark ? 'true' : 'false');
      const textNode = toggle.querySelector('span');
      if (textNode) {
        textNode.textContent = label(isDark ? 'dark' : 'light');
      }
    }
  };

  let storedPreference = null;
  try {
    storedPreference = localStorage.getItem(storageKey);
  } catch (error) {
    storedPreference = null;
  }

  const initialTheme = storedPreference === 'dark' ? 'dark' : 'light';
  applyTheme(initialTheme);

  if (toggle) {
    toggle.addEventListener('click', () => {
      const currentTheme = root.getAttribute('data-theme') === 'light' ? 'light' : 'dark';
      const nextTheme = currentTheme === 'light' ? 'dark' : 'light';
      applyTheme(nextTheme);
      try {
        localStorage.setItem(storageKey, nextTheme);
      } catch (error) {
        // ignore storage failures (private mode, etc.)
      }
    });

    const systemQuery = window.matchMedia('(prefers-color-scheme: dark)');
    const handleSystemChange = event => {
      let remembered = null;
      try {
        remembered = localStorage.getItem(storageKey);
      } catch (error) {
        remembered = null;
      }
      if (!remembered) {
        applyTheme(event.matches ? 'dark' : 'light');
      }
    };

    try {
      if (typeof systemQuery.addEventListener === 'function') {
        systemQuery.addEventListener('change', handleSystemChange);
      } else if (typeof systemQuery.addListener === 'function') {
        systemQuery.addListener(handleSystemChange);
      }
    } catch (error) {
      // older browsers might throw if matchMedia is unsupported
    }
  }

  const navLinks = Array.from(document.querySelectorAll('.nav a'));
  if (navLinks.length) {
    const currentPath = window.location.pathname.split('/').pop() || 'index.html';
    navLinks.forEach(link => {
      const href = link.getAttribute('href') || '';
      const normalized = href.replace(/^\.\//, '') || 'index.html';
      if (normalized === currentPath) {
        link.setAttribute('aria-current', 'page');
      } else {
        link.removeAttribute('aria-current');
      }
    });
  }
})();
