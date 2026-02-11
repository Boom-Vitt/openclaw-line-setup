# OpenClaw LINE Setup Configuration
# ==================================
# This file contains the complete setup needed for LINE integration with OpenClaw
# Save the JSON5 config to: ~/.openclaw/openclaw.json

## ===================================
## STEP 1: Install the LINE Plugin
## ===================================

# Via npm (recommended):
openclaw plugins install @openclaw/line

# Or local checkout (if running from git repo):
openclaw plugins install ./extensions/line

## ===================================
## STEP 2: LINE Developers Console Setup
## ===================================

# 1. Go to: https://developers.line.biz/console/
# 2. Create a Provider (or use existing one)
# 3. Create a "Messaging API" channel
# 4. Get these credentials from the channel settings:
#    - Channel access token (long-lived token)
#    - Channel secret
# 5. Enable "Use webhook" in Messaging API settings
# 6. Set webhook URL (must be HTTPS):
#    https://your-gateway-host/line/webhook

## ===================================
## STEP 3: Main Config File (~/.openclaw/openclaw.json)
## ===================================

{
  // Bot identity
  identity: {
    name: "YourBotName",      // Your bot's display name
    theme: "helpful assistant", // Personality/theme
    emoji: "🤖",              // Bot emoji signature
  },

  // Agent workspace
  agent: {
    workspace: "~/.openclaw/workspace",
    model: {
      primary: "anthropic/claude-sonnet-4-5",  // Or your preferred model
    },
  },

  // Gateway settings
  gateway: {
    mode: "local",
    port: 18789,
    bind: "loopback",  // Change to "0.0.0.0" if external access needed
    // For LINE, you need HTTPS webhook. Use Tailscale or a reverse proxy:
    tailscale: {
      mode: "serve",   // or "funnel" for public HTTPS
    },
  },

  // LINE Channel Configuration
  channels: {
    line: {
      enabled: true,

      // Option A: Direct token (not recommended for production)
      // channelAccessToken: "YOUR_LINE_CHANNEL_ACCESS_TOKEN",
      // channelSecret: "YOUR_LINE_CHANNEL_SECRET",

      // Option B: Environment variables (recommended)
      // Set these env vars: LINE_CHANNEL_ACCESS_TOKEN, LINE_CHANNEL_SECRET

      // Option C: Token files (best for production)
      // tokenFile: "/path/to/line-token.txt",
      // secretFile: "/path/to/line-secret.txt",

      // Direct message policy
      // - "pairing": Users get pairing code, you approve via CLI (default)
      // - "allowlist": Only allowFrom list can DM
      // - "open": Anyone can DM (use with caution)
      // - "disabled": No DMs
      dmPolicy: "pairing",

      // If dmPolicy is "allowlist", specify allowed LINE user IDs here
      // LINE user IDs look like: U + 32 hex chars (e.g., Uf4e56d7c8b9a0123456789abcdef0123)
      allowFrom: [],

      // Group chat policy
      // - "allowlist": Only specific groups allowed
      // - "open": All groups allowed
      // - "disabled": No group chats
      groupPolicy: "allowlist",

      // Allowed group/room IDs for group chats
      // Group IDs: C + 32 hex chars
      // Room IDs: R + 32 hex chars
      groupAllowFrom: [],

      // Per-group settings
      groups: {
        // Example: specific group configuration
        // "C1234567890abcdef1234567890abcdef": {
        //   requireMention: true,  // Bot only responds when mentioned
        // },
      },

      // Webhook path (default is /line/webhook)
      // webhookPath: "/line/webhook",

      // Media download limit in MB (default: 10)
      mediaMaxMb: 10,
    },
  },

  // Tools configuration
  tools: {
    allow: ["read", "write", "edit", "exec", "web_search", "web_fetch"],
    elevated: {
      enabled: true,
      allowFrom: {
        line: [],  // Add LINE user IDs that can use elevated tools
      },
    },
  },

  // Session settings
  session: {
    scope: "per-sender",  // Each LINE user gets their own session
    reset: {
      mode: "daily",
      atHour: 4,
    },
  },

  // Logging
  logging: {
    level: "info",
    consoleLevel: "info",
  },
}

## ===================================
## STEP 4: Environment Variables Setup
## ===================================

# Add to your ~/.bashrc, ~/.zshrc, or ~/.profile:

# LINE Bot Credentials (from LINE Developers Console)
export LINE_CHANNEL_ACCESS_TOKEN="YOUR_CHANNEL_ACCESS_TOKEN_HERE"
export LINE_CHANNEL_SECRET="YOUR_CHANNEL_SECRET_HERE"

# AI Model API Keys (choose your provider)
export ANTHROPIC_API_KEY="sk-ant-..."
# OR
export OPENAI_API_KEY="sk-..."
# OR
export OPENROUTER_API_KEY="sk-or-..."

# Optional: Gemini for embeddings (memory search)
export GEMINI_API_KEY="..."

## ===================================
## STEP 5: Pairing Users (if using dmPolicy: "pairing")
## ===================================

# When a new user messages your bot, they'll get a pairing code.
# You approve them via CLI:

# List pending pairing requests:
openclaw pairing list line

# Approve a user:
openclaw pairing approve line <PAIRING_CODE>

# Example:
# openclaw pairing approve line ABC123

## ===================================
## STEP 6: Managing Group Chats
## ===================================

# To get group/room IDs, temporarily set groupPolicy to "open",
# have someone send a message in the group, then check logs.
# The ID will appear in the log output.

# Then add the ID to groupAllowFrom and set policy back to "allowlist".

## ===================================
## STEP 7: Start the Gateway
## ===================================

# Start OpenClaw gateway:
openclaw gateway start

# Or run in background:
openclaw gateway start --daemon

# Check status:
openclaw gateway status

## ===================================
## ADVANCED: Multiple LINE Accounts
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
## TROUBLESHOOTING
## ===================================

# 1. Webhook verification fails:
#    - Ensure webhook URL is HTTPS
#    - Check channelSecret matches LINE console
#    - Verify gateway is reachable from internet

# 2. No messages received:
#    - Check webhook path matches config
#    - Verify "Use webhook" is enabled in LINE console
#    - Check gateway logs: openclaw gateway logs

# 3. Media not downloading:
#    - Increase mediaMaxMb in config
#    - Check LINE channel has proper permissions

# 4. Pairing not working:
#    - Ensure dmPolicy is "pairing"
#    - Check user is sending DMs, not group messages
#    - Verify pairing code hasn't expired

## ===================================
## USEFUL COMMANDS
## ===================================

# Check gateway config:
openclaw gateway config.get

# Validate config:
openclaw gateway config.schema

# View logs:
openclaw gateway logs

# Restart gateway:
openclaw gateway restart

# Send test message via CLI:
openclaw message send --channel line --target "Uxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" "Hello from OpenClaw!"
