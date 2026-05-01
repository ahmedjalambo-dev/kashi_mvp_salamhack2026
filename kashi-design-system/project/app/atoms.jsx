// Kashi Android · Atoms — icons, buttons, fields, pills, status, layout helpers.
// All Material You-inspired but custom — olive/terracotta, rounded, soft shadows.

const { useState, useEffect, useRef } = React;

// ---------- Tokens (read inline so this file is self-sufficient) ----------
const K = {
  olive: "#2D5F3F", olive700: "#234B32", olive50: "#EAF2EC", oliveLift: "#4A8A65",
  terra: "#C76F3F", terra50: "#FBEFE6", terra700: "#A4582E",
  gold: "#D4A24C", gold50: "#FBF3E1",
  bg: "#FAF8F5", surface: "#FFFFFF", surface2: "#F4F1EB",
  fg: "#1A1A1A", fg2: "#6B6B6B", fg3: "#9A9A9A",
  border: "#E8E5E0", borderStrong: "#D4CFC6",
  success: "#4CAF50", successBg: "#E8F5E9", successFg: "#2E7D32",
  warning: "#FF9800", warningBg: "#FFF4E5", warningFg: "#B86E00",
  error: "#E53935", errorBg: "#FCEAEA", errorFg: "#B71C1C",
};
window.K = K;

// ---------- Icons ----------
const I = ({ d, size = 24, sw = 1.75, fill = "none", children, color, style }) => (
  <svg viewBox="0 0 24 24" width={size} height={size} fill={fill}
    stroke={color || "currentColor"} strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" style={style}>
    {d ? <path d={d}/> : children}
  </svg>
);
const Ico = {
  wallet:  (p)=><I {...p}><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0 0 4h16v4"/><path d="M3 5v14a2 2 0 0 0 2 2h16v-4"/><circle cx="17" cy="14" r="1.5"/></I>,
  qr:      (p)=><I {...p}><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3M21 14v.01M21 21v.01M14 21v.01M17 21h4M21 17h-3"/></I>,
  shield:  (p)=><I {...p}><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="m9 12 2 2 4-4"/></I>,
  wifiOff: (p)=><I {...p}><line x1="2" y1="2" x2="22" y2="22"/><path d="M8.5 16.5a5 5 0 0 1 7 0"/><path d="M2 8.82a15 15 0 0 1 4.17-2.65"/><path d="M10.66 5c4.01-.36 8.14.9 11.34 3.76"/><path d="M16.85 11.25a10 10 0 0 1 2.22 1.68"/><line x1="12" y1="20" x2="12" y2="20"/></I>,
  wifi:    (p)=><I {...p}><path d="M5 12.55a11 11 0 0 1 14.08 0"/><path d="M1.42 9a16 16 0 0 1 21.16 0"/><path d="M8.53 16.11a6 6 0 0 1 6.95 0"/><line x1="12" y1="20" x2="12" y2="20"/></I>,
  activity:(p)=><I {...p}><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></I>,
  home:    (p)=><I {...p}><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></I>,
  user:    (p)=><I {...p}><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></I>,
  arrowDn: (p)=><I {...p}><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></I>,
  arrowUp: (p)=><I {...p}><path d="M12 19V5"/><path d="m5 12 7-7 7 7"/></I>,
  arrowRt: (p)=><I {...p}><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></I>,
  arrowLt: (p)=><I {...p}><line x1="19" y1="12" x2="5" y2="12"/><polyline points="12 19 5 12 12 5"/></I>,
  send:    (p)=><I {...p}><path d="m22 2-7 20-4-9-9-4z"/><path d="M22 2 11 13"/></I>,
  check:   (p)=><I {...p}><path d="M20 6 9 17l-5-5"/></I>,
  chevRt:  (p)=><I {...p}><polyline points="9 18 15 12 9 6"/></I>,
  chevLt:  (p)=><I {...p}><polyline points="15 18 9 12 15 6"/></I>,
  chevDn:  (p)=><I {...p}><polyline points="6 9 12 15 18 9"/></I>,
  close:   (p)=><I {...p}><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></I>,
  key:     (p)=><I {...p}><circle cx="7.5" cy="15.5" r="5.5"/><path d="m21 2-9.6 9.6"/><path d="m15.5 7.5 3 3L22 7l-3-3"/></I>,
  copy:    (p)=><I {...p}><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></I>,
  bell:    (p)=><I {...p}><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></I>,
  plus:    (p)=><I {...p}><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></I>,
  bluetooth:(p)=><I {...p}><polyline points="6.5 6.5 17.5 17.5 12 23 12 1 17.5 6.5 6.5 17.5"/></I>,
  scan:    (p)=><I {...p}><path d="M3 7V5a2 2 0 0 1 2-2h2"/><path d="M17 3h2a2 2 0 0 1 2 2v2"/><path d="M21 17v2a2 2 0 0 1-2 2h-2"/><path d="M7 21H5a2 2 0 0 1-2-2v-2"/><line x1="7" y1="12" x2="17" y2="12"/></I>,
  refresh: (p)=><I {...p}><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10"/><path d="M20.49 15a9 9 0 0 1-14.85 3.36L1 14"/></I>,
  bank:    (p)=><I {...p}><line x1="3" y1="22" x2="21" y2="22"/><line x1="6" y1="18" x2="6" y2="11"/><line x1="10" y1="18" x2="10" y2="11"/><line x1="14" y1="18" x2="14" y2="11"/><line x1="18" y1="18" x2="18" y2="11"/><polygon points="12 2 20 7 4 7"/></I>,
  search:  (p)=><I {...p}><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></I>,
  cloudOff:(p)=><I {...p}><path d="M22.61 16.95A5 5 0 0 0 18 10h-1.26a8 8 0 0 0-7.05-6M5 5a8 8 0 0 0 4 15h9a5 5 0 0 0 1.7-.3"/><line x1="1" y1="1" x2="23" y2="23"/></I>,
  flash:   (p)=><I {...p}><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></I>,
  sun:     (p)=><I {...p}><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></I>,
};
window.Ico = Ico;

