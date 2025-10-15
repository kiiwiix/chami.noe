(() => {
  const terminal = document.getElementById('terminal');
  if (!terminal) return;

  const COMMANDS = [
    {
      command: 'nmap -sV 10.0.0.5',
      output: [
        'Starting Nmap 7.94 ( https://nmap.org )',
        'Nmap scan report for 10.0.0.5',
        'PORT     STATE SERVICE VERSION',
        '22/tcp   open  ssh     OpenSSH 8.4p1 Debian',
        '80/tcp   open  http    Apache httpd 2.4.57'
      ]
    },
    {
      command: 'ifconfig eth0',
      output: [
        'eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500',
        '        inet 192.168.56.12  netmask 255.255.255.0  broadcast 192.168.56.255',
        '        ether 08:00:27:bd:3c:af  txqueuelen 1000  (Ethernet)'
      ]
    },
    {
      command: 'ping -c 4 192.168.1.1',
      output: [
        'PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.',
        '64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=1.34 ms',
        '64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=1.29 ms',
        '--- 192.168.1.1 ping statistics ---',
        '4 packets transmitted, 4 received, 0% packet loss'
      ]
    },
    {
      command: 'sudo apt update',
      output: [
        'Atteint :1 http://kali.download/kali kali-rolling InRelease',
        'Lecture des listes de paquets... Fait',
        'Construction de l\'arbre des dépendances... Fait',
        'Calcul de la mise à jour... Fait'
      ]
    },
    {
      command: 'ls -la /var/www',
      output: [
        'total 28',
        'drwxr-xr-x  4 root root 4096 jan 15 09:12 .',
        'drwxr-xr-x 14 root root 4096 jan 15 08:01 ..',
        '-rw-r--r--  1 root root 1090 jan 15 09:12 index.html'
      ]
    },
    {
      command: 'whoami',
      output: ['noe']
    },
    {
      command: 'netstat -tulpn | grep LISTEN',
      output: [
        'tcp   0   0 0.0.0.0:22      0.0.0.0:*      LISTEN      1234/sshd',
        'tcp6  0   0 :::80           :::*           LISTEN      1987/apache2'
      ]
    },
    {
      command: 'systemctl status apache2',
      output: [
        '● apache2.service - The Apache HTTP Server',
        '     Loaded: loaded (/lib/systemd/system/apache2.service; enabled)',
        '     Active: active (running)',
        '   Main PID: 1987 (apache2)'
      ]
    },
    {
      command: 'cat /etc/os-release | grep PRETTY_NAME',
      output: ['PRETTY_NAME="Kali GNU/Linux Rolling"']
    },
    {
      command: 'hydra -L users.txt -P passwords.txt ssh://10.10.0.12',
      output: [
        'Hydra v9.5 (c) 2024 - by van Hauser/THC & David Maciejak',
        '[DATA] max 16 tasks per 1 server, overall 16 tasks, 1 login tries (l:1/p:1), ~0 tries per task',
        '[STATUS] attack finished for 10.10.0.12 (valid pair found)'
      ]
    }
  ];

  const MAX_LINES = 18;
  const PROMPT = 'kali@noe:~$';
  const cursor = document.createElement('span');
  cursor.className = 'terminal-cursor';
  cursor.setAttribute('aria-hidden', 'true');

  let previousIndex = -1;

  const randomBetween = (min, max) => Math.random() * (max - min) + min;

  const trimHistory = () => {
    while (terminal.children.length > MAX_LINES) {
      const first = terminal.firstElementChild;
      if (!first) break;
      if (first.contains(cursor)) {
        cursor.remove();
      }
      first.remove();
    }
  };

  const pickCommand = () => {
    if (!COMMANDS.length) {
      return { command: PROMPT, output: [] };
    }
    let index = Math.floor(Math.random() * COMMANDS.length);
    if (COMMANDS.length > 1) {
      while (index === previousIndex) {
        index = Math.floor(Math.random() * COMMANDS.length);
      }
    }
    previousIndex = index;
    return COMMANDS[index];
  };

  const appendLine = (className) => {
    const line = document.createElement('div');
    line.className = className;
    terminal.appendChild(line);
    return line;
  };

  const typeCommand = (entry) => new Promise((resolve) => {
    const line = appendLine('terminal-line');
    const promptSpan = document.createElement('span');
    promptSpan.className = 'terminal-prompt';
    promptSpan.textContent = PROMPT;

    const commandSpan = document.createElement('span');
    commandSpan.className = 'terminal-command';

    line.append(promptSpan, document.createTextNode(' '), commandSpan, cursor);
    trimHistory();
    terminal.scrollTop = terminal.scrollHeight;

    let position = 0;

    const step = () => {
      if (position < entry.command.length) {
        commandSpan.textContent += entry.command.charAt(position);
        position += 1;
        terminal.scrollTop = terminal.scrollHeight;
        const pause = entry.command.charAt(position - 1) === ' ' ? randomBetween(38, 72) : randomBetween(22, 55);
        window.setTimeout(step, pause);
      } else {
        cursor.remove();
        line.appendChild(cursor);
        resolve();
      }
    };

    step();
  });

  const renderOutput = (lines) => {
    lines.forEach((text) => {
      const outputLine = appendLine('terminal-output');
      outputLine.textContent = text;
      trimHistory();
    });
    terminal.scrollTop = terminal.scrollHeight;
  };

  const cycle = () => {
    const entry = pickCommand();
    typeCommand(entry).then(() => {
      if (Array.isArray(entry.output) && entry.output.length) {
        renderOutput(entry.output);
      }
      const pause = randomBetween(2000, 4000);
      window.setTimeout(cycle, pause);
    });
  };

  cycle();
})();
