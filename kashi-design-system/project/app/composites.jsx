// Kashi Android · Composites — balance card, action tiles, transaction tiles, sync header.

// ---------- Balance card (the hero) ----------
function BalanceCard({ amount = 1250, online = true, dir = "ltr" }) {
  return (
    <div style={{
      background: "linear-gradient(135deg,#2D5F3F 0%,#234B32 100%)",
      borderRadius: 24, padding: 22, color: "#FAF8F5",
      boxShadow: "0 8px 24px rgba(45,95,63,0.18)",
      position: "relative", overflow: "hidden",
    }}>
      <div style={{
        position: "absolute", [dir === "rtl" ? "left" : "right"]: -50, top: -50,
        width: 180, height: 180, borderRadius: "50%",
        background: "radial-gradient(circle, rgba(212,162,76,0.20), transparent 70%)",
      }}/>
      {/* faint olive leaf watermark */}
      <svg viewBox="0 0 100 100" style={{ position: "absolute", bottom: -20, [dir==="rtl"?"right":"left"]: -15, width: 130, height: 130, opacity: 0.06 }}>
        <path d="M70 20 C 35 30, 20 60, 30 85 C 65 75, 90 50, 85 25 C 80 22, 75 20, 70 20 Z" fill="#FAF8F5"/>
      </svg>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", position: "relative" }}>
        <div style={{ fontSize: 11, fontWeight: 600, opacity: 0.78, letterSpacing: "0.08em", textTransform: "uppercase" }}>
          {dir === "rtl" ? "رصيد المحفظة" : "Wallet balance"}
        </div>
        <span style={{
          display: "inline-flex", gap: 6, alignItems: "center",
          background: "rgba(255,255,255,0.14)", padding: "4px 10px", borderRadius: 999,
          fontSize: 11, fontWeight: 600,
        }}>
          <span style={{ width: 6, height: 6, borderRadius: 999,
            background: online ? "#7BD389" : K.gold,
            animation: online ? "kpulse 2s ease-in-out infinite" : "none" }}/>
          {online ? (dir === "rtl" ? "متصل" : "Online") : (dir === "rtl" ? "بدون اتصال" : "Offline")}
        </span>
      </div>
      <div style={{
        fontSize: 40, fontWeight: 700, letterSpacing: "-0.02em", marginTop: 8,
        fontVariantNumeric: "tabular-nums", position: "relative",
        fontFamily: dir === "rtl" ? "'IBM Plex Sans Arabic', sans-serif" : "inherit",
      }}>{dir === "rtl" ? `${fmtAmt(amount)} ₪` : fmtSh(amount)}</div>
      <div style={{
        fontFamily: "'JetBrains Mono', monospace", fontSize: 12,
        opacity: 0.78, marginTop: 14, letterSpacing: "0.04em",
        display: "flex", alignItems: "center", justifyContent: "space-between", position: "relative",
        direction: "ltr",
      }}>
        <span>PS00 KASH 0000 0123 4567 89</span>
        <span style={{ opacity: 0.7 }}><Ico.copy size={14}/></span>
      </div>
    </div>
  );
}
window.BalanceCard = BalanceCard;

// ---------- Action tile (home grid) ----------
function ActionTile({ icon: Icon, label, accent, onClick }) {
  const colors = {
    olive: { bg: K.olive50, fg: K.olive },
    gold:  { bg: K.gold50, fg: K.terra700 },
    terra: { bg: K.terra50, fg: K.terra700 },
  }[accent || "olive"];
  return (
    <button onClick={onClick} style={{
      flex: 1, background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16,
      padding: "14px 8px", display: "flex", flexDirection: "column", alignItems: "center", gap: 8,
      cursor: "pointer", fontFamily: "inherit", color: K.fg,
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 999,
        background: colors.bg, color: colors.fg, display: "grid", placeItems: "center",
      }}><Icon size={20}/></div>
      <span style={{ fontSize: 12, fontWeight: 600, textAlign: "center" }}>{label}</span>
    </button>
  );
}
window.ActionTile = ActionTile;

