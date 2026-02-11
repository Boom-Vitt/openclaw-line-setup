#!/bin/bash
# OpenClaw + LINE Setup Checker
# ใช้ตรวจสอบระบบก่อนติดตั้ง
# รันด้วย: bash setup-checker.sh

echo "=========================================="
echo "  OpenClaw + LINE Setup Checker"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0

# สีสำหรับ output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ERRORS=$((ERRORS + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

# 1. ตรวจสอบ OpenClaw
echo "[1/10] ตรวจสอบ OpenClaw..."
if command -v openclaw &> /dev/null; then
    check_pass "OpenClaw ติดตั้งแล้ว"
    openclaw --version 2>/dev/null | head -1
else
    check_fail "OpenClaw ยังไม่ติดตั้ง"
    echo "  ติดตั้งด้วย: npm install -g openclaw"
fi
echo ""

# 2. ตรวจสอบ Node.js
echo "[2/10] ตรวจสอบ Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -ge 18 ]; then
        check_pass "Node.js $(node --version)"
    else
        check_warn "Node.js $(node --version) - แนะนำ v18+"
    fi
else
    check_fail "Node.js ยังไม่ติดตั้ง"
    echo "  ดาวน์โหลดที่: https://nodejs.org"
fi
echo ""

# 3. ตรวจสอบ npm
echo "[3/10] ตรวจสอบ npm..."
if command -v npm &> /dev/null; then
    check_pass "npm $(npm --version)"
else
    check_fail "npm ยังไม่ติดตั้ง"
fi
echo ""

# 4. ตรวจสอบโฟลเดอร์ OpenClaw
echo "[4/10] ตรวจสอบโฟลเดอร์..."
if [ -d "$HOME/.openclaw" ]; then
    check_pass "พบโฟลเดอร์ ~/.openclaw"
    
    # ตรวจสอบโฟลเดอร์ย่อย
    if [ -d "$HOME/.openclaw/workspace" ]; then
        check_pass "พบ workspace/"
    else
        check_warn "ไม่พบ workspace/ - จะสร้างให้"
        mkdir -p "$HOME/.openclaw/workspace"
    fi
else
    check_warn "ไม่พบโฟลเดอร์ ~/.openclaw - จะสร้างให้"
    mkdir -p "$HOME/.openclaw/workspace" "$HOME/.openclaw/sessions" "$HOME/.openclaw/cron"
fi
echo ""

# 5. ตรวจสอบ Plugin LINE
echo "[5/10] ตรวจสอบ Plugin LINE..."
if command -v openclaw &> /dev/null; then
    if openclaw plugins list 2>/dev/null | grep -q "line"; then
        check_pass "Plugin LINE ติดตั้งแล้ว"
    else
        check_warn "Plugin LINE ยังไม่ติดตั้ง"
        echo "  ติดตั้งด้วย: openclaw plugins install @openclaw/line"
    fi
else
    check_warn "ข้ามการตรวจสอบ Plugin (OpenClaw ยังไม่ติดตั้ง)"
fi
echo ""

# 6. ตรวจสอบ Config
echo "[6/10] ตรวจสอบไฟล์ Config..."
if [ -f "$HOME/.openclaw/openclaw.json" ]; then
    check_pass "พบไฟล์ openclaw.json"
    
    # ลอง validate
    if command -v openclaw &> /dev/null; then
        if openclaw gateway config.schema &> /dev/null; then
            check_pass "Config ถูกต้อง"
        else
            check_fail "Config มีข้อผิดพลาด"
            echo "  รันด้วย: openclaw gateway config.schema"
        fi
    fi
else
    check_warn "ไม่พบไฟล์ openclaw.json"
    echo "  ต้องสร้างไฟล์ config - ดูตัวอย่างที่ config-simple.json"
fi
echo ""

# 7. ตรวจสอบ Token ไฟล์
echo "[7/10] ตรวจสอบ LINE Token..."
if [ -f "$HOME/.openclaw/line-token.txt" ]; then
    check_pass "พบ line-token.txt"
    # ตรวจสอบสิทธิ์
    PERMS=$(stat -c %a "$HOME/.openclaw/line-token.txt" 2>/dev/null || stat -f %Lp "$HOME/.openclaw/line-token.txt" 2>/dev/null)
    if [ "$PERMS" = "600" ]; then
        check_pass "สิทธิ์ไฟล์ถูกต้อง (600)"
    else
        check_warn "สิทธิ์ไฟล์ควรเป็น 600 (ปัจจุบัน: $PERMS)"
        echo "  แก้ไข: chmod 600 ~/.openclaw/line-token.txt"
    fi
else
    check_warn "ไม่พบ line-token.txt"
    echo "  ต้องสร้างไฟล์นี้ใส่ LINE Channel Access Token"
fi

if [ -f "$HOME/.openclaw/line-secret.txt" ]; then
    check_pass "พบ line-secret.txt"
else
    check_warn "ไม่พบ line-secret.txt"
    echo "  ต้องสร้างไฟล์นี้ใส่ LINE Channel Secret"
fi
echo ""

