# คู่มือติดตั้ง OpenClaw + LINE แบบสมบูรณ์ (ภาษาไทย)
# ===================================================
# ไฟล์นี้รวมทุกอย่างที่ต้องการ ตั้งแต่ติดตั้งจะแก้ไขปัญหา
# สร้าง: 2024-02-10

# ===========================================
# 📋 สารบัญ
# ===========================================
# 1. ไฟล์สำหรับดาวน์โหลด/คัดลอก
# 2. ตรวจสอบก่อนเริ่มต้น (Pre-flight Check)
# 3. ขั้นตอนการติดตั้งแบบละเอียด
# 4. ไฟล์ Config พร้อมใช้งาน
# 5. การแก้ไขปัญหา Gateway
# 6. การแก้ไขปัญหา LINE
# 7. คำสั่งตรวจสอบระบบ
# 8. Checklist ก่อนใช้งาน

# ===========================================
# 1. ไฟล์สำหรับดาวน์โหลด/คัดลอก
# ===========================================

# 📁 ไฟล์ที่ต้องสร้าง:
#
# ~/.openclaw/openclaw.json          ← ไฟล์ตั้งค่าหลัก
# ~/.openclaw/line-token.txt         ← เก็บ LINE Token (ปลอดภัยกว่า)
# ~/.openclaw/line-secret.txt        ← เก็บ LINE Secret (ปลอดภัยกว่า)
# ~/.openclaw/.env                   ← เก็บ Environment Variables
#
# สร้างโฟลเดอร์ก่อน:
# mkdir -p ~/.openclaw/workspace

# ===========================================
# 2. ตรวจสอบก่อนเริ่มต้น (Pre-flight Check)
# ===========================================

# รันคำสั่งเหล่านี้ก่อนเพื่อตรวจสอบระบบ:

# 2.1 ตรวจสอบ OpenClaw ติดตั้งแล้วหรือไม่
which openclaw
openclaw --version

# 2.2 ตรวจสอบ Node.js (ต้องมี v18+)
node --version

# 2.3 ตรวจสอบ npm
npm --version

# 2.4 ตรวจสอบสิทธิ์ในโฟลเดอร์
ls -la ~/.openclaw/

# ถ้าไม่มีโฟลเดอร์ ให้สร้าง:
# mkdir -p ~/.openclaw/workspace ~/.openclaw/sessions ~/.openclaw/cron

# ===========================================
# 3. ขั้นตอนการติดตั้งแบบละเอียด
# ===========================================

# ----- ขั้นตอนที่ 1: ติดตั้ง LINE Plugin -----
# วิธีที่ 1: ติดตั้งจาก npm (แนะนำ)
openclaw plugins install @openclaw/line

# วิธีที่ 2: ถ้าติดตั้งไม่ได้ ลองใช้ local
# git clone https://github.com/openclaw/openclaw.git
# openclaw plugins install ./openclaw/extensions/line

# ตรวจสอบว่าติดตั้งสำเร็จ:
openclaw plugins list
# ต้องเห็น "@openclaw/line" ในรายการ

# ----- ขั้นตอนที่ 2: สมัคร LINE Developers -----
# 1. ไปที่: https://developers.line.biz/console/
# 2. เข้าสู่ระบบด้วย LINE Account
# 3. คลิก "Create Provider" → ตั้งชื่อ เช่น "MyOpenClawBot"
# 4. คลิก "Create Channel" → เลือก "Messaging API"
# 5. กรอกข้อมูล:
#    - Channel name: ชื่อบอท
#    - Channel description: รายละเอียด
#    - Category: ความบันเทิง หรือ อื่นๆ
#    - Subcategory: Chatbot
# 6. ยอมรับข้อกำหนด → คลิก "Create"
# 7. ไปที่แท็บ "Messaging API"
# 8. คัดลอก:
#    - Channel secret (อยู่ด้านบน)
#    - Channel access token (คลิก "Issue" ถ้ายังไม่มี)

