// Kashi UI Kit — Components
// Pixel-perfect React recreation of the Kashi mobile wallet.
// All components consume tokens from /colors_and_type.css.

const { useState, useRef, useEffect } = React;

// ---------- Lucide-style inline SVG icons (1.75 stroke) ----------
const Icon = ({ d, size = 24, stroke = 1.75, fill = "none", children, style }) => (
  <svg viewBox="0 0 24 24" width={size} height={size} fill={fill}
    stroke="currentColor" strokeWidth={stroke} strokeLinecap="round" strokeLinejoin="round"
    style={style}>
    {d ? <path d={d}/> : children}
  </svg>
);
const IconWallet  = (p) => <Icon {...p}><path d="M21 12V7a2 2 0 0 0-2-2H5a2 2 0 0 0 0 4h16v4"/><path d="M3 5v14a2 2 0 0 0 2 2h16v-4"/><circle cx="17" cy="14" r="1.5"/></Icon>;
const IconQR      = (p) => <Icon {...p}><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3M21 14v.01M21 21v.01M14 21v.01M17 21h4M21 17h-3"/></Icon>;
const IconShield  = (p) => <Icon {...p}><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="m9 12 2 2 4-4"/></Icon>;
const IconWifiOff = (p) => <Icon {...p}><line x1="2" y1="2" x2="22" y2="22"/><path d="M8.5 16.5a5 5 0 0 1 7 0"/><path d="M2 8.82a15 15 0 0 1 4.17-2.65"/><path d="M10.66 5c4.01-.36 8.14.9 11.34 3.76"/><path d="M16.85 11.25a10 10 0 0 1 2.22 1.68"/><line x1="12" y1="20" x2="12" y2="20"/></Icon>;
const IconActivity= (p) => <Icon {...p}><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></Icon>;
const IconHome    = (p) => <Icon {...p}><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></Icon>;
const IconUser    = (p) => <Icon {...p}><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></Icon>;
const IconArrowDown=(p) => <Icon {...p}><path d="M12 5v14"/><path d="m19 12-7 7-7-7"/></Icon>;
const IconArrowUp = (p) => <Icon {...p}><path d="M12 19V5"/><path d="m5 12 7-7 7 7"/></Icon>;
const IconSend    = (p) => <Icon {...p}><path d="m22 2-7 20-4-9-9-4z"/><path d="M22 2 11 13"/></Icon>;
const IconCheck   = (p) => <Icon {...p}><path d="M20 6 9 17l-5-5"/></Icon>;
const IconChevron = (p) => <Icon {...p}><polyline points="9 18 15 12 9 6"/></Icon>;
const IconClose   = (p) => <Icon {...p}><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></Icon>;
const IconKey     = (p) => <Icon {...p}><circle cx="7.5" cy="15.5" r="5.5"/><path d="m21 2-9.6 9.6"/><path d="m15.5 7.5 3 3L22 7l-3-3"/></Icon>;
const IconCopy    = (p) => <Icon {...p}><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></Icon>;
const IconBell    = (p) => <Icon {...p}><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></Icon>;
const IconPlus    = (p) => <Icon {...p}><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></Icon>;

// ---------- Currency formatter ----------
const fmt = (n) => "₪ " + n.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

// ---------- Status pill ----------
function StatusPill({ kind, children, icon }) {
  const styles = {
    success: { bg: "#E8F5E9", fg: "#2E7D32" },
    warning: { bg: "#FFF4E5", fg: "#B86E00" },
    error:   { bg: "#FCEAEA", fg: "#B71C1C" },
    info:    { bg: "#EAF2EC", fg: "#2D5F3F" },
    offline: { bg: "#FBEFE6", fg: "#A4582E" },
  }[kind] || { bg: "#EAF2EC", fg: "#2D5F3F" };
  return (
    <span style={{ display: "inline-flex", alignItems: "center", gap: 4, padding: "4px 10px",
      borderRadius: 999, background: styles.bg, color: styles.fg,
      fontSize: 12, fontWeight: 600, letterSpacing: "0.02em" }}>
      {icon}{children}
    </span>
  );
}

