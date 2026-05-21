# 启动 (Activate) Design System

## Visual Theme & Atmosphere
- Mood: playful
- Feel: Gentle gamification — encouraging but never overwhelming. A companion, not a commander. Soft tinted backgrounds reduce pressure; warm accents signal safety and energy states.
- References: Gamified habit trackers, Duolingo's encouragement patterns, minimalist meditation apps
- Key decision: Light-mode phone interiors on dark stage — contrast draws focus to content without the clinical feel of pure white. Each mode has its own background tint to signal "this is a different headspace."

## Color Palette & Roles

### Stage (Gamified Showcase)
- Stage Background: `#0E0D0C` (near-black, deep warm)
- Spotlight Glow: `radial-gradient(ellipse at 50% 0%, rgba(100,100,100,0.08) 0%, transparent 60%)`
- Caption / Meta text: `#52525B`

### 🆘 Rescue Mode
- Background: `#FEF7F2` (warm cream, like morning light through curtains)
- Surface: `#FDF0E5` (slightly deeper warm)
- Surface Elevated: `#FCE4D0`
- Text Primary: `#1C1917`
- Text Secondary: `#78716C`
- Divider: `#E7E5E4`
- Accent: `#D97706` (warm amber)
- Accent Hover: `#B45309`
- Accent Surface: `rgba(217,119,6,0.12)`

### 🌤️ Daily Mode
- Background: `#F5FBFA` (cool fresh, like mint water)
- Surface: `#E8F5F2`
- Surface Elevated: `#D4EDE8`
- Text Primary: `#0F172A`
- Text Secondary: `#475569`
- Divider: `#E2E8F0`
- Accent: `#0D9488` (teal)
- Accent Hover: `#0F766E`
- Accent Surface: `rgba(13,148,136,0.12)`

### ⚡ High Energy Mode
- Background: `#FEF5F5` (soft rose, gently energizing)
- Surface: `#FDE8E8`
- Surface Elevated: `#FBC8C8`
- Text Primary: `#1C1917`
- Text Secondary: `#78716C`
- Divider: `#E7E5E4`
- Accent: `#F97316` (coral)
- Accent Hover: `#EA580C`
- Accent Surface: `rgba(249,115,22,0.12)`

### Effort Level Markers (Cross-Mode)
- 🔴 Heavy: `#EF4444`
- 🟡 Medium: `#EAB308`
- 🔵 Light: `#3B82F6`

### Status Colors (Cross-Mode)
- Success (Completed): `#22C55E`
- Danger (Cancel): `#EF4444`

### Confetti Colors (Celebration, Cross-Mode)
Particles draw from a fixed palette of 8 celebratory hues — bright but warm, avoiding harsh neons:
- `#FBBF24` (amber-400)
- `#F472B6` (pink-400)
- `#34D399` (emerald-400)
- `#60A5FA` (blue-400)
- `#A78BFA` (violet-400)
- `#FB923C` (orange-400)
- `#FACC15` (yellow-400)
- `#4ADE80` (green-400)

## Typography Rules
- Display: `system-ui`, weight 700, `1.25rem`/1.3 (section titles, timer)
- Body: `system-ui`, weight 400, `1rem`/1.6 (task names, labels)
- Caption: `system-ui`, weight 400, `0.8125rem`/1.5 (timestamps, meta)
- Mono: `JetBrains Mono`, weight 400, `0.8125rem` (countdown digits)
- **Chinese text**: `system-ui` → Android fallback to Noto Sans SC. Unified rendering; no Latin/CJK mismatch.

## Component Stylings

### Mode Tab Bar
- Top of screen, 3 equal-width tabs, height 48px
- Active: accent background + bold white text
- Inactive: transparent, text-secondary color
- No elevation, flush with content

### Label Grid (Tag Grid)
- 2–3 columns, `flex-wrap`, `justify-content: center`, gap 12px
- Each tile: `border-radius: 12px`, surface bg, padding 16px, min 44×44px touch target
- Tile text: body size, text-primary, centered
- Effort indicator: 8px colored dot, top-right corner of tile
- Press: `scale(0.96)`, 100ms ease-out
- Long press (>600ms): triggers random-pick → highlight selected tile → auto-open time picker
- Custom label (+): dashed outline border, accent color, same dimensions

