# แก้ไขปัญหา Gateway ไม่ทำงาน (ฉบับละเอียด)
# ============================================

# เอกสารนี้รวมวิธีแก้ไขปัญหา Gateway ทั้งหมด
# ใช้เมื่อคุณไม่สามารถเชื่อมต่อ OpenClaw ได้

# ============================================
# 🔴 ปัญหายอดนิยม: Gateway ไม่เริ่มต้น
# ============================================

## อาการที่ 1: รันคำสั่งแล้วไม่มีอะไรเกิดขึ้น

```bash
$ openclaw gateway start
# ไม่มี output อะไรเลย หรือค้างอยู่
```

### วิธีตรวจสอบ:

# 1. รันแบบ verbose เพื่อดู error
openclaw gateway start --verbose

# 2. ตรวจสอบว่ามี process รันอยู่แล้วหรือไม่
ps aux | grep openclaw

# 3. ตรวจสอบ port ถูกใช้งานหรือไม่
lsof -i :18789
netstat -tlnp | grep 18789
ss -tlnp | grep 18789

# ถ้ามี process อื่นใช้ port 18789:
# วิธีแก้: เปลี่ยน port ใน config
# แก้ไขไฟล์ ~/.openclaw/openclaw.json
# "port": 18790  # ใช้ port อื่น

# หรือ kill process ที่ใช้ port:
kill -9 <PID>  # PID จากคำสั่ง lsof

---

## อาการที่ 2: Error "Cannot find module"

```
Error: Cannot find module '@openclaw/line'
```

### วิธีแก้ไข:

# 1. ติดตั้ง plugin ใหม่
openclaw plugins remove @openclaw/line
openclaw plugins install @openclaw/line

# 2. ถ้ายังไม่ได้ ลอง install แบบ global
npm install -g @openclaw/line

# 3. หรือใช้ local path
git clone https://github.com/openclaw/openclaw.git
openclaw plugins install ./openclaw/extensions/line

# 4. ตรวจสอบว่าติดตั้งสำเร็จ
openclaw plugins list
# ต้องเห็น "@openclaw/line" ในรายการ

---

## อาการที่ 3: Error "Invalid configuration"

```
Error: Invalid configuration
Schema validation failed
```

### วิธีแก้ไข:

# 1. ตรวจสอบว่าเป็น JSON5 ที่ถูกต้อง
# - ไม่มี comma เกินหลังบรรทัดสุดท้าย
# - ใช้ double quotes ครอบ key
# - comment ใช้ // หรือ /* */

# 2. ใช้เครื่องมือตรวจสอบ
openclaw gateway config.schema

# 3. ถ้าไม่บอกตำแหน่ง error ให้ลองดู config ที่ใช้
openclaw gateway config.get

# 4. ตัวอย่าง config ที่ถูกต้อง (ดูใน config-simple.json)

---

# ============================================
# 🔴 ปัญหายอดนิยม: Gateway เริ่มแล้วแต่เข้าไม่ได้
# ============================================

## อาการที่ 4: "Connection refused" หรือไม่สามารถเชื่อมต่อได้

```bash
$ curl http://localhost:18789
curl: (7) Failed to connect to localhost port 18789: Connection refused
```

### วิธีตรวจสอบ:

# 1. ตรวจสอบว่ากำลังรันอยู่
openclaw gateway status

# 2. ดู log ล่าสุด
tail -50 ~/.openclaw/openclaw.log

# 3. ตรวจสอบว่า bind ถูกต้อง
# ใน config ถ้าตั้งค่า bind: "loopback" → เข้าได้เฉพาะจากเครื่องนั้น
# ถ้าต้องการเข้าจากภายนอก → เปลี่ยนเป็น bind: "0.0.0.0"

# 4. ตรวจสอบ Firewall
# Linux (ufw):
sudo ufw status
sudo ufw allow 18789/tcp

# Linux (iptables):
sudo iptables -L | grep 18789
sudo iptables -A INPUT -p tcp --dport 18789 -j ACCEPT

# macOS:
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add openclaw

# 5. ตรวจสอบ SELinux (ถ้าใช้ CentOS/RHEL)
sestatus
sudo setsebool -P httpd_can_network_connect 1

---

## อาการที่ 5: Permission Denied