// ---------- Wallet balance hero card ----------
function BalanceCard({ amount, online = true, iban = "PS00 KASH 0000 0123 4567 89" }) {
  return (
    <div style={{
      background: "linear-gradient(135deg,#2D5F3F 0%,#234B32 100%)",
      borderRadius: 24, padding: 22, color: "#FAF8F5",
      boxShadow: "0 8px 24px rgba(45,95,63,0.18)",
      position: "relative", overflow: "hidden",
    }}>
      <div style={{ position: "absolute", right: -50, top: -50, width: 180, height: 180,
        borderRadius: "50%", background: "radial-gradient(circle, rgba(212,162,76,0.18), transparent 70%)" }} />
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", position: "relative" }}>
        <div style={{ fontSize: 12, fontWeight: 500, opacity: 0.75, letterSpacing: "0.06em", textTransform: "uppercase" }}>
          Wallet balance
        </div>
        <span style={{ display: "inline-flex", gap: 6, alignItems: "center",
          background: "rgba(255,255,255,0.14)", padding: "4px 10px", borderRadius: 999,
          fontSize: 11, fontWeight: 600 }}>
          <span style={{ width: 6, height: 6, borderRadius: 999, background: online ? "#7BD389" : "#D4A24C" }}/>
          {online ? "Online" : "Offline"}
        </span>
      </div>
      <div style={{ fontSize: 38, fontWeight: 700, letterSpacing: "-0.02em", marginTop: 8,
        fontVariantNumeric: "tabular-nums" }}>{fmt(amount)}</div>
      <div style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: 12,
        opacity: 0.78, marginTop: 14, letterSpacing: "0.04em",
        display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <span>{iban}</span>
        <span style={{ color: "rgba(255,255,255,0.7)" }}><IconCopy size={14} /></span>
      </div>
    </div>
  );
}

// ---------- Action tile (Send / Receive / Pay offline / Top up) ----------
function ActionTile({ icon, label, accent, onClick }) {
  return (
    <button onClick={onClick} style={{
      flex: 1, background: "#FFFFFF", border: "1px solid #E8E5E0", borderRadius: 16,
      padding: "14px 8px", display: "flex", flexDirection: "column", alignItems: "center", gap: 8,
      cursor: "pointer", fontFamily: "inherit", color: "#1A1A1A",
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 999,
        background: accent === "gold" ? "#FBF3E1" : "#EAF2EC",
        color: accent === "gold" ? "#B0833A" : "#2D5F3F",
        display: "grid", placeItems: "center"
      }}>{icon}</div>
      <span style={{ fontSize: 12, fontWeight: 600 }}>{label}</span>
    </button>
  );
}

// ---------- Transaction list item ----------
function TxItem({ kind, name, sub, amount, signed }) {
  const inflow = kind === "in";
  return (
    <div style={{ display: "grid", gridTemplateColumns: "40px 1fr auto", gap: 12,
      alignItems: "center", padding: "12px 0", borderBottom: "1px solid #E8E5E0" }}>
      <div style={{ width: 40, height: 40, borderRadius: 999,
        background: inflow ? "#E8F5E9" : "#FBEFE6",
        color: inflow ? "#2E7D32" : "#A4582E",
        display: "grid", placeItems: "center" }}>
        {inflow ? <IconArrowDown size={18}/> : <IconArrowUp size={18}/>}
      </div>
      <div>
        <div style={{ fontSize: 14, fontWeight: 600, display: "flex", alignItems: "center", gap: 6 }}>
          {name}
          {signed && <span style={{ color: "#2D5F3F" }}><IconShield size={13} stroke={2}/></span>}
        </div>
        <div style={{ fontSize: 11, color: "#6B6B6B", marginTop: 2 }}>{sub}</div>
      </div>
      <div style={{ fontSize: 14, fontWeight: 600,
        color: inflow ? "#2E7D32" : "#1A1A1A",
        fontVariantNumeric: "tabular-nums" }}>
        {inflow ? "+ " : "− "}{fmt(amount)}
      </div>
    </div>
  );
}