# ----- ขั้นตอนที่ 3: สมัคร AI API -----
# ⚠️ สำคัญ: ต้องสมัครและใช้ API Key ของตัวเอง
#
# ตัวเลือก 1: OpenRouter (ฟรีมี quota, ง่ายที่สุด)
# - https://openrouter.ai/
# - สมัคร → ไปที่ Keys → Create Key
#
# ตัวเลือก 2: Google Gemini (ฟรีมี quota)
# - https://ai.google.dev/
# - สมัคร → สร้าง API Key
#
# ตัวเลือก 3: Anthropic (Claude) - ต้องเติมเงิน
# - https://console.anthropic.com/
#
# ตัวเลือก 4: OpenAI (GPT) - ต้องเติมเงิน
# - https://platform.openai.com/

# ----- ขั้นตอนที่ 4: สร้างไฟล์ Token -----
# วิธีนี้ปลอดภัยกว่าใส่ใน config โดยตรง

# สร้างไฟล์เก็บ LINE Token
echo "YOUR_LINE_CHANNEL_ACCESS_TOKEN" > ~/.openclaw/line-token.txt
echo "YOUR_LINE_CHANNEL_SECRET" > ~/.openclaw/line-secret.txt

# ตั้งค่าสิทธิ์ (อ่านได้เฉพาะเจ้าของ)
chmod 600 ~/.openclaw/line-token.txt ~/.openclaw/line-secret.txt

# ----- ขั้นตอนที่ 5: ตั้งค่า Environment Variables -----
# เพิ่มลงใน ~/.bashrc หรือ ~/.zshrc:

cat >> ~/.bashrc << 'EOF'

# === OpenClaw Configuration ===
export OPENCLAW_WORKSPACE="$HOME/.openclaw/workspace"

# AI Model API (เลือกอย่างใดอย่างหนึ่ง)
export OPENROUTER_API_KEY="sk-or-v1-XXXXXXXXXXXXXXXXXXXX"
# export ANTHROPIC_API_KEY="sk-ant-..."
# export OPENAI_API_KEY="sk-..."
# export GEMINI_API_KEY="..."

# PATH
export PATH="$PATH:$HOME/.openclaw/bin"
EOF

# โหลดการตั้งค่าใหม่
source ~/.bashrc

# ----- ขั้นตอนที่ 6: สร้างไฟล์ Config -----
# ดูไฟล์ตัวอย่างในส่วนที่ 4 ด้านล่าง

# ----- ขั้นตอนที่ 7: ตรวจสอบ Config -----
openclaw gateway config.schema

# ----- ขั้นตอนที่ 8: เริ่ม Gateway -----
openclaw gateway start

# หรือรันแบบ debug เพื่อดู error:
openclaw gateway start --verbose

# ===========================================
# 4. ไฟล์ Config พร้อมใช้งาน (คัดลอกได้เลย)
# ===========================================

# ----- ไฟล์ A: สำหรับมือใหม่ (ง่ายที่สุด) -----
# บันทึกที่: ~/.openclaw/openclaw.json

{
  // ตัวตนของบอท
  identity: {
    name: "MyLineBot",
    theme: "ผู้ช่วยอัจฉริยะ",
    emoji: "🤖",
  },

  // AI Model - ใช้ OpenRouter (ง่ายที่สุด)
  agent: {
    workspace: "~/.openclaw/workspace",
    model: {
      primary: "openrouter/google/gemini-2.0-flash",  // ฟรีมี quota
    },
  },

  // สภาพแวดล้อม
  env: {
    OPENROUTER_API_KEY: "${OPENROUTER_API_KEY}",
  },

  // Gateway
  gateway: {
    mode: "local",
    port: 18789,
    bind: "loopback",
    controlUi: {
      enabled: true,
      basePath: "/openclaw",
    },
  },

  // LINE
  channels: {
    line: {
      enabled: true,
      tokenFile: "~/.openclaw/line-token.txt",
      secretFile: "~/.openclaw/line-secret.txt",
      dmPolicy: "pairing",
      mediaMaxMb: 10,
    },
  },

  // เซสชัน
  session: {
    scope: "per-sender",
    reset: {
      mode: "daily",
      atHour: 4,
    },
  },

  // ล็อก
  logging: {
    level: "info",
    consoleLevel: "info",
    file: "~/.openclaw/openclaw.log",
  },
}

