# คู่มือติดตั้ง OpenClaw สำหรับ LINE (ภาษาไทย)
# ===========================================
# ไฟล์นี้มีคำอธิบายครบถ้วนสำหรับการเชื่อมต่อ OpenClaw กับ LINE
# บันทึกไฟล์ JSON5 นี้ที่: ~/.openclaw/openclaw.json

## ===================================
## ขั้นตอนที่ 1: ติดตั้ง LINE Plugin
## ===================================

# ผ่าน npm (แนะนำ):
openclaw plugins install @openclaw/line

# หรือติดตั้งจากโฟลเดอร์ (ถ้ารันจาก git repo):
openclaw plugins install ./extensions/line

## ===================================
## ขั้นตอนที่ 2: ตั้งค่า LINE Developers Console
## ===================================

# 1. เข้าไปที่: https://developers.line.biz/console/
# 2. สร้าง Provider (หรือใช้ที่มีอยู่)
# 3. สร้างช่องทาง "Messaging API"
# 4. คัดลอกข้อมูลจากหน้าตั้งค่าช่องทาง:
#    - Channel access token (token ระยะยาว)
#    - Channel secret
# 5. เปิดใช้งาน "Use webhook" ในการตั้งค่า Messaging API
# 6. ตั้งค่า webhook URL (ต้องเป็น HTTPS):
#    https://your-gateway-host/line/webhook

## ===================================
## ขั้นตอนที่ 3: ไฟล์ตั้งค่าหลัก (~/.openclaw/openclaw.json)
## ===================================

{
  // ตัวตนของบอท
  identity: {
    name: "ชื่อบอทของคุณ",      // ชื่อที่แสดงของบอท
    theme: "ผู้ช่วยที่เป็นประโยชน์", // บุคลิก/ธีม
    emoji: "🤖",              // อิโมจิประจำตัวบอท
  },

  // โฟลเดอร์ทำงานของ Agent
  agent: {
    workspace: "~/.openclaw/workspace",
    // ⚠️ สำคัญ: API Key สำหรับ AI Model ต้องใช้ของผู้ใช้เอง
    // รองรับ: Anthropic, OpenAI, OpenRouter, Google Gemini, หรือโมเดลอื่นๆ
    model: {
      primary: "anthropic/claude-sonnet-4-5",  // หรือโมเดลที่คุณต้องการ
    },
  },

  // การตั้งค่า Gateway
  gateway: {
    mode: "local",
    port: 18789,
    bind: "loopback",  // เปลี่ยนเป็น "0.0.0.0" ถ้าต้องการเข้าถึงจากภายนอก
    // สำหรับ LINE ต้องใช้ HTTPS webhook ใช้ Tailscale หรือ reverse proxy:
    tailscale: {
      mode: "serve",   // หรือ "funnel" สำหรับ HTTPS สาธารณะ
    },
  },

  // การตั้งค่าช่องทาง LINE
  channels: {
    line: {
      enabled: true,

      // ตัวเลือก A: ใส่ token โดยตรง (ไม่แนะนำสำหรับ production)
      // channelAccessToken: "YOUR_LINE_CHANNEL_ACCESS_TOKEN",
      // channelSecret: "YOUR_LINE_CHANNEL_SECRET",

      // ตัวเลือก B: ใช้ตัวแปรสภาพแวดล้อม (แนะนำ)
      // ตั้งค่า env vars: LINE_CHANNEL_ACCESS_TOKEN, LINE_CHANNEL_SECRET

      // ตัวเลือก C: ไฟล์ token (ดีที่สุดสำหรับ production)
      // tokenFile: "/path/to/line-token.txt",
      // secretFile: "/path/to/line-secret.txt",

      // นโยบายข้อความส่วนตัว (DM)
      // - "pairing": ผู้ใช้ได้รับรหัสจับคู่ คุณอนุมัติผ่าน CLI (ค่าเริ่มต้น)
      // - "allowlist": อนุญาตเฉพาะรายการ allowFrom
      // - "open": ใครก็ได้สามารถส่ง DM (ใช้ด้วยความระมัดระวัง)
      // - "disabled": ปิด DM
      dmPolicy: "pairing",

      // ถ้า dmPolicy เป็น "allowlist" ให้ระบุ LINE user IDs ที่อนุญาต
      // LINE user IDs มีรูปแบบ: U + 32 ตัวอักษร hex
      allowFrom: [],

      // นโยบายแชทกลุ่ม
      // - "allowlist": อนุญาตเฉพาะกลุ่มที่ระบุ
      // - "open": อนุญาตทุกกลุ่ม
      // - "disabled": ปิดแชทกลุ่ม
      groupPolicy: "allowlist",

      // LINE IDs ของกลุ่ม/ห้องที่อนุญาต
      // Group IDs: C + 32 ตัวอักษร hex
      // Room IDs: R + 32 ตัวอักษร hex
      groupAllowFrom: [],

      // การตั้งค่าแต่ละกลุ่ม
      groups: {
        // ตัวอย่าง: การตั้งค่ากลุ่มเฉพาะ
        // "C1234567890abcdef1234567890abcdef": {
        //   requireMention: true,  // บอทตอบเมื่อถูกกล่าวถึงเท่านั้น
        // },
      },

      // เส้นทาง webhook (ค่าเริ่มต้น: /line/webhook)
      // webhookPath: "/line/webhook",

      // ขีดจำกัดการดาวน์โหลดมีเดีย (MB) (ค่าเริ่มต้น: 10)
      mediaMaxMb: 10,
    },
  },

  // การตั้งค่าเครื่องมือ
  tools: {
    allow: ["read", "write", "edit", "exec", "web_search", "web_fetch"],
    elevated: {
      enabled: true,
      allowFrom: {
        line: [],  // เพิ่ม LINE user IDs ที่ใช้เครื่องมือ elevated ได้
      },
    },
  },

  // การตั้งค่าเซสชัน
  session: {
    scope: "per-sender",  // ผู้ใช้ LINE แต่ละคนมีเซสชันของตัวเอง
    reset: {
      mode: "daily",
      atHour: 4,
    },
  },

  // การบันทึกล็อก
  logging: {
    level: "info",
    consoleLevel: "info",
  },
}