// ---------- Currency / IBAN formatters ----------
const fmtAmt = (n) => n.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const fmtSh  = (n) => "₪ " + fmtAmt(n);
const fmtIBAN = (s) => s.replace(/(.{4})/g, "$1 ").trim();
window.fmtAmt = fmtAmt; window.fmtSh = fmtSh; window.fmtIBAN = fmtIBAN;

// ---------- Scaffold (the inner phone screen frame) ----------
function Scaffold({ children, bg = K.bg, dir = "ltr" }) {
  return (
    <div dir={dir} style={{
      width: 390, height: 780, background: bg, position: "relative",
      overflow: "hidden", fontFamily: "'Inter', system-ui, sans-serif",
      color: K.fg, fontSize: 14, lineHeight: 1.5,
      display: "flex", flexDirection: "column",
    }}>
      <StatusBar dir={dir}/>
      {children}
    </div>
  );
}

// ---------- Faux Android status bar ----------
function StatusBar({ dir = "ltr", dark = false }) {
  const c = dark ? "#fff" : K.fg;
  return (
    <div style={{
      height: 30, padding: "0 16px", display: "flex", alignItems: "center",
      justifyContent: "space-between", flexShrink: 0,
      fontSize: 12, fontWeight: 600, color: c, letterSpacing: "0.02em",
    }}>
      <span>9:41</span>
      <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
        <Ico.wifi size={13} sw={2} color={c}/>
        <svg width="22" height="11" viewBox="0 0 22 11"><rect x="0.5" y="0.5" width="18" height="10" rx="2.5" stroke={c} fill="none"/><rect x="2" y="2" width="15" height="7" rx="1" fill={c}/><rect x="19" y="3.5" width="2" height="4" rx="1" fill={c}/></svg>
      </div>
    </div>
  );
}
window.Scaffold = Scaffold;

