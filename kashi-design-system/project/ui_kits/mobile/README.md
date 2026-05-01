# Kashi Mobile UI Kit

Pixel-perfect-ish recreations of Kashi's key mobile screens. Built directly from the brand brief — there is no upstream codebase or Figma to copy from, so every component flows from the design tokens in `/colors_and_type.css`.

## Files

- `index.html` — six iPhone frames showing each screen + an interactive prototype.
- `ios-frame.jsx` — device bezel (status bar, home indicator).
- `components.jsx` — atoms: `Button`, `BalanceCard`, `ActionTile`, `TxItem`, `BottomNav`, `TopBar`, `StatusPill`, all `Icon*` (Lucide-style inline SVG).
- `screens.jsx` — composed screens: `HomeScreen`, `SendScreen`, `OfflinePayScreen`, `SuccessScreen`, `ActivityScreen`.

## Screens covered

1. **Home** — wallet balance card (the "sacred" element), four action tiles, recent activity list.
2. **Send** — amount input, recipient picker, primary CTA. One main action per screen.
3. **Offline pay (hero)** — the cryptographically-signed QR ceremony. Visually distinct: gold/terracotta gradient surface, signature fragment shown, trust copy.
4. **Success** — restrained confirmation, no confetti. Reference number monospaced.
5. **Activity** — filtered transaction history with offline-signed indicator.
6. **Interactive prototype** — click the action tiles to walk Send → Offline → Success.

## Caveats

- **Cryptographic signing is mocked.** In production the QR encodes a signed payload; here it's a deterministic dot pattern.
- **Arabic / RTL views are not yet built out** as full screens — bilingual treatment is shown in the Home greeting and tested in the type cards. A proper RTL flow is a natural next iteration.
- **No real codebase or Figma** — components are interpretations of the brief, not copies of an existing implementation.