### Bottom Sheet (Time Picker)
- Top corners `border-radius: 16px 16px 0 0`, surface-elevated bg
- Options row: 5 pills (1, 3, 5, 10, 15 min), equal-width, gap 8px
- Tap pill: fills with accent (white text); confirm button below
- Backdrop: `rgba(0,0,0,0.3)` (lighter for light mode interiors)
- Dismiss: swipe down or tap backdrop

### Task Card (Active)
- Surface bg, `border-radius: 8px`, padding 12px
- Drag handle `≡` on left margin, 24px wide
- Row 1: label name + effort dot (colored circle 8px)
- Row 2: timer countdown in mono font, accent-colored
- Right side: ✓ (success green) and ✕ (danger red) buttons, min 44×44px each
- Long press card → drag to reorder (haptic feedback)
- Auto-scroll list during drag

### Task Card (Completed)
- Same structure, opacity 0.45, text-decoration: none (dimmed, not crossed out)
- Completion timestamp in caption style below label
- Sits under a 1px divider label "✅ 已完成"
- Auto-cleared after 24 hours (local only)

### Timer Countdown
- Large digits: `JetBrains Mono`, `1.5rem`, weight 600, accent color
- Optional: circular SVG progress ring (accent stroke on neutral track)
- Reaches `00:00` → auto-mark task complete → system notification "「{label}」完成!"
- Notification triggers vibration pattern
- **Timer Persistence (v1.1.0):** Timer stores `createdAt` timestamp. On app relaunch after process kill, remaining seconds = `duration - (now - createdAt)`. No reset on restart.

### Confetti Celebration Overlay (v1.1.0)
A full-screen particle animation that plays once when a task is marked complete. Intensity scales with the task's effort level.

**Trigger:** Task completion (timer reaches 0, or manual ✓ tap)

**Intensity Levels:**

| Effort | Particle Count | Duration | Spread | Description |
|--------|---------------|----------|--------|-------------|
| 🔵 Light | ~15–20 | 1.5s | Narrow cone, gentle float | Quick, quiet acknowledgment |
| 🟡 Medium | ~40–50 | 2.5s | Medium cone, moderate velocity | Satisfying pop of encouragement |
| 🔴 Heavy | ~80–100 | 3.5s | Wide cone, energetic burst | Full celebration — you earned it |

**Visual Spec:**
- Particles: 4–8px colored circles, semi-transparent (opacity 0.7–1.0)
- Colors: drawn from the 8-color Confetti palette, randomly assigned per particle
- Motion: particles originate from screen center-top, arc outward with randomized velocity + gravity
- Rotation: each particle has slight random spin (0–360°/s)
- Fade: particles fade from opacity 1.0 → 0 over the last 30% of their lifespan
- Overlay: semi-transparent backdrop `rgba(0,0,0,0.15)` fades in over 200ms, fades out over 300ms after last particle

**Easing:** `easeOutCubic` for all particle motion, `easeInOut` for overlay opacity

**Accessibility:** If system `prefers-reduced-motion` is active, confetti is replaced with a static "✨ {label} 完成！" text badge that fades in/out over 1.5s

**Performance:** All particles rendered via a single `CustomPainter` canvas. No individual widget per particle.

### Daily Summary Panel
- Slide-up panel or dedicated page, accessible from task list header
- Header: date (e.g. "5月9日") + "今日总结"
- Effort breakdown: 3 horizontal bars (light / medium / heavy), proportional to count
- List: all completed tasks with label, timestamp, effort marker
- Footer: [📤 导出文本] button → generates plain text → Android share sheet

### Random Pick (Long Press Action)
- Hold any label >600ms → haptic buzz
- All other grid tiles fade to opacity 0.2
- Selected tile: accent surface glow, scale 1.05
- After 400ms: time picker bottom sheet auto-opens with the selected label

## Label Catalog (Per Mode)