// ---------- Top app bar ----------
function AppBar({ title, onBack, action, sync = "online", dir = "ltr" }) {
  const syncBadge = {
    online:  { color: K.successFg, bg: K.successBg, icon: <Ico.wifi size={11} sw={2}/>, label: "Online" },
    offline: { color: K.terra700, bg: K.terra50, icon: <Ico.wifiOff size={11} sw={2}/>, label: "Offline" },
    syncing: { color: K.warningFg, bg: K.warningBg, icon: <Ico.refresh size={11} sw={2}/>, label: "Syncing" },
    pending: { color: K.warningFg, bg: K.warningBg, icon: <Ico.cloudOff size={11} sw={2}/>, label: "Pending sync" },
  }[sync] || null;
  const Back = dir === "rtl" ? Ico.chevRt : Ico.chevLt;
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "8px 12px 12px", minHeight: 44, flexShrink: 0 }}>
      {onBack ? (
        <button onClick={onBack} style={iconBtn}><Back size={20}/></button>
      ) : <div style={{ width: 40 }}/>}
      <div style={{ flex: 1, textAlign: "center", fontSize: 16, fontWeight: 600, color: K.fg }}>{title}</div>
      {action ? action : (syncBadge ? (
        <div style={{ display: "inline-flex", alignItems: "center", gap: 4, padding: "4px 8px", borderRadius: 999, background: syncBadge.bg, color: syncBadge.color, fontSize: 11, fontWeight: 600 }}>
          {syncBadge.icon}{syncBadge.label}
        </div>
      ) : <div style={{ width: 40 }}/>)}
    </div>
  );
}
const iconBtn = {
  width: 40, height: 40, borderRadius: 999, border: "none",
  background: "transparent", display: "grid", placeItems: "center", cursor: "pointer", color: K.fg,
};
window.AppBar = AppBar; window.iconBtn = iconBtn;

// ---------- Bottom Navigation (Material 3 inspired) ----------
function BottomNav({ active = "home", dir = "ltr" }) {
  const items = [
    { id: "home",     icon: Ico.home,     label: "Home" },
    { id: "send",     icon: Ico.send,     label: "Send" },
    { id: "scan",     icon: Ico.qr,       label: "Pay",  center: true },
    { id: "activity", icon: Ico.activity, label: "Activity" },
    { id: "me",       icon: Ico.user,     label: "Profile" },
  ];
  return (
    <div style={{
      flexShrink: 0, height: 80, background: "rgba(250,248,245,0.94)",
      backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)",
      borderTop: `1px solid ${K.border}`,
      display: "flex", alignItems: "flex-start", padding: "8px 4px 0",
    }}>
      {items.map(it => {
        const Icon = it.icon;
        const isActive = active === it.id;
        if (it.center) return (
          <button key={it.id} style={navBtnBase}>
            <div style={{
              width: 56, height: 36, borderRadius: 999,
              background: K.olive, color: "#FAF8F5",
              display: "grid", placeItems: "center", marginTop: -4,
              boxShadow: "0 4px 12px rgba(45,95,63,0.32)",
            }}><Icon size={22} sw={2}/></div>
            <span style={{ fontSize: 10, fontWeight: 600, color: K.olive }}>{it.label}</span>
          </button>
        );
        return (
          <button key={it.id} style={navBtnBase}>
            <div style={{
              width: 56, height: 32, borderRadius: 999,
              background: isActive ? K.olive50 : "transparent",
              display: "grid", placeItems: "center",
              color: isActive ? K.olive : K.fg2,
              transition: "background 150ms",
            }}><Icon size={20} sw={isActive ? 2 : 1.75}/></div>
            <span style={{ fontSize: 10, fontWeight: isActive ? 700 : 500, color: isActive ? K.olive : K.fg2 }}>{it.label}</span>
          </button>
        );
      })}
    </div>
  );
}
const navBtnBase = {
  flex: 1, background: "transparent", border: 0, cursor: "pointer",
  display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
  fontFamily: "inherit", padding: 4,
};
window.BottomNav = BottomNav;

