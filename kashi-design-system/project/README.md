# Kashi (كاشي) Design System

> A Palestinian digital wallet built for the realities of life in Gaza and the West Bank.

## What is Kashi?

Kashi is a mobile-first digital wallet designed for users affected by Gaza's cash crisis and intermittent connectivity. Users sign up with their phone number and receive an auto-generated Palestinian IBAN (`PS00 KASH …`). They can:

- Receive money from Palestinian banks via **E-SADAD**
- Hold and spend **ILS** (Israeli new shekel, ₪)
- Send money out via **iBuraq**
- **Pay peer-to-peer fully offline** using QR codes + cryptographic signatures — the hero feature

Built for **SalamHack 2026** fintech hackathon. Target users: drivers, merchants, families, and anyone navigating Gaza's cash + connectivity crisis.

## Brand personality

- **Trustworthy + warm + dignified** — this is people's money, in tough conditions
- **Modern but not cold** — humanity matters
- **Empowering, not patronizing**
- **Palestinian pride, professional fintech feel** — refined, not folkloric

The visual reference points are Wise, Revolut, and Tabby — clean fintech — but with a Palestinian soul rooted in olive groves, terracotta earth, and warm hospitality.

## Sources

This design system was built from a written brand brief (no Figma or codebase provided). All visual decisions were made directly from the brief's specifications. Where ambiguous, choices favor the stated principles: **wallet balance is sacred**, **offline P2P is the hero**, **every state is designed**, **trust signals everywhere**, **one main action per screen**.

---

## CONTENT FUNDAMENTALS

Kashi is **bilingual, Arabic-primary**. Most users are Arabic-first; English is secondary. Both must look balanced — never an afterthought.

### Voice & tone

- **Friendly but precise.** This is a financial app in a serious context. Warmth is welcome; cheerfulness is not.
- **Empowering, never patronizing.** Users are navigating real hardship — speak to them as capable adults.
- **No emoji-heavy or over-cheerful copy.** A single trust mark (✓, lock icon) is fine; an emoji 🎉 on a successful payment is wrong.
- **Avoid Western chumminess.** No "Hey there!", "Oops!", "Yay!". Default to greetings like "مرحبا" or "أهلاً".
- **Modern Standard Arabic (فصحى)** for buttons, labels, and structural copy. Lightly conversational MSA for messages and confirmations — never colloquial dialect, which would exclude users.

### Casing

- **English:** Sentence case for buttons, labels, and most UI ("Send money", not "Send Money" or "SEND MONEY"). Title Case only for proper product names (E-SADAD, iBuraq, Kashi).
- **Arabic:** Arabic has no case; rely on weight and size for hierarchy.

### Specific examples

| Context | Good | Avoid |
|---|---|---|
| Welcome | "أهلاً، محمد" / "Welcome, Mohammed" | "Hey Mohammed! 👋" |
| Send button | "إرسال" / "Send" | "Send it! 🚀" |
| Empty wallet | "محفظتك فارغة. ابدأ بالاستلام." / "Your wallet is empty. Start by receiving." | "Nothing here yet 😢" |
| Offline mode | "أنت بدون اتصال — الدفع لا يزال متاحاً" / "You're offline — payments still work" | "No internet! Try again later." |
| Error | "تعذّر إتمام العملية. حاول مرة أخرى." / "Couldn't complete that. Please try again." | "Oops, something went wrong!" |
| Success | "تم الإرسال" / "Sent" | "Yay, sent! 🎉" |

### Numbers, dates, currency

- **Currency:** `₪ 250.00` — shekel symbol, space, tabular figures, two decimals always.
- **IBAN:** monospace, grouped 4 chars: `PS00 KASH 0000 0123 4567 89`.
- **Phone:** `+970` default, grouped: `+970 59 123 4567`.
- **Date:** `DD/MM/YYYY` — day first. Arabic numerals (0-9) are fine in both locales for clarity.
- **Tabular figures everywhere balances appear** — so columns of amounts align cleanly.

### What we never write

- "Hey there!" / "Howdy" / "Yo"
- Stacked exclamation points
- Religious greetings (السلام عليكم) — keep secular and inclusive
- References to Israel, the occupation, or politics — Kashi is a tool, not a statement
- Folkloric flourishes ("the warmth of our ancestors…") — this is fintech

---

## VISUAL FOUNDATIONS

### Color

