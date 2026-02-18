cat > termix-store.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "======================================"
echo "      Termix Store Installer"
echo "      by ravlav (Rick000000007)"
echo "======================================"
echo ""

pkg update -y
pkg install -y nodejs

rm -rf ~/termix-store
mkdir -p ~/termix-store
cd ~/termix-store

npm init -y >/dev/null 2>&1 || true
npm i express >/dev/null 2>&1

cat > server.js <<'EOT'
const express = require("express");
const { spawn } = require("child_process");
const app = express();
const PORT = 8080;

function sh(cmd) {
  return spawn("bash", ["-lc", cmd], { stdio: ["ignore", "pipe", "pipe"] });
}

function safePkgName(x) {
  return /^[a-z0-9.+-]+$/i.test(x || "");
}

// installed list
app.get("/api/installed", (req, res) => {
  const proc = sh("pkg list-installed");
  let out = "";
  proc.stdout.on("data", d => out += d.toString());
  proc.on("close", () => {
    const installed = new Set();

    out.split("\n").forEach(line => {
      // example: curl/stable,now 8.5.0 arm [installed]
      const m = line.match(/^([a-z0-9.+-]+)\//i);
      if (m) installed.add(m[1]);
    });

    res.json({ ok: true, installed: Array.from(installed) });
  });
});

// all packages
app.get("/api/all", (req, res) => {
  // apt-cache sometimes missing, so fallback
  const proc = sh(`
    if command -v apt-cache >/dev/null 2>&1; then
      apt-cache pkgnames | sort
    else
      apt list 2>/dev/null | cut -d/ -f1 | sort -u
    fi
  `);

  let out = "";
  proc.stdout.on("data", d => out += d.toString());
  proc.on("close", () => {
    const list = out.split("\n")
      .map(x => x.trim())
      .filter(Boolean)
      .filter(safePkgName)
      .slice(0, 8000);

    res.json({ ok: true, packages: list });
  });
});

// streaming install/remove
app.get("/api/stream", (req, res) => {
  const action = (req.query.action || "").toLowerCase();
  const pkg = (req.query.pkg || "").trim();

  if (!safePkgName(pkg)) return res.status(400).send("Invalid package");
  if (!["install","remove"].includes(action)) return res.status(400).send("Invalid action");

  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");

  const send = (type, data) => {
    res.write(`event: ${type}\n`);
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  };

  const cmd = action === "install"
    ? `pkg install -y ${pkg}`
    : `pkg remove -y ${pkg}`;

  const proc = sh(cmd);

  proc.stdout.on("data", d => send("log", { text: d.toString() }));
  proc.stderr.on("data", d => send("log", { text: d.toString() }));

  proc.on("close", code => {
    send("done", { ok: code === 0, code });
    res.end();
  });
});

// UI
app.get("/", (req, res) => {
  res.send(`<!doctype html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>Termix Store</title>
<style>
body{margin:0;font-family:system-ui;background:#0b0f14;color:#e5e7eb}
header{padding:14px;background:#111827;position:sticky;top:0}
h1{margin:0;font-size:18px}
main{padding:14px;max-width:1100px;margin:0 auto}
input{width:100%;padding:12px;border-radius:12px;border:1px solid #333;background:#0b0f14;color:#fff}
.grid{margin-top:14px;display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:12px}
.card{background:#111827;border:1px solid #222;padding:12px;border-radius:16px}
button{padding:10px 12px;border-radius:12px;border:0;font-weight:800;cursor:pointer}
.install{background:#16a34a;color:white}
.remove{background:#dc2626;color:white}
pre{background:#0b0f14;border:1px solid #222;border-radius:12px;padding:10px;max-height:160px;overflow:auto;font-size:11px}
small{color:#9ca3af}
</style>
</head>
<body>
<header>
  <h1>Termix Store</h1>
  <small>GUI for Termux pkg</small>
</header>
<main>
  <input id="search" placeholder="Search package..."/>
  <div class="grid" id="grid"></div>
</main>

<script>
let all = [];
let installed = new Set();

async function loadInstalled(){
  const r = await fetch("/api/installed");
  const j = await r.json();
  installed = new Set(j.installed || []);
}

async function loadAll(){
  const r = await fetch("/api/all");
  const j = await r.json();
  all = j.packages || [];
}

function card(name){
  const c = document.createElement("div");
  c.className = "card";
  const isInstalled = installed.has(name);

  c.innerHTML = \`
    <b>\${name}</b><br/>
    <small>\${isInstalled ? "Installed ✅" : "Not installed"}</small><br/><br/>
    <button class="\${isInstalled ? "remove":"install"}">\${isInstalled ? "Remove":"Install"}</button>
    <pre style="display:none"></pre>
  \`;

  const btn = c.querySelector("button");
  const pre = c.querySelector("pre");

  btn.onclick = () => {
    pre.style.display="block";
    pre.textContent="";
    btn.disabled = true;

    const action = isInstalled ? "remove":"install";
    const es = new EventSource(\`/api/stream?action=\${action}&pkg=\${encodeURIComponent(name)}\`);

    es.addEventListener("log", e=>{
      const d = JSON.parse(e.data);
      pre.textContent += d.text;
      pre.scrollTop = pre.scrollHeight;
    });

    es.addEventListener("done", async ()=>{
      es.close();
      await init();
    });
  };

  return c;
}

function render(){
  const q = document.getElementById("search").value.trim().toLowerCase();
  const grid = document.getElementById("grid");
  grid.innerHTML = "";

  all.filter(x => !q || x.toLowerCase().includes(q))
     .slice(0, 250)
     .forEach(p => grid.appendChild(card(p)));
}

async function init(){
  await loadInstalled();
  await loadAll();
  render();
}

document.getElementById("search").oninput = render;
init();
</script>
</body>
</html>`);
});

app.listen(PORT, "127.0.0.1", () => console.log("Termix Store running: http://localhost:"+PORT));
EOT

cat > run.sh <<'EOT'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/termix-store
node server.js
EOT

chmod +x run.sh

echo ""
echo "DONE ✅"
echo "Run: cd ~/termix-store && ./run.sh"
echo "Open: http://localhost:8080"
echo ""
EOF

chmod +x termix-store.sh