// ---------- Buttons ----------
function Btn({ children, kind = "primary", icon, onClick, disabled, fullWidth, style }) {
  const s = {
    primary:   { bg: K.olive, fg: "#FAF8F5" },
    secondary: { bg: K.surface, fg: K.fg, border: `1px solid ${K.borderStrong}` },
    accent:    { bg: K.gold, fg: K.fg },
    ghost:     { bg: "transparent", fg: K.olive },
    danger:    { bg: K.error, fg: "#fff" },
  }[kind];
  return (
    <button onClick={onClick} disabled={disabled} style={{
      minHeight: 52, width: fullWidth !== false ? "100%" : "auto",
      padding: "0 24px", borderRadius: 24, border: s.border || "none",
      background: s.bg, color: s.fg,
      fontFamily: "inherit", fontSize: 16, fontWeight: 600,
      display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 8,
      cursor: disabled ? "not-allowed" : "pointer", opacity: disabled ? 0.4 : 1,
      ...style,
    }}>
      {icon}{children}
    </button>
  );
}
window.Btn = Btn;

// ---------- Field ----------
function Field({ label, hint, error, children, prefix, dir = "ltr" }) {
  return (
    <div style={{ marginBottom: 14 }}>
      {label && <div style={{ fontSize: 12, fontWeight: 600, color: K.fg2, marginBottom: 6, letterSpacing: "0.02em" }}>{label}</div>}
      <div style={{ position: "relative" }}>
        {prefix && <div style={{
          position: "absolute", [dir === "rtl" ? "right" : "left"]: 14, top: "50%",
          transform: "translateY(-50%)", color: K.fg2, fontWeight: 600,
          fontFamily: "'JetBrains Mono', monospace", fontSize: 14, pointerEvents: "none",
        }}>{prefix}</div>}
        {children}
      </div>
      {error && <div style={{ fontSize: 12, color: K.error, marginTop: 6 }}>{error}</div>}
      {hint && !error && <div style={{ fontSize: 12, color: K.fg3, marginTop: 6 }}>{hint}</div>}
    </div>
  );
}
function Input({ value, onChange, placeholder, type = "text", style, prefixWidth = 0 }) {
  return (
    <input value={value || ""} onChange={(e) => onChange?.(e.target.value)} placeholder={placeholder} type={type}
      style={{
        width: "100%", boxSizing: "border-box", minHeight: 52,
        padding: prefixWidth ? `0 16px 0 ${prefixWidth}px` : "0 16px",
        background: K.surface, color: K.fg,
        border: `1px solid ${K.border}`, borderRadius: 12,
        fontFamily: "inherit", fontSize: 16, outline: "none", ...style,
      }}
      onFocus={(e) => { e.target.style.borderColor = K.olive; e.target.style.boxShadow = `0 0 0 3px ${K.olive50}`; }}
      onBlur={(e) => { e.target.style.borderColor = K.border; e.target.style.boxShadow = "none"; }}
    />
  );
}
window.Field = Field; window.Input = Input;

// ---------- Pills / chips ----------
function Pill({ kind = "info", icon, children, large }) {
  const styles = {
    success: { bg: K.successBg, fg: K.successFg },
    warning: { bg: K.warningBg, fg: K.warningFg },
    error:   { bg: K.errorBg, fg: K.errorFg },
    info:    { bg: K.olive50, fg: K.olive },
    offline: { bg: K.terra50, fg: K.terra700 },
    pending: { bg: K.warningBg, fg: K.warningFg },
    accent:  { bg: K.gold50, fg: K.terra700 },
  }[kind] || { bg: K.olive50, fg: K.olive };
  return (
    <span style={{
      display: "inline-flex", alignItems: "center", gap: 6,
      padding: large ? "6px 14px" : "4px 10px",
      borderRadius: 999, background: styles.bg, color: styles.fg,
      fontSize: large ? 13 : 12, fontWeight: 600, letterSpacing: "0.02em",
    }}>
      {icon}{children}
    </span>
  );
}
window.Pill = Pill;

