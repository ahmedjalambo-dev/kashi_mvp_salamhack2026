---
name: kashi-design
description: Use this skill to generate well-branded interfaces and assets for Kashi (كاشي), the Palestinian digital wallet. Contains essential design guidelines, colors, type, fonts, brand assets, and UI kit components for prototyping or production design work — including the offline P2P hero flow.
user-invocable: true
---

# Kashi Design Skill

Kashi is a Palestinian digital wallet built for life in Gaza and the West Bank — phone-based signup, auto-generated `PS`-prefixed IBAN, ILS holding & spending, and a hero feature: **fully-offline peer-to-peer payments via signed QR codes**.

Read `README.md` first for the brand context, content fundamentals, visual foundations, and iconography rules. Then explore:

- `colors_and_type.css` — design tokens (light + dark mode). Import this in any HTML you produce.
- `assets/` — `kashi-logo.svg` and `kashi-mark.svg`.
- `preview/` — small specimen cards for every token group; useful as visual reference.
- `ui_kits/mobile/` — React/JSX components and full screens. Re-use `BalanceCard`, `Button`, `BottomNav`, `TxItem`, `OfflinePayScreen`, etc. instead of rebuilding.

## When invoked

If the user invokes this skill with a clear goal, proceed. If not, ask:
1. **What surface?** (mobile screen, marketing page, slide deck, illustration)
2. **Locale?** (English, Arabic, or bilingual — Arabic is primary; mirror everything for RTL)
3. **Light or dark mode?**
4. **Production code or throwaway prototype?**

## Design with these non-negotiables

1. **Wallet balance is sacred.** Always prominent. Never crowded. Use `BalanceCard` from the UI kit when relevant.
2. **Offline P2P is the hero.** Treat it as ceremonial — gold/terracotta gradient, signature fragments, trust copy. The QR moment is the most important visual in the product.
3. **Every state is designed** — loading, empty, error, success, offline, signed-pending-settlement.
4. **Trust signals everywhere** — `IconShield`, `IconKey`, signature hashes (mono), verified pills.
5. **One main action per screen** — primary olive button at the bottom; secondary actions are ghost/text.

## Quick rules

- **Colors:** olive `#2D5F3F` primary, terracotta `#C76F3F` for warmth, gold `#D4A24C` for premium accents. Background `#FAF8F5` — never pure white.
- **Type:** Inter (English) + IBM Plex Sans Arabic. Tabular figures on every numeric value. JetBrains Mono for IBANs and signature hashes.
- **Radii:** 12 input, 16 card, 24 button & balance, 999 pill.
- **Shadows:** subtle. `shadow-balance` is the only saturated shadow — used only on the wallet card.
- **Icons:** Lucide, 1.75px stroke, 24px standard. Never emoji as functional UI. Status badges always combine icon + text + color.
- **Voice:** friendly but precise. No "Hey there!", no exclamation pile-ups, no emoji-celebrations. Greetings: `أهلاً`, `مرحبا`, `Welcome`.
- **Currency:** `₪ 250.00` with tabular nums. **IBAN:** `PS00 KASH 0000 0123 4567 89` in mono, 4-char groups.
- **RTL** is first-class for Arabic — mirror layouts, flip directional icons.

## Workflow for HTML artifacts

1. Link `colors_and_type.css` (relative path).
2. Use the SVG icons from `ui_kits/mobile/components.jsx` or the inline icons in `preview/iconography.html` — copy the path data, don't redraw.
3. For screens, copy components out of `ui_kits/mobile/components.jsx` and `screens.jsx`. They're modular and consume only design tokens.
4. Verify visually before declaring done.

## Workflow for production code

Lift the tokens from `colors_and_type.css` into your codebase's design-token file. The component patterns in `ui_kits/mobile/` are illustrative, not production-ready — but the spacing, radii, shadow, and color decisions are.