```
EACCES: permission denied, open '/root/.openclaw/...'
```

### วิธีแก้ไข:

# 1. ตรวจสอบเจ้าของโฟลเดอร์
ls -la ~/.openclaw/

# 2. แก้ไขสิทธิ์ (รันด้วย user ปกติ ไม่ใช่ root)
chown -R $(whoami):$(whoami) ~/.openclaw
chmod -R 755 ~/.openclaw

# 3. สำหรับไฟล์ token (ควรมีสิทธิ์ 600)
chmod 600 ~/.openclaw/line-token.txt
chmod 600 ~/.openclaw/line-secret.txt

# 4. ถ้ารันด้วย root แล้วมีปัญหา
# ควรรันด้วย user ปกติ หรือตั้งค่า:
export OPENCLAW_WORKSPACE="/home/username/.openclaw/workspace"

---

# ============================================
# 🔴 ปัญหา Webhook (สำคัญมากสำหรับ LINE)
# ============================================

## อาการที่ 6: LINE Webhook Verification Failed

# ใน LINE Console ขึ้น "Verification failed"
# หรือ "Connection timeout"

### สาเหตุหลัก: LINE ต้องการ HTTPS เท่านั้น

# วิธีแก้ไขมีหลายแบบ:

# ============================================
# วิธีที่ 1: ใช้ Tailscale (ง่ายที่สุด - แนะนำ)
# ============================================

# 1. สมัคร Tailscale: https://tailscale.com (ฟรี)
# 2. ติดตั้ง Tailscale บนเครื่อง:
#    - Linux: curl -fsSL https://tailscale.com/install.sh | sh
#    - macOS: ดาวน์โหลดจากเว็บ
#    - Windows: ดาวน์โหลด installer

# 3. เข้าสู่ระบบ Tailscale
sudo tailscale up

# 4. แก้ไข config OpenClaw
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "loopback",
    "tailscale": {
      "mode": "serve"  // หรือ "funnel" ถ้าต้องการ public
    }
  }
}

# 5. รัน OpenClaw
openclaw gateway start

# 6. ดู URL ที่ได้
# Tailscale จะให้ URL แบบ https://your-machine.tailnet-xxxx.ts.net
# เอา URL นี้ไปใส่ใน LINE Console + "/line/webhook"
# ตัวอย่าง: https://myserver.tailnet-1234.ts.net/line/webhook

---

# ============================================
# วิธีที่ 2: ใช้ ngrok (ชั่วคราว สำหรับทดสอบ)
# ============================================

# 1. สมัคร ngrok: https://ngrok.com
# 2. ติดตั้ง ngrok
# 3. ตั้งค่า auth token
ngrok config add-authtoken YOUR_TOKEN

# 4. รัน OpenClaw ก่อน (port 18789)
openclaw gateway start

# 5. เปิด terminal อีกอัน รัน ngrok
ngrok http 18789

# 6. ngrok จะแสดง URL HTTPS เช่น https://xxxx.ngrok.io
# เอาไปใส่ใน LINE Console: https://xxxx.ngrok.io/line/webhook

# ⚠️ ข้อเสีย: URL เปลี่ยนทุกครั้งที่รัน ngrok ใหม่

---

# ============================================
# วิธีที่ 3: ใช้ Cloudflare Tunnel
# ============================================

# 1. สมัคร Cloudflare: https://dash.cloudflare.com
# 2. ติดตั้ง cloudflared
#    Linux: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/

# 3. Login
cloudflared tunnel login

# 4. สร้าง tunnel
cloudflared tunnel create openclaw

# 5. รัน tunnel (เปิด terminal อีกอัน)
cloudflared tunnel run openclaw

# 6. Config tunnel ให้ชี้ไปที่ localhost:18789
# แก้ไข ~/.cloudflared/config.yml

---

# ============================================
# วิธีที่ 4: ใช้ Reverse Proxy (สำหรับ VPS/Server)
# ============================================

# ถ้าคุณมี VPS หรือ Server จริง ใช้ nginx หรือ caddy

# --- ตัวอย่าง nginx ---
# /etc/nginx/sites-available/openclaw