// ---------- Logo ----------
// Canonical Kashi mark — Tatreez 8-point star inside QR-finder corners,
// gold dot = cryptographic seal. Mirrors preview/logo.html exactly.
function KashiMark({ size = 36, color = K.olive, bg, glyph = "#FAF8F5", small = false }) {
  // Background tile color — when `bg` is passed, that's the tile; otherwise use `color`.
  const tileFill = bg || color;
  // Glyph stroke color — light on dark tiles, olive on light tiles.
  const stroke = bg ? glyph : "#FAF8F5";
  // Below ~32px we drop the QR corner outlines and merge tatreez into a chunky cross.
  const compact = small || size <= 32;
  return (
    <div style={{
      width: size, height: size, borderRadius: size * 0.25,
      background: tileFill, display: "grid", placeItems: "center",
    }}>
      <svg width={size} height={size} viewBox="0 0 64 64" aria-label="Kashi mark">
        {compact ? (
          <g fill={stroke}>
            <rect x="8"  y="8"  width="14" height="14" rx="3"/>
            <rect x="42" y="8"  width="14" height="14" rx="3"/>
            <rect x="8"  y="42" width="14" height="14" rx="3"/>
            <rect x="28" y="22" width="8"  height="8"/>
            <rect x="22" y="28" width="8"  height="8"/>
            <rect x="28" y="34" width="8"  height="8"/>
            <rect x="34" y="28" width="8"  height="8"/>
          </g>
        ) : (
          <g fill="none" stroke={stroke} strokeWidth="2.4" opacity="0.95">
            {/* QR finder corners */}
            <rect x="8"  y="8"  width="14" height="14" rx="3"/>
            <rect x="42" y="8"  width="14" height="14" rx="3"/>
            <rect x="8"  y="42" width="14" height="14" rx="3"/>
            <rect x="12" y="12" width="6" height="6" fill={stroke}/>
            <rect x="46" y="12" width="6" height="6" fill={stroke}/>
            <rect x="12" y="46" width="6" height="6" fill={stroke}/>
            {/* Tatreez 8-point star */}
            <g fill={stroke} stroke="none">
              <rect x="30" y="22" width="4" height="4"/>
              <rect x="30" y="38" width="4" height="4"/>
              <rect x="22" y="30" width="4" height="4"/>
              <rect x="38" y="30" width="4" height="4"/>
              <rect x="26" y="26" width="4" height="4"/>
              <rect x="34" y="26" width="4" height="4"/>
              <rect x="26" y="34" width="4" height="4"/>
              <rect x="34" y="34" width="4" height="4"/>
              <rect x="30" y="30" width="4" height="4"/>
            </g>
          </g>
        )}
        {/* Gold cryptographic seal */}
        <circle cx="32" cy="32" r={compact ? 1.4 : 1.8} fill={K.gold}/>
      </svg>
    </div>
  );
}
// Bilingual lockup — mark + "Kashi" wordmark + كاشي, RTL-aware.
function KashiLockup({ size = 36, color = K.olive, bg, glyph = "#FAF8F5", textColor, dir = "ltr" }) {
  const word = textColor || (bg ? glyph : K.fg);
  return (
    <div style={{
      display: "inline-flex", alignItems: "center", gap: 12,
      flexDirection: dir === "rtl" ? "row-reverse" : "row",
    }}>
      <KashiMark size={size} color={color} bg={bg} glyph={glyph}/>
      <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
        <span style={{
          fontFamily: "'Inter', system-ui, sans-serif",
          fontWeight: 700, fontSize: size * 0.55, letterSpacing: "-0.02em",
          color: word,
        }}>Kashi</span>
        <span style={{ width: 4, height: 4, borderRadius: 999, background: K.gold }}/>
        <span style={{
          fontFamily: "'IBM Plex Sans Arabic', sans-serif",
          fontWeight: 700, fontSize: size * 0.55, color: word, marginBottom: -2,
        }}>كاشي</span>
      </div>
    </div>
  );
}
window.KashiMark = KashiMark;
window.KashiLockup = KashiLockup;

