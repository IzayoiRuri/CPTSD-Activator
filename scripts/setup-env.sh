#!/bin/bash
# ──────────────────────────────────────────────────────────
# Activate (启动) 开发环境一键重建
# 用法: bash scripts/setup-env.sh
# 前提: /shared/dev-tools/ 下已有完整工具链（持久化在宿主机）
# ──────────────────────────────────────────────────────────
set -e

SHARED="/shared/dev-tools"
ENV_FILE="/opt/env.sh"

echo "🔧 Setting up Activate dev environment..."

# ── 1. 工具链软链接 ──
link_if_missing() {
    local src="$1"
    local dst="$2"
    local name="$3"
    if [ ! -e "$dst" ]; then
        ln -sf "$src" "$dst"
        echo "  ✅ $name linked"
    else
        echo "  ⏭️  $name already exists"
    fi
}

link_if_missing "$SHARED/java17"          /opt/java17          "JDK 17"
link_if_missing "$SHARED/flutter"         /home/agent/flutter  "Flutter SDK"
link_if_missing "$SHARED/android-sdk"     /opt/android-sdk     "Android SDK"
link_if_missing "$SHARED/gradle-8.4"      /opt/gradle-8.4     "Gradle 8.4"

# ── 2. 环境变量 ──
cat > "$ENV_FILE" << 'EOF'
export JAVA_HOME=/opt/java17
export ANDROID_HOME=/opt/android-sdk
export FLUTTER_HOME=/home/agent/flutter
export GRADLE_HOME=/opt/gradle-8.4/gradle-8.4
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$FLUTTER_HOME/bin:$GRADLE_HOME/bin:$PATH"
EOF
source "$ENV_FILE"
echo "  ✅ /opt/env.sh written"

# ── 3. 权限修复 ──
chmod +x "$SHARED/android-sdk/cmdline-tools/latest/bin/"* 2>/dev/null || true
chmod +x "$SHARED/gradle-8.4/gradle-8.4/bin/gradle" 2>/dev/null || true
chmod +x "$SHARED/flutter/bin/"* 2>/dev/null || true
echo "  ✅ Permissions fixed"

# ── 4. Flutter 配置 ──
flutter config --no-analytics 2>/dev/null || true
echo "  ✅ Flutter configured"

# ── 5. 依赖安装 ──
cd "$(dirname "$0")/.."
flutter pub get
echo "  ✅ pub get done"

echo ""
echo "🎉 Environment ready! Run: flutter build apk --release"