# ----- ไฟล์ B: สำหรับใช้กับ Tailscale (แนะนำ) -----
# ใช้ถ้าคุณมี Tailscale (https://tailscale.com) - ฟรี
# Tailscale ช่วยให้ได้ HTTPS แบบง่าย

{
  identity: {
    name: "MyLineBot",
    theme: "ผู้ช่วยอัจฉริยะ",
    emoji: "🤖",
  },

  agent: {
    workspace: "~/.openclaw/workspace",
    model: {
      primary: "openrouter/google/gemini-2.0-flash",
    },
  },

  env: {
    OPENROUTER_API_KEY: "${OPENROUTER_API_KEY}",
  },

  gateway: {
    mode: "local",
    port: 18789,
    bind: "loopback",
    controlUi: {
      enabled: true,
      basePath: "/openclaw",
    },
    // Tailscale ช่วยให้ LINE เข้าถึง webhook ได้
    tailscale: {
      mode: "serve",  // หรือ "funnel" ถ้าต้องการ public
    },
  },

  channels: {
    line: {
      enabled: true,
      tokenFile: "~/.openclaw/line-token.txt",
      secretFile: "~/.openclaw/line-secret.txt",
      dmPolicy: "pairing",
      mediaMaxMb: 10,
    },
  },

  session: {
    scope: "per-sender",
    reset: {
      mode: "daily",
      atHour: 4,
    },
  },

  logging: {
    level: "info",
    consoleLevel: "info",
    file: "~/.openclaw/openclaw.log",
  },
}

# ----- ไฟล์ C: สำหรับ Cloud/VPS (Public) -----
# ใช้ถ้ารันบน VPS ที่มี Public IP

{
  identity: {
    name: "MyLineBot",
    theme: "ผู้ช่วยอัจฉริยะ",
    emoji: "🤖",
  },

  agent: {
    workspace: "~/.openclaw/workspace",
    model: {
      primary: "openrouter/google/gemini-2.0-flash",
    },
  },

  env: {
    OPENROUTER_API_KEY: "${OPENROUTER_API_KEY}",
  },

  gateway: {
    mode: "local",
    port: 18789,
    bind: "0.0.0.0",  // รับจากทุก IP
    controlUi: {
      enabled: true,
      basePath: "/openclaw",
    },
    // ใช้ Auth Token ป้องกัน
    auth: {
      mode: "token",
      token: "your-secret-token-here",
    },
  },

  channels: {
    line: {
      enabled: true,
      tokenFile: "~/.openclaw/line-token.txt",
      secretFile: "~/.openclaw/line-secret.txt",
      dmPolicy: "pairing",
      mediaMaxMb: 10,
    },
  },

  session: {
    scope: "per-sender",
    reset: {
      mode: "daily",
      atHour: 4,
    },
  },

  logging: {
    level: "info",
    consoleLevel: "info",
    file: "~/.openclaw/openclaw.log",
  },
}

# ===========================================
# 5. การแก้ไขปัญหา Gateway (ละเอียด)
# ===========================================

# ----- ปัญหา 1: Gateway ไม่เริ่มต้น -----

# อาการ: รัน openclaw gateway start แล้วไม่มีอะไรเกิดขึ้น
# หรือขึ้น error ทันที

# ตรวจสอบ:
# 1. ตรวจสอบ config
openclaw gateway config.schema

# 2. ดู error ละเอียด
openclaw gateway start --verbose

# 3. ตรวจสอบ port ถูกใช้งานหรือไม่
lsof -i :18789
# หรือ
netstat -tlnp | grep 18789

# ถ้ามี process อื่นใช้ port 18789:
# แก้ไข: เปลี่ยน port ใน config
# "port": 18790  # ใช้ port อื่น

# หรือ kill process ที่ใช้ port นั้น:
# kill -9 <PID>

# ----- ปัญหา 2: Config ผิดพลาด -----

# อาการ: "Error: Invalid configuration" หรือ "Schema validation failed"