The palette is Palestinian-inspired but refined for fintech. The hero color is a **deep olive green** — trust, growth, the olive tree. Earth tones (terracotta, gold) carry warmth. Semantic colors (success, warning, error) are softened — never aggressive. See `colors_and_type.css` for tokens.

- **Primary** Deep Olive `#2D5F3F`
- **Secondary** Warm Terracotta `#C76F3F`
- **Accent** Gold `#D4A24C`
- **Background** Warm off-white `#FAF8F5` (never pure white — feels less clinical)
- **Surface** `#FFFFFF` for cards over the warm bg

### Typography

- **English:** Inter (400/500/600/700). Tabular figures for all numbers.
- **Arabic:** IBM Plex Sans Arabic (400/500/600/700). Sized to optically match Inter at every step.
- **Hero balance:** 48px / 700 — the wallet balance is sacred.
- **Body:** 16px / 400.
- **Caption:** 14px / 500.
- **Mono (IBANs, codes):** JetBrains Mono with tabular spacing.

Arabic and English coexist on the same screen often. Arabic is sized **+1 to +2px** vs the equivalent English to feel optically balanced (Arabic glyphs are denser).

### Backgrounds

- **No gradients in product chrome.** Surfaces are flat (`#FAF8F5` or `#FFFFFF`). Gradients appear only on the **wallet balance card** and the **offline P2P ceremonial moment** — and even there, they're subtle olive-to-deeper-olive, never rainbow or bluish-purple.
- **No photography in the product UI.** Marketing surfaces may use warm, grainy photography of hands, markets, and olive groves — never staged, never cliché.
- **No repeating patterns** in the chrome. A faint olive-leaf watermark may appear on the offline-payment success screen to mark the ceremony.

### Animation

- **Restrained and purposeful.** This is a financial app — motion should reassure, not entertain.
- **Easing:** `cubic-bezier(0.4, 0.0, 0.2, 1)` (Material standard) for most. `cubic-bezier(0.16, 1, 0.3, 1)` (ease-out-expo) for the offline-payment success ceremony.
- **Durations:** 150ms for state changes (hover, press), 250ms for sheet/screen transitions, 600ms for the ceremonial offline-pay confirmation.
- **No bounces.** Money doesn't bounce.
- **Fades + small translates** preferred over scale.

### Hover & press states

- **Hover (web/desktop):** background darkens by ~6% (or surface lifts to a higher shadow tier). No color shifts.
- **Press (mobile):** scale to `0.98` + opacity to `0.9`, 100ms. Restored on release.
- **Focus:** 2px olive ring with 2px offset. Always visible — accessibility-first.

### Borders, radii, shadows

- **Radii (strict):**
  - 12px — input fields
  - 16px — cards, sheets, list items
  - 24px — primary buttons, the wallet balance card
  - 999px — pills, badges, avatars
- **Borders:** 1px `#E8E5E0` for separators; never heavier. Borders are a fallback — prefer whitespace + shadow.
- **Shadows (subtle, never heavy):**
  - `shadow-sm`: `0 1px 2px rgba(26,26,26,0.04)` — list items
  - `shadow-md`: `0 4px 12px rgba(26,26,26,0.06)` — cards
  - `shadow-lg`: `0 12px 32px rgba(26,26,26,0.08)` — sheets, modals
  - `shadow-balance`: `0 8px 24px rgba(45,95,63,0.18)` — wallet balance card only

### Layout rules

- **8px spacing grid.** All margins and paddings are multiples of 8 (occasionally 4 for tight inline cases).
- **Generous whitespace.** A screen with too much content is a design failure — split it.
- **One main action per screen.** A primary olive button at the bottom; secondary actions are text or ghost.
- **Bottom nav** on mobile, max 5 items. The center is reserved for the **Pay** action — visually distinct, slightly elevated.
- **RTL is first-class.** Every layout mirrors cleanly for Arabic. Icons that imply direction (arrows, back chevrons) flip; logos and brand marks do not.

### Transparency & blur

- **Used sparingly.** The bottom-nav has a `backdrop-filter: blur(20px)` over a `rgba(255,255,255,0.85)` fill, so content scrolls behind it without distracting.
- **Modal scrims** are `rgba(15,22,18,0.5)` — a tinted dark, not pure black.
- **No frosted-glass cards** in the main flow. Save it for the offline-pay ceremony.

### Imagery