// ---------- QR Code mock ----------
function QRMock({ size = 200, light = "#fff", dark = "#1A1A1A", seed = 0 }) {
  const cells = 25;
  // seeded pseudo-random
  let s = seed * 9301 + 49297;
  const rand = () => { s = (s * 9301 + 49297) % 233280; return s / 233280; };
  const grid = Array.from({ length: cells * cells }).map((_, i) => {
    const r = Math.floor(i / cells), c = i % cells;
    // corners — 7x7 finder patterns
    const inFinder = (r < 7 && c < 7) || (r < 7 && c > cells - 8) || (r > cells - 8 && c < 7);
    if (inFinder) {
      const localR = r > cells - 8 ? r - (cells - 7) : r;
      const localC = c > cells - 8 ? c - (cells - 7) : c;
      const isOuter = localR === 0 || localR === 6 || localC === 0 || localC === 6;
      const isInner = localR >= 2 && localR <= 4 && localC >= 2 && localC <= 4;
      return isOuter || isInner;
    }
    return rand() > 0.5;
  });
  return (
    <div style={{
      width: size, height: size, padding: size * 0.06, background: light, borderRadius: 12,
      display: "grid", gridTemplateColumns: `repeat(${cells}, 1fr)`, gap: 0,
    }}>
      {grid.map((on, i) => <div key={i} style={{ background: on ? dark : "transparent", aspectRatio: "1/1" }}/>)}
    </div>
  );
}
window.QRMock = QRMock;

// ---------- Numpad (for OTP / amount) ----------
function Numpad({ onKey, dec = false }) {
  const keys = ["1","2","3","4","5","6","7","8","9", dec ? "." : "", "0", "←"];
  return (
    <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 8 }}>
      {keys.map((k, i) => (
        <button key={i} onClick={() => k && onKey?.(k)} style={{
          height: 56, borderRadius: 16, border: "none", background: k ? K.surface : "transparent",
          fontSize: 20, fontWeight: 600, color: K.fg, fontFamily: "inherit",
          cursor: k ? "pointer" : "default",
          boxShadow: k ? "0 1px 2px rgba(26,26,26,0.04)" : "none",
        }}>{k}</button>
      ))}
    </div>
  );
}
window.Numpad = Numpad;

// ---------- Empty state ----------
function EmptyState({ icon, title, body }) {
  return (
    <div style={{ padding: "40px 24px", textAlign: "center" }}>
      <div style={{
        width: 72, height: 72, borderRadius: 999, margin: "0 auto 16px",
        background: K.olive50, color: K.olive, display: "grid", placeItems: "center",
      }}>{icon}</div>
      <div style={{ fontSize: 17, fontWeight: 600 }}>{title}</div>
      <div style={{ fontSize: 13, color: K.fg2, marginTop: 6, maxWidth: 260, marginLeft: "auto", marginRight: "auto" }}>{body}</div>
    </div>
  );
}
window.EmptyState = EmptyState;

// ---------- Shimmer / loading row ----------
function Shimmer({ w = "100%", h = 12, r = 6, style }) {
  return (
    <div style={{
      width: w, height: h, borderRadius: r,
      background: `linear-gradient(90deg, ${K.surface2} 0%, ${K.bg} 50%, ${K.surface2} 100%)`,
      backgroundSize: "200% 100%", animation: "kshimmer 1.4s ease-in-out infinite",
      ...style,
    }}/>
  );
}
window.Shimmer = Shimmer;

// Inject shimmer keyframes once.
if (!document.getElementById("kashi-keyframes")) {
  const st = document.createElement("style"); st.id = "kashi-keyframes";
  st.textContent = `
    @keyframes kshimmer { 0% { background-position: 200% 0; } 100% { background-position: -200% 0; } }
    @keyframes kradar { 0% { transform: scale(0.6); opacity: 0.7; } 100% { transform: scale(2.4); opacity: 0; } }
    @keyframes kpulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
    @keyframes kcheckPop { 0% { transform: scale(0); } 60% { transform: scale(1.15); } 100% { transform: scale(1); } }
  `;
  document.head.appendChild(st);
}