# แก้ไข:
# 1. ตรวจสอบ JSON5 ว่าถูกต้อง
# - ไม่มี comma เกินหลังบรรทัดสุดท้ายของ object
# - ไม่มี comment ใน JSON ปกติ (ใช้ JSON5 จึงมี comment ได้)

# 2. ใช้คำสั่งตรวจสอบ:
openclaw gateway config.get

# 3. ดูตำแหน่ง config file:
openclaw gateway config.get --raw

# ----- ปัญหา 3: Gateway เริ่มแล้วแต่เข้าไม่ได้ -----

# อาการ: รัน gateway แล้วแต่ไม่สามารถเชื่อมต่อได้

# ตรวจสอบ:
# 1. ตรวจสอบว่ากำลังรันอยู่
openclaw gateway status

# 2. ตรวจสอบ log
tail -f ~/.openclaw/openclaw.log

# 3. ตรวจสอบ bind address
# ถ้าตั้งค่า bind: "loopback" → เข้าได้เฉพาะจากเครื่องนั้น
# ถ้าต้องการเข้าจากภายนอก → เปลี่ยนเป็น bind: "0.0.0.0"

# 4. ตรวจสอบ Firewall
sudo ufw status
# หรือ
sudo iptables -L | grep 18789

# เปิด port:
sudo ufw allow 18789/tcp

# ----- ปัญหา 4: Webhook ไม่ทำงาน -----

# อาการ: LINE ไม่สามารถส่ง webhook มาที่ gateway ได้

# ตรวจสอบขั้นตอนต่อไปนี้:

# 1. ตรวจสอบว่า Gateway เปิด HTTPS หรือไม่
# LINE ต้องการ HTTPS เท่านั้น

# วิธีแก้:
# - ใช้ Tailscale (ง่ายที่สุด): https://tailscale.com
# - ใช้ ngrok (ชั่วคราว): https://ngrok.com
# - ใช้ Cloudflare Tunnel
# - ใช้ Reverse Proxy (nginx, caddy)

# 2. ตรวจสอบ URL ที่ตั้งค่าใน LINE Console
# ต้องตรงกับ webhookPath ใน config

# 3. ตรวจสอบว่า URL เข้าถึงได้จากอินเทอร์เน็ต
# ใช้ https://httpbin.org/get หรือ curl จากเครื่องอื่น

# ----- ปัญหา 5: Permission Denied -----

# อาการ: "EACCES: permission denied" หรือ cannot write to directory

# แก้ไข:
# 1. ตรวจสอบสิทธิ์โฟลเดอร์
ls -la ~/.openclaw/

# 2. แก้ไขสิทธิ์
chmod -R 755 ~/.openclaw
chmod 600 ~/.openclaw/line-token.txt ~/.openclaw/line-secret.txt

# 3. ตรวจสอบเจ้าของโฟลเดอร์
chown -R $(whoami):$(whoami) ~/.openclaw

# ----- ปัญหา 6: Plugin ไม่โหลด -----

# อาการ: "Plugin @openclaw/line not found" หรือ channel line ไม่ทำงาน

# แก้ไข:
# 1. ตรวจสอบว่าติดตั้งแล้ว
openclaw plugins list

# 2. ติดตั้งใหม่
openclaw plugins remove @openclaw/line
openclaw plugins install @openclaw/line

# 3. ตรวจสอบ log ตอนเริ่ม gateway
openclaw gateway start --verbose 2>&1 | grep -i line

# 4. ตรวจสอบว่า enabled: true ใน config

# ===========================================
# 6. การแก้ไขปัญหา LINE (ละเอียด)
# ===========================================

# ----- ปัญหา 1: Webhook Verification Failed -----

# อาการ: LINE Console ขึ้น "Verification failed"

# สาเหตุและแก้ไข:
# 1. Channel Secret ไม่ตรง
#    - ตรวจสอบใน line-secret.txt ว่าตรงกับ LINE Console

# 2. URL ไม่ใช่ HTTPS
#    - LINE บังคับใช้ HTTPS เท่านั้น
#    - ใช้ Tailscale, ngrok, หรือ reverse proxy

# 3. Webhook path ไม่ตรง
#    - ตรวจสอบว่า URL ตั้งค่าใน LINE Console ตรงกับ config
#    - ค่าเริ่มต้น: /line/webhook