// ---------- Bottom nav ----------
function BottomNav({ active, onChange }) {
  const items = [
    { id: "home", label: "Home", icon: <IconHome size={22}/> },
    { id: "activity", label: "Activity", icon: <IconActivity size={22}/> },
    { id: "pay", label: "Pay", center: true },
    { id: "wallet", label: "Wallet", icon: <IconWallet size={22}/> },
    { id: "me", label: "Me", icon: <IconUser size={22}/> },
  ];
  return (
    <div style={{
      position: "absolute", bottom: 0, left: 0, right: 0,
      height: 80, background: "rgba(250,248,245,0.92)",
      backdropFilter: "blur(20px)", WebkitBackdropFilter: "blur(20px)",
      borderTop: "1px solid #E8E5E0",
      display: "flex", alignItems: "flex-start", padding: "10px 8px 0",
    }}>
      {items.map(it => it.center ? (
        <button key={it.id} onClick={() => onChange(it.id)} style={{
          flex: 1, background: "transparent", border: 0, padding: 0, cursor: "pointer",
          display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
          fontFamily: "inherit",
        }}>
          <div style={{
            width: 56, height: 56, borderRadius: 999,
            background: "#2D5F3F", color: "#FAF8F5",
            display: "grid", placeItems: "center",
            boxShadow: "0 6px 16px rgba(45,95,63,0.32)",
            marginTop: -22,
          }}><IconQR size={26} stroke={2}/></div>
          <span style={{ fontSize: 10, fontWeight: 600, color: "#2D5F3F" }}>Pay</span>
        </button>
      ) : (
        <button key={it.id} onClick={() => onChange(it.id)} style={{
          flex: 1, background: "transparent", border: 0, cursor: "pointer",
          display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
          color: active === it.id ? "#2D5F3F" : "#9A9A9A",
          fontFamily: "inherit", padding: 4,
        }}>
          {it.icon}
          <span style={{ fontSize: 10, fontWeight: 600 }}>{it.label}</span>
        </button>
      ))}
    </div>
  );
}

// ---------- Top bar ----------
function TopBar({ title, onBack, action }) {
  return (
    <div style={{
      display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "8px 16px 12px", minHeight: 44,
    }}>
      {onBack ? (
        <button onClick={onBack} style={{
          width: 36, height: 36, borderRadius: 999, border: "1px solid #E8E5E0",
          background: "#FFFFFF", display: "grid", placeItems: "center", cursor: "pointer", color: "#1A1A1A",
        }}>
          <IconChevron size={18} style={{ transform: "scaleX(-1)" }}/>
        </button>
      ) : <div style={{ width: 36 }}/>}
      <div style={{ fontSize: 16, fontWeight: 600 }}>{title}</div>
      <div style={{ width: 36, display: "flex", justifyContent: "flex-end" }}>{action}</div>
    </div>
  );
}

// ---------- Primary button ----------
function Button({ children, kind = "primary", icon, onClick, disabled, style }) {
  const s = {
    primary:   { bg: "#2D5F3F", fg: "#FAF8F5" },
    secondary: { bg: "#FFFFFF", fg: "#1A1A1A", border: "1px solid #D4CFC6" },
    accent:    { bg: "#D4A24C", fg: "#1A1A1A" },
    ghost:     { bg: "transparent", fg: "#2D5F3F" },
  }[kind];
  return (
    <button onClick={onClick} disabled={disabled} style={{
      minHeight: 52, width: "100%",
      padding: "0 24px", borderRadius: 24, border: s.border || "none",
      background: s.bg, color: s.fg,
      fontFamily: "inherit", fontSize: 16, fontWeight: 600,
      display: "inline-flex", alignItems: "center", justifyContent: "center", gap: 8,
      cursor: disabled ? "not-allowed" : "pointer", opacity: disabled ? 0.4 : 1,
      transition: "transform 100ms, opacity 100ms",
      ...style
    }}>
      {icon}{children}
    </button>
  );
}

// Export to window so other Babel scripts can import
Object.assign(window, {
  fmt, IconWallet, IconQR, IconShield, IconWifiOff, IconActivity, IconHome,
  IconUser, IconArrowDown, IconArrowUp, IconSend, IconCheck, IconChevron, IconClose,
  IconKey, IconCopy, IconBell, IconPlus,
  StatusPill, BalanceCard, ActionTile, TxItem, BottomNav, TopBar, Button,
});