# 8. ตรวจสอบ Environment Variables
echo "[8/10] ตรวจสอบ Environment Variables..."
HAS_API_KEY=false

if [ -n "$OPENROUTER_API_KEY" ]; then
    check_pass "OPENROUTER_API_KEY ตั้งค่าแล้ว"
    HAS_API_KEY=true
fi

if [ -n "$ANTHROPIC_API_KEY" ]; then
    check_pass "ANTHROPIC_API_KEY ตั้งค่าแล้ว"
    HAS_API_KEY=true
fi

if [ -n "$OPENAI_API_KEY" ]; then
    check_pass "OPENAI_API_KEY ตั้งค่าแล้ว"
    HAS_API_KEY=true
fi

if [ -n "$GEMINI_API_KEY" ]; then
    check_pass "GEMINI_API_KEY ตั้งค่าแล้ว"
    HAS_API_KEY=true
fi

if [ "$HAS_API_KEY" = false ]; then
    check_fail "ยังไม่มี AI API Key"
    echo "  ต้องสมัครและตั้งค่าอย่างน้อย 1 อัน:"
    echo "  - OpenRouter (แนะนำ): https://openrouter.ai"
    echo "  - Google Gemini (ฟรี): https://ai.google.dev"
    echo "  - Anthropic: https://console.anthropic.com"
fi
echo ""

# 9. ตรวจสอบ Port
echo "[9/10] ตรวจสอบ Port 18789..."
if command -v lsof &> /dev/null; then
    if lsof -i :18789 &> /dev/null; then
        check_warn "Port 18789 ถูกใช้งานอยู่"
        echo "  อาจมี OpenClaw รันอยู่แล้ว"
        echo "  ตรวจสอบ: openclaw gateway status"
    else
        check_pass "Port 18789 ว่าง"
    fi
elif command -v netstat &> /dev/null; then
    if netstat -tlnp 2>/dev/null | grep -q ":18789"; then
        check_warn "Port 18789 ถูกใช้งานอยู่"
    else
        check_pass "Port 18789 ว่าง"
    fi
else
    check_warn "ไม่สามารถตรวจสอบ port ได้ (ไม่มี lsof หรือ netstat)"
fi
echo ""

# 10. ตรวจสอบสิทธิ์
echo "[10/10] ตรวจสอบสิทธิ์โฟลเดอร์..."
if [ -d "$HOME/.openclaw" ]; then
    OWNER=$(stat -c %U "$HOME/.openclaw" 2>/dev/null || stat -f %Su "$HOME/.openclaw" 2>/dev/null)
    if [ "$OWNER" = "$(whoami)" ]; then
        check_pass "เจ้าของโฟลเดอร์ถูกต้อง"
    else
        check_warn "เจ้าของโฟลเดอร์คือ $OWNER (ควรเป็น $(whoami))"
        echo "  แก้ไข: chown -R $(whoami):$(whoami) ~/.openclaw"
    fi
fi
echo ""

# สรุป
echo "=========================================="
echo "  สรุปผลการตรวจสอบ"
echo "=========================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ ระบบพร้อมใช้งาน!${NC}"
    echo ""
    echo "คุณสามารถเริ่มใช้งานได้ด้วยคำสั่ง:"
    echo "  openclaw gateway start"
    echo ""
    echo "จากนั้นตั้งค่า Webhook ใน LINE Console:"
    echo "  URL: http://localhost:18789/line/webhook"
    echo "  (ต้องใช้ HTTPS สำหรับ production)"
    
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ พบข้อควรระวัง $WARNINGS รายการ${NC}"
    echo ""
    echo "แก้ไขข้อควรระวังแล้วลองรันอีกครั้ง"
    echo "ส่วนใหญ่แก้ไขได้ด้วยการสร้างไฟล์ที่ขาดหาย"
    
else
    echo -e "${RED}✗ พบข้อผิดพลาด $ERRORS รายการ${NC}"
    echo -e "${YELLOW}⚠ พบข้อควรระวัง $WARNINGS รายการ${NC}"
    echo ""
    echo "แก้ไขข้อผิดพลาดตามคำแนะนำด้านบนก่อนเริ่มใช้งาน"
fi

echo ""
echo "=========================================="
echo "  ขั้นตอนถัดไป"
echo "=========================================="
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "1. แก้ไขข้อผิดพลาดที่พบ"
fi

echo "2. สมัคร LINE Developers: https://developers.line.biz/console/"
echo "3. สร้างไฟล์ ~/.openclaw/line-token.txt (ใส่ Channel Access Token)"
echo "4. สร้างไฟล์ ~/.openclaw/line-secret.txt (ใส่ Channel Secret)"
echo "5. สมัคร OpenRouter: https://openrouter.ai (หรือผู้ให้บริการอื่น)"
echo "6. ตั้งค่า OPENROUTER_API_KEY ใน ~/.bashrc"
echo "7. คัดลอก config-simple.json ไปที่ ~/.openclaw/openclaw.json"
echo "8. รัน: openclaw gateway start"
echo ""
echo "ดูคู่มือฉบับเต็ม: LINE_SETUP_THAI_COMPLETE.md"
echo ""