// ---------- Transaction tile ----------
function TxTile({ kind, name, sub, amount, signed, pending, dir = "ltr" }) {
  const variants = {
    in:        { color: K.successFg, bg: K.successBg, icon: <Ico.arrowDn size={18}/>, sign: "+" },
    out:       { color: K.fg,        bg: K.surface2,  icon: <Ico.arrowUp size={18}/>, sign: "−" },
    p2pIn:     { color: K.successFg, bg: K.successBg, icon: <Ico.qr size={18}/>,      sign: "+" },
    p2pOut:    { color: K.fg,        bg: K.gold50,    icon: <Ico.qr size={18}/>,      sign: "−" },
    bank:      { color: K.fg,        bg: K.surface2,  icon: <Ico.bank size={18}/>,    sign: "−" },
    topup:     { color: K.successFg, bg: K.successBg, icon: <Ico.plus size={18}/>,    sign: "+" },
  };
  const v = variants[kind] || variants.out;
  const positive = v.sign === "+";
  return (
    <div style={{
      display: "grid", gridTemplateColumns: "40px 1fr auto", gap: 12,
      alignItems: "center", padding: "12px 0", borderBottom: `1px solid ${K.border}`,
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: 999, background: v.bg, color: v.color,
        display: "grid", placeItems: "center",
      }}>{v.icon}</div>
      <div>
        <div style={{ fontSize: 14, fontWeight: 600, display: "flex", alignItems: "center", gap: 6 }}>
          {name}
          {signed && <span style={{ color: K.olive }} title="Cryptographically signed"><Ico.shield size={13} sw={2}/></span>}
          {pending && <Pill kind="pending"><Ico.cloudOff size={10} sw={2}/>{dir==="rtl"?"معلّقة":"Pending"}</Pill>}
        </div>
        <div style={{ fontSize: 11, color: K.fg2, marginTop: 2 }}>{sub}</div>
      </div>
      <div style={{
        fontSize: 14, fontWeight: 600,
        color: positive ? K.successFg : K.fg,
        fontVariantNumeric: "tabular-nums", direction: "ltr",
      }}>{v.sign} {fmtSh(amount)}</div>
    </div>
  );
}
window.TxTile = TxTile;

// ---------- Sync status header bar (top of app) ----------
function SyncHeader({ status = "online", dir = "ltr" }) {
  if (status === "online") return null;
  const cfg = {
    offline: { bg: K.terra50, fg: K.terra700, icon: <Ico.wifiOff size={13} sw={2}/>, text: dir==="rtl"?"وضع عدم الاتصال — الدفع لا يزال يعمل":"You're offline — payments still work" },
    syncing: { bg: K.warningBg, fg: K.warningFg, icon: <Ico.refresh size={13} sw={2}/>, text: dir==="rtl"?"جاري المزامنة…":"Syncing pending payments…" },
    pending: { bg: K.gold50, fg: K.terra700, icon: <Ico.cloudOff size={13} sw={2}/>, text: dir==="rtl"?"3 معاملات في انتظار المزامنة":"3 transactions waiting to sync" },
  }[status];
  return (
    <div style={{
      background: cfg.bg, color: cfg.fg, padding: "8px 16px",
      display: "flex", alignItems: "center", gap: 8, fontSize: 12, fontWeight: 600,
    }}>
      {cfg.icon}<span>{cfg.text}</span>
    </div>
  );
}
window.SyncHeader = SyncHeader;

// ---------- Section title ----------
function SectionTitle({ children, action, dir = "ltr" }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 22, marginBottom: 12 }}>
      <div style={{ fontSize: 15, fontWeight: 700, fontFamily: dir==="rtl" ? "'IBM Plex Sans Arabic', sans-serif" : "inherit" }}>{children}</div>
      {action}
    </div>
  );
}
window.SectionTitle = SectionTitle;

// ---------- Avatar (initials) ----------
function Avatar({ name = "", size = 40, color = K.olive, bg = K.olive50 }) {
  const initials = name.split(" ").map(s => s[0]).slice(0, 2).join("").toUpperCase();
  return (
    <div style={{
      width: size, height: size, borderRadius: 999, background: bg, color,
      display: "grid", placeItems: "center", fontWeight: 700, fontSize: size * 0.4,
    }}>{initials}</div>
  );
}
window.Avatar = Avatar;

// ---------- Toast (ribbon at top) ----------
function Toast({ kind = "success", icon, children }) {
  const cfg = { success: { bg: K.olive, fg: "#FAF8F5" }, error: { bg: K.error, fg: "#fff" } }[kind];
  return (
    <div style={{
      position: "absolute", top: 38, left: 16, right: 16, zIndex: 50,
      background: cfg.bg, color: cfg.fg, padding: "12px 16px", borderRadius: 16,
      display: "flex", alignItems: "center", gap: 10, fontSize: 14, fontWeight: 600,
      boxShadow: "0 12px 32px rgba(26,26,26,0.18)",
    }}>{icon}<span>{children}</span></div>
  );
}
window.Toast = Toast;