# ----- ปัญหา 2: ไม่ได้รับข้อความ -----

# อาการ: ส่งข้อความใน LINE แต่บอทไม่ตอบ

# ตรวจสอบ:
# 1. ดู log
 tail -f ~/.openclaw/openclaw.log | grep -i line

# 2. ตรวจสอบว่า "Use webhook" เปิดอยู่ใน LINE Console

# 3. ตรวจสอบ Auto-reply messages
#    - ปิด "Auto-reply messages" ใน LINE Console
#    - ปิด "Greeting messages" ถ้าไม่ต้องการ

# 4. ตรวจสอบ dmPolicy
#    - ถ้าเป็น "pairing" ต้องอนุมัติก่อนถึงจะรับข้อความได้

# ----- ปัญหา 3: ส่งข้อความไม่ได้ -----

# อาการ: บอทเห็นข้อความแต่ตอบกลับไม่ได้

# สาเหตุ:
# 1. Channel Access Token หมดอายุ
#    - ไปที่ LINE Console → สร้าง token ใหม่

# 2. บอทไม่ได้เพิ่มเป็นเพื่อน
#    - ใน LINE ต้องเพิ่มบอทเป็นเพื่อนก่อนถึงจะส่ง DM ได้

# 3. ถูกบล็อก
#    - ตรวจสอบว่าผู้ใช้ไม่ได้บล็อกบอท

# ----- ปัญหา 4: รูปภาพ/สติ๊กเกอร์ ไม่ส่ง -----

# อาการ: ส่งรูปภาพหรือสติ๊กเกอร์แล้วบอทไม่เห็น

# แก้ไข:
# 1. เพิ่ม mediaMaxMb ใน config
# "mediaMaxMb": 20  # เพิ่มจาก 10 เป็น 20 MB

# 2. ตรวจสอบสิทธิ์การเข้าถึง LINE Content API
#    - ต้องใช้ Channel Access Token ที่ถูกต้อง

# ===========================================
# 7. คำสั่งตรวจสอบระบบ (ใช้บ่อย)
# ===========================================

# ----- ชุดคำสั่งตรวจสอบเบื้องต้น -----
#!/bin/bash
# บันทึกเป็น check-openclaw.sh แล้วรัน

echo "=== OpenClaw System Check ==="
echo ""

echo "1. ตรวจสอบ OpenClaw..."
if command -v openclaw &> /dev/null; then
    echo "   ✓ OpenClaw ติดตั้งแล้ว"
    openclaw --version
else
    echo "   ✗ OpenClaw ยังไม่ติดตั้ง"
fi
echo ""

echo "2. ตรวจสอบ Node.js..."
node --version
echo ""

echo "3. ตรวจสอบโฟลเดอร์..."
ls -la ~/.openclaw/ 2>/dev/null || echo "   ✗ ยังไม่มีโฟลเดอร์ ~/.openclaw"
echo ""

echo "4. ตรวจสอบ Plugin LINE..."
openclaw plugins list 2>/dev/null | grep line || echo "   ✗ Plugin LINE ยังไม่ติดตั้ง"
echo ""

echo "5. ตรวจสอบ Config..."
if [ -f ~/.openclaw/openclaw.json ]; then
    echo "   ✓ พบไฟล์ config"
    openclaw gateway config.schema 2>/dev/null || echo "   ✗ Config ผิดพลาด"
else
    echo "   ✗ ยังไม่มีไฟล์ config"
fi
echo ""

echo "6. ตรวจสอบ Token ไฟล์..."
if [ -f ~/.openclaw/line-token.txt ]; then
    echo "   ✓ พบ line-token.txt"
else
    echo "   ✗ ยังไม่มี line-token.txt"
fi

if [ -f ~/.openclaw/line-secret.txt ]; then
    echo "   ✓ พบ line-secret.txt"
else
    echo "   ✗ ยังไม่มี line-secret.txt"
fi
echo ""

echo "7. ตรวจสอบ Environment Variables..."
if [ -n "$OPENROUTER_API_KEY" ]; then
    echo "   ✓ OPENROUTER_API_KEY ตั้งค่าแล้ว"