When marketing imagery is used (outside the product), it's **warm, slightly grainy, golden-hour**. Hands, olive trees, market stalls. Never flags, never weapons, never poverty-tourism. The color grade leans warm — terracotta and olive in the shadows.

### Cards

Cards are the workhorse. A standard Kashi card:
- 16px radius
- `#FFFFFF` surface on `#FAF8F5` background — visible without a border
- `shadow-md` for elevated cards; flat for inline list items
- 16px or 20px internal padding
- Header (optional, 14px medium secondary), title (16-18px, primary text), supporting content
- Trailing chevron (RTL-aware) for navigable cards

The **wallet balance card** is the exception: 24px radius, deep-olive gradient background, white text, `shadow-balance`, full-width on the home screen.

---

## ICONOGRAPHY

Kashi uses **Lucide** as its icon system. Lucide's outlined, 1.5–2px stroke aesthetic matches the modern fintech feel and the brief's explicit guidance.

- **Standard size:** 24px
- **Feature contexts:** 32px (e.g. action tiles on the home screen, hero icons on empty states)
- **Inline within text:** 16px or 20px, vertical-aligned to the cap height
- **Stroke width:** 1.5px (default) — bumped to 2px only when an icon needs to feel weightier (the `Pay` action, the balance card lock)
- **Color:** Inherits from `currentColor`. Never multi-color icons. Never filled icons except for status badges (✓ success, ⚠ warning) where fill aids legibility at small sizes.

### Where icons are loaded from

`assets/lucide.js` — the official Lucide library, loaded from CDN in the UI kit and copied locally for offline use. Icon names follow Lucide's kebab-case convention (`arrow-right`, `wallet`, `qr-code`, `shield-check`, `wifi-off`).

### Status icons (always icon + text + color — never color alone)

| State | Icon | Color |
|---|---|---|
| Success | `check-circle-2` | `#4CAF50` |
| Warning | `alert-triangle` | `#FF9800` |
| Error | `x-circle` | `#E53935` |
| Verified | `shield-check` | `#2D5F3F` |
| Offline mode | `wifi-off` | `#C76F3F` |
| Signed (cryptographically) | `signature` or `key-round` | `#2D5F3F` |

### What we don't use

- **No emoji** as functional UI. (The single exception: a user's own avatar may be initials or emoji of their choice — user content, not chrome.)
- **No unicode glyphs** as icons (no ✕, ✓, →). Always Lucide.
- **No custom-drawn icons** unless the concept doesn't exist in Lucide (e.g. a future Kashi-specific glyph for the offline signature handshake).

### Logo & brand mark

The Kashi wordmark is set in Inter 700 with the Arabic كاشي in IBM Plex Sans Arabic 700, paired horizontally (English first in LTR, Arabic first in RTL). The mark itself is a simplified olive-leaf glyph — see `assets/kashi-logo.svg`. The logo never rotates, never gradients, never mirrors.

---

## INDEX — what's in this folder

| File / folder | Purpose |
|---|---|
| `README.md` | This file. Brand context + content + visual + iconography fundamentals. |
| `SKILL.md` | Cross-compatible skill manifest for Claude Code / agents. |
| `colors_and_type.css` | All design tokens as CSS custom properties — colors, type, spacing, radii, shadows. Light + dark mode. |
| `fonts/` | Inter and IBM Plex Sans Arabic (loaded via Google Fonts in HTML; copies kept here for offline ref). |
| `assets/` | Logos, icon set reference, illustration placeholders. |
| `preview/` | Design system specimen cards (colors, type, components, spacing, brand). |
| `ui_kits/mobile/` | Kashi mobile wallet UI kit. Pixel-perfect React (JSX) recreation of key screens including the offline P2P ceremony. |

## Caveats

- **No codebase or Figma was provided** — this system is built directly from the brand brief. Component specifics (exact paddings, micro-states) are reasonable interpretations of the principles, not copies of an existing implementation.
- **Fonts:** Inter and IBM Plex Sans Arabic are loaded via Google Fonts. If the team has licensed copies or a different cut (e.g. SF Pro for iOS native, Tajawal as the Arabic alternative mentioned in the brief), drop them in `fonts/` and update `colors_and_type.css`.
- **Iconography uses Lucide** — if the team prefers Phosphor (also mentioned in the brief), it's a one-line CDN swap and the visual language is very close.
- **No real photography** is included — the system describes the imagery direction but doesn't ship stock photos.
"# kashi_design_system" 