## ===================================
## ขั้นตอนที่ 4: ตั้งค่าตัวแปรสภาพแวดล้อม
## ===================================

# เพิ่มลงใน ~/.bashrc, ~/.zshrc, หรือ ~/.profile:

# LINE Bot Credentials (จาก LINE Developers Console)
export LINE_CHANNEL_ACCESS_TOKEN="YOUR_CHANNEL_ACCESS_TOKEN_HERE"
export LINE_CHANNEL_SECRET="YOUR_CHANNEL_SECRET_HERE"

# ⚠️ สำคัญ: API Keys สำหรับ AI Model ต้องใช้ของผู้ใช้เอง
# เลือกใช้ผู้ให้บริการที่คุณต้องการ:

# ตัวเลือก 1: Anthropic (Claude)
export ANTHROPIC_API_KEY="sk-ant-..."

# ตัวเลือก 2: OpenAI (GPT)
export OPENAI_API_KEY="sk-..."

# ตัวเลือก 3: OpenRouter (รองรับหลายโมเดล)
export OPENROUTER_API_KEY="sk-or-..."

# ตัวเลือก 4: Google Gemini
export GEMINI_API_KEY="..."

# ตัวเลือก 5: โมเดลอื่นๆ (Groq, DeepSeek, ฯลฯ)
# export GROQ_API_KEY="gsk-..."
# export DEEPSEEK_API_KEY="sk-..."

# หมายเหตุ: คุณต้องสมัครและได้รับ API Key จากผู้ให้บริการเอง
# OpenClaw ไม่มี API Key มาให้ ผู้ใช้ต้องใช้ API Key ของตัวเอง

## ===================================
## ขั้นตอนที่ 5: การจับคู่ผู้ใช้ (ถ้าใช้ dmPolicy: "pairing")
## ===================================

# เมื่อผู้ใช้ใหม่ส่งข้อความถึงบอท พวกเขาจะได้รับรหัสจับคู่
# คุณอนุมัติผ่าน CLI:

# ดูรายการรอการจับคู่:
openclaw pairing list line

# อนุมัติผู้ใช้:
openclaw pairing approve line <รหัสจับคู่>

# ตัวอย่าง:
# openclaw pairing approve line ABC123

## ===================================
## ขั้นตอนที่ 6: การจัดการแชทกลุ่ม
## ===================================