else
    echo "   ✗ OPENROUTER_API_KEY ยังไม่ตั้งค่า"
fi

echo ""
echo "=== Check Complete ==="

# ----- คำสั่งตรวจสอบ Gateway -----
# ตรวจสอบสถานะ
openclaw gateway status

# ดู log แบบ realtime
tail -f ~/.openclaw/openclaw.log

# ตรวจสอบ port
netstat -tlnp | grep openclaw

# ทดสอบเชื่อมต่อ (จากเครื่องเดียวกัน)
curl http://localhost:18789/openclaw

# ----- คำสั่งตรวจสอบ LINE -----
# ดูรายการผู้ใช้ที่รอการอนุมัติ
openclaw pairing list line

# อนุมัติผู้ใช้
openclaw pairing approve line <CODE>

# ส่งข้อความทดสอบ
openclaw message send --channel line --target "Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" "ทดสอบ"

# ===========================================
# 8. Checklist ก่อนใช้งาน
# ===========================================

# [ ] 1. ติดตั้ง OpenClaw แล้ว
# [ ] 2. ติดตั้ง Plugin LINE แล้ว (openclaw plugins list)
# [ ] 3. สร้าง LINE Bot ที่ https://developers.line.biz/console/
# [ ] 4. ได้รับ Channel Access Token และ Channel Secret
# [ ] 5. สมัคร AI API (OpenRouter, Gemini, หรืออื่นๆ)
# [ ] 6. ตั้งค่า Environment Variables
# [ ] 7. สร้างไฟล์ line-token.txt และ line-secret.txt
# [ ] 8. สร้างไฟล์ ~/.openclaw/openclaw.json
# [ ] 9. ตรวจสอบ Config ผ่าน (openclaw gateway config.schema)
# [ ] 10. เริ่ม Gateway สำเร็จ (openclaw gateway start)
# [ ] 11. ตั้งค่า Webhook URL ใน LINE Console
# [ ] 12. ยืนยัน Webhook สำเร็จใน LINE Console
# [ ] 13. เพิ่มบอทเป็นเพื่อนใน LINE
# [ ] 14. ส่งข้อความทดสอบและได้รับรหัสจับคู่
# [ ] 15. อนุมัติผู้ใช้ (openclaw pairing approve line <CODE>)
# [ ] 16. ทดสอบสนทนากับบอท

# ===========================================
# 9. ข้อมูลเพิ่มเติม
# ===========================================

# เอกสาร OpenClaw:
# https://docs.openclaw.ai/channels/line

# LINE Messaging API:
# https://developers.line.biz/en/docs/messaging-api/

# ชุมชน Discord:
# https://discord.com/invite/clawd

# GitHub:
# https://github.com/openclaw/openclaw

# ===========================================
# ตัวอย่าง: สคริปต์ติดตั้งอัตโนมัติ
# ===========================================

#!/bin/bash
# บันทึกเป็น install-openclaw-line.sh
# รันด้วย: bash install-openclaw-line.sh

set -e

echo "=== ติดตั้ง OpenClaw + LINE ==="

# สร้างโฟลเดอร์
mkdir -p ~/.openclaw/workspace ~/.openclaw/sessions ~/.openclaw/cron

# ติดตั้ง Plugin
openclaw plugins install @openclaw/line || {
    echo "ติดตั้ง Plugin ไม่สำเร็จ ลองใช้ local install"
    exit 1
}

echo ""
echo "=== ติดตั้งสำเร็จ ==="
echo ""
echo "ขั้นตอนถัดไป:"
echo "1. สร้างไฟล์ ~/.openclaw/line-token.txt"
echo "2. สร้างไฟล์ ~/.openclaw/line-secret.txt"
echo "3. ตั้งค่า OPENROUTER_API_KEY (หรือ API key อื่น)"
echo "4. คัดลอก config ไปที่ ~/.openclaw/openclaw.json"
echo "5. รัน: openclaw gateway start"
echo ""
echo "ดูคู่มือเต็มที่: LINE_SETUP_THAI_COMPLETE.md"