server {
    listen 443 ssl;
    server_name your-domain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location /line/webhook {
        proxy_pass http://127.0.0.1:18789;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# --- ตัวอย่าง Caddy (ง่ายกว่า) ---
# Caddyfile

your-domain.com {
    reverse_proxy /line/webhook localhost:18789
}

---

# ============================================
# 🔴 ปัญหา Plugin ไม่ทำงาน
# ============================================

## อาการที่ 7: Plugin LINE ไม่โหลด

### วิธีตรวจสอบ:

# 1. ตรวจสอบว่าติดตั้งจริง
openclaw plugins list
# ต้องเห็น @openclaw/line

# 2. ตรวจสอบ log ตอนเริ่ม
openclaw gateway start --verbose 2>&1 | grep -i line

# 3. ตรวจสอบว่า enabled ใน config
# "channels": {
#   "line": {
#     "enabled": true
#   }
# }

# 4. ถ้ายังไม่ได้ ลอง reinstall
rm -rf ~/.openclaw/plugins/line
openclaw plugins install @openclaw/line

# 5. ถ้าใช้ npm ติดตั้ง ลองดูว่า install ที่ไหน
npm list -g @openclaw/line
# หรือ
npm list @openclaw/line

---

# ============================================
# 🔴 ปัญหาอื่นๆ
# ============================================

## อาการที่ 8: "Address already in use" แต่ไม่มี process ไหนใช้

# วิธีแก้:
# รอสักครู่ (60 วินาที) ให้ OS release port
# หรือใช้ port อื่น

## อาการที่ 9: Gateway รันแล้วแต่ตอบช้ามาก

# วิธีแก้:
# 1. ตรวจสอบ log ว่ามี error ซ้ำๆ หรือไม่
# 2. ตรวจสอบการใช้ RAM/CPU
top
htop

# 3. อาจต้อง restart
openclaw gateway restart

## อาการที่ 10: "EMFILE: too many open files"

# วิธีแก้:
# เพิ่ม limit ไฟล์
ulimit -n 4096

# หรือแก้ไข /etc/security/limits.conf
# * soft nofile 4096
# * hard nofile 4096

---

# ============================================
# 🛠️ เครื่องมือช่วย Debug
# ============================================

# 1. รัน checker script
bash setup-checker.sh

# 2. ดู log แบบ realtime
tail -f ~/.openclaw/openclaw.log | grep -E "(error|ERROR|warn|WARN)"

# 3. ทดสอบ webhook ด้วย curl
# ส่ง POST ไปที่ webhook (ทดสอบว่า gateway ตอบหรือไม่)
curl -X POST http://localhost:18789/line/webhook \
  -H "Content-Type: application/json" \
  -d '{"events":[]}'

# 4. ตรวจสอบว่า port เปิดจริง
nc -zv localhost 18789

# 5. ดู process ที่ใช้ port
fuser 18789/tcp

# 6. รัน gateway แบบ debug mode
DEBUG=* openclaw gateway start

---

# ============================================
# 📝 Checklist ก่อนถามช่วยเหลือ
# ============================================

# ก่อนถามในชุมชน ให้เตรียมข้อมูลต่อไปนี้:

# 1. รันคำสั่งนี้แล้ว copy ผลลัพธ์
openclaw gateway status 2>&1
openclaw --version 2>&1

# 2. ส่วนล่าสุดของ log (ลบข้อมูลส่วนตัวก่อน)
tail -50 ~/.openclaw/openclaw.log

# 3. สรุปสิ่งที่ลองแล้ว
# - ติดตั้งยังไง
# - error อะไร
# - ลองแก้ไขอะไรไปบ้าง

# 4. สภาพแวดล้อม
# - OS: Ubuntu 22.04 / macOS / อื่นๆ
# - Node.js version: node --version
# - รันที่ไหน: Local / VPS / Cloud

---

# ============================================
# 🆘 ติดต่อขอความช่วยเหลือ
# ============================================

# Discord: https://discord.com/invite/clawd
# GitHub Issues: https://github.com/openclaw/openclaw/issues
# เอกสาร: https://docs.openclaw.ai

# ข้อมูลที่ควรแจ้ง:
# 1. รายละเอียด error ที่เจอ
# 2. ผลจาก setup-checker.sh
# 3. ส่วนท้ายของ log file
# 4. สภาพแวดล้อมที่ใช้ (OS, Node version)