### 🆘 Rescue Mode Labels
| Label | Effort |
|-------|--------|
| 深呼吸 | 🔵 Light |
| 从床上坐起来 | 🔵 Light |
| 洗脸 | 🔵 Light |
| 喝水 | 🔵 Light |
| 看一页书 | 🔵 Light |
| 换一件上衣 | 🔵 Light |
| 关掉社交软件 | 🔵 Light |

### 🌤️ Daily Mode Labels
| Label | Effort |
|-------|--------|
| 洗碗 | 🟡 Medium |
| 洗衣服 | 🔴 Heavy |
| 扔垃圾 | 🔵 Light |
| 收拾厨房 | 🟡 Medium |
| 扫地 | 🟡 Medium |
| 拖地 | 🟡 Medium |
| 准备做饭食材 | 🟡 Medium |

### ⚡ High Energy Mode Labels
| Label | Effort |
|-------|--------|
| 写一段练笔 | 🟡 Medium |
| 画画 | 🟡 Medium |
| 刻印 | 🔴 Heavy |
| 深入读书 | 🟡 Medium |
| 有氧拳击 | 🔴 Heavy |

## Layout Principles
- Max width: `412px` (Android phone portrait)
- Content centered, single-column
- Section spacing (vertical): `24px`
- Content padding (horizontal): `16px`
- Tag grid: centered, `gap: 12px`, wraps naturally
- Task list: full-width scrollable, max-height remaining viewport
- Status bar aware: top padding `env(safe-area-inset-top)`

## Depth & Elevation
- Light mode interiors: subtle `box-shadow: 0 1px 3px rgba(0,0,0,0.06)` on surface-elevated elements
- Bottom sheet: `box-shadow: 0 -4px 12px rgba(0,0,0,0.08)` for visual lift
- Active task card: `border: 1px solid rgba(0,0,0,0.06)`
- No heavy shadows — soft, barely-there depth

## Do's and Don'ts

### ✅ DO
- DO use `system-ui` for ALL text — unified CJK + Latin rendering
- DO switch full color palette (bg, surface, accent) between modes
- DO keep task-adding to ≤3 taps: open app → tap label → tap time → done
- DO ensure all touch targets ≥44×44px (WCAG 2.1 mobile)
- DO show completed tasks list as positive reinforcement
- DO use encouraging microcopy for empty states
- DO use soft, tinted backgrounds — never clinical pure white or harsh pure black
- DO use celebration moments (confetti) as earned rewards for task completion
- DO scale animation intensity to effort level — a light task gets a light celebration
- DO respect system `prefers-reduced-motion` — swap animations for static acknowledgment

### ❌ DON'T
- DON'T use ambient or looping animations (no parallax scrolls, no pulse-on-idle loops)
- DON'T blend multiple accent colors on one screen
- DON'T show error-style alerts for empty task lists
- DON'T require scrolling to add the first task of the day
- DON'T make confetti last longer than 3.5s — celebrations are punctuation, not a feature
- DON'T use animations that could feel overstimulating as background states — brief, earned celebrations are the exception

## Responsive Behavior
- Primary target: `360px`–`412px` width (Android phone portrait)
- Single-column only, no landscape adaptation needed
- Font sizes respect system accessibility scale
- Bottom sheet and summary panel: `max-height: 80vh`, internal scroll

## Agent Prompt Guide
- All colors from section "Color Palette & Roles" only — no invented hex values
- Accent color and background are both mode-dependent; switch full palette via CSS custom properties
- `font-family: system-ui` for ALL text; JetBrains Mono only for timer digits
- Accent appears max 3 times per viewport (active tab, timer digits, one CTA)
- All interactive elements need `:focus-visible { outline: 2px solid var(--accent) }`
- Three distinct mode palettes — rescue (warm cream), daily (cool mint), high energy (soft rose)
- Animations allowed: press `scale(0.96)` (100ms), random-pick highlight (400ms), countdown pulse every 500ms below 30 seconds, **confetti celebration (1.5s–3.5s depending on effort)**
- Touch targets: minimum 44×44px everywhere
- Generate real, meaningful task names in Chinese from the Label Catalog
- Default mode on app launch: Daily (🌤️)
- Confetti particles use the 8-color Confetti palette only — no mode accent colors in confetti