# เพื่อรับ ID กลุ่ม/ห้อง ให้ตั้งค่า groupPolicy เป็น "open" ชั่วคราว
# ให้มีคนส่งข้อความในกลุ่ม แล้วตรวจสอบล็อก
# ID จะปรากฏในเอาต์พุตล็อก

# จากนั้นเพิ่ม ID ลงใน groupAllowFrom และเปลี่ยนกลับเป็น "allowlist"

## ===================================
## ขั้นตอนที่ 7: เริ่ม Gateway
## ===================================

# เริ่ม OpenClaw gateway:
openclaw gateway start

# หรือรันในเบื้องหลัง:
openclaw gateway start --daemon

# ตรวจสอบสถานะ:
openclaw gateway status

## ===================================
## ขั้นสูง: หลายบัญชี LINE
## ===================================

{
  channels: {
    line: {
      accounts: {
        personal: {
          channelAccessToken: "${LINE_PERSONAL_TOKEN}",
          channelSecret: "${LINE_PERSONAL_SECRET}",
          webhookPath: "/line/personal",
          dmPolicy: "pairing",
        },
        business: {
          channelAccessToken: "${LINE_BUSINESS_TOKEN}",
          channelSecret: "${LINE_BUSINESS_SECRET}",
          webhookPath: "/line/business",
          dmPolicy: "allowlist",
          allowFrom: ["Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1", "Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx2"],
        },
      },
    },
  },
}

## ===================================
## แก้ไขปัญหา
## ===================================

# 1. การยืนยัน webhook ล้มเหลว:
#    - ตรวจสอบว่า webhook URL เป็น HTTPS
#    - ตรวจสอบว่า channelSecret ตรงกับ LINE console
#    - ตรวจสอบว่า gateway เข้าถึงได้จากอินเทอร์เน็ต

# 2. ไม่ได้รับข้อความ:
#    - ตรวจสอบว่าเส้นทาง webhook ตรงกับ config
#    - ตรวจสอบว่า "Use webhook" เปิดใช้งานใน LINE console
#    - ตรวจสอบล็อก gateway: openclaw gateway logs

# 3. ไม่สามารถดาวน์โหลดมีเดีย:
#    - เพิ่ม mediaMaxMb ใน config
#    - ตรวจสอบว่าช่องทาง LINE มีสิทธิ์ที่เหมาะสม

# 4. การจับคู่ไม่ทำงาน:
#    - ตรวจสอบว่า dmPolicy เป็น "pairing"
#    - ตรวจสอบว่าผู้ใช้ส่ง DM ไม่ใช่ข้อความกลุ่ม
#    - ตรวจสอบว่ารหัสจับคู่ยังไม่หมดอายุ

## ===================================
## คำสั่งที่มีประโยชน์
## ===================================

# ดูการตั้งค่า gateway:
openclaw gateway config.get

# ตรวจสอบความถูกต้องของ config:
openclaw gateway config.schema

# ดูล็อก:
openclaw gateway logs

# รีสตาร์ท gateway:
openclaw gateway restart

# ส่งข้อความทดสอบผ่าน CLI:
openclaw message send --channel line --target "Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" "สวัสดีจาก OpenClaw!"

## ===================================
## ⚠️ หมายเหตุสำคัญเกี่ยวกับ API
## ===================================

# 1. LINE Plugin:
#    - ติดตั้งด้วย: openclaw plugins install @openclaw/line
#    - ถ้าติดตั้งไม่ได้ ตรวจสอบว่า OpenClaw อัปเดตแล้ว
#    - ใช้คำสั่ง: openclaw plugins list เพื่อดู plugin ที่ติดตั้ง

# 2. AI Model API:
#    - ผู้ใช้ต้องใช้ API Key ของตัวเอง
#    - OpenClaw ไม่มี API Key มาให้
#    - ต้องสมัครและรับ API Key จากผู้ให้บริการที่เลือก
#    - รองรับ: Anthropic, OpenAI, OpenRouter, Google, Groq, DeepSeek, และอื่นๆ

# 3. การตั้งค่าโมเดล:
#    - แก้ไขในส่วน agent.model.primary
#    - ใช้รูปแบบ: "provider/model-name"
#    - ตัวอย่าง: "anthropic/claude-sonnet-4-5", "openai/gpt-5.2"
