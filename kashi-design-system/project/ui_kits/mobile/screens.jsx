// Kashi UI Kit — Screens (Home, Send, Offline Pay, Success, Activity)
const { useState: useS } = React;

function HomeScreen({ onNav }) {
  return (
    <div style={{ padding: "0 16px 100px" }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "8px 0 16px" }}>
        <div>
          <div style={{ fontSize: 12, color: "#6B6B6B", fontWeight: 500 }}>أهلاً</div>
          <div style={{ fontSize: 20, fontWeight: 700, marginTop: 2 }}>Mohammed</div>
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <button style={{ width: 40, height: 40, borderRadius: 999, border: "1px solid #E8E5E0", background: "#fff", display: "grid", placeItems: "center", cursor: "pointer" }}><IconBell size={18}/></button>
          <div style={{ width: 40, height: 40, borderRadius: 999, background: "#2D5F3F", color: "#fff", display: "grid", placeItems: "center", fontWeight: 700, fontSize: 14 }}>MA</div>
        </div>
      </div>

      <BalanceCard amount={1250} online={true}/>

      <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
        <ActionTile icon={<IconArrowDown size={20}/>} label="Receive" onClick={() => onNav("receive")}/>
        <ActionTile icon={<IconSend size={20}/>} label="Send" onClick={() => onNav("send")}/>
        <ActionTile icon={<IconQR size={20}/>} label="Pay offline" accent="gold" onClick={() => onNav("offline")}/>
        <ActionTile icon={<IconPlus size={20}/>} label="Top up" onClick={() => onNav("topup")}/>
      </div>

      <div style={{ marginTop: 24, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <div style={{ fontSize: 16, fontWeight: 600 }}>Recent activity</div>
        <button style={{ background: "transparent", border: 0, color: "#2D5F3F", fontSize: 13, fontWeight: 600, cursor: "pointer" }}>See all</button>
      </div>

      <div style={{ background: "#FFFFFF", borderRadius: 16, padding: "4px 16px", marginTop: 12, boxShadow: "0 4px 12px rgba(26,26,26,0.06)" }}>
        <TxItem kind="in" name="From Bank of Palestine" sub="via E-SADAD · Today" amount={500}/>
        <TxItem kind="out" name="Mahmoud Al-Khatib" sub="Offline payment · 2:14 PM" amount={80} signed/>
        <TxItem kind="out" name="iBuraq · Family transfer" sub="Yesterday" amount={250}/>
      </div>
    </div>
  );
}

function SendScreen({ onBack, onSend }) {
  const [amt, setAmt] = useS("250.00");
  return (
    <div>
      <TopBar title="Send money" onBack={onBack}/>
      <div style={{ padding: "0 20px" }}>
        <div style={{ background: "#FFFFFF", borderRadius: 16, padding: 20, boxShadow: "0 4px 12px rgba(26,26,26,0.06)" }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: "#6B6B6B", textTransform: "uppercase", letterSpacing: "0.06em" }}>Amount</div>
          <div style={{ display: "flex", alignItems: "baseline", gap: 8, marginTop: 6 }}>
            <span style={{ fontSize: 32, color: "#9A9A9A", fontWeight: 600 }}>₪</span>
            <input value={amt} onChange={e => setAmt(e.target.value)} style={{
              border: 0, outline: 0, fontFamily: "inherit", fontSize: 40, fontWeight: 700,
              letterSpacing: "-0.02em", width: "100%", fontVariantNumeric: "tabular-nums", color: "#1A1A1A"
            }}/>
          </div>
          <div style={{ fontSize: 12, color: "#6B6B6B", marginTop: 6 }}>Available: <b style={{ color: "#1A1A1A", fontVariantNumeric: "tabular-nums" }}>₪ 1,250.00</b></div>
        </div>

        <div style={{ marginTop: 16 }}>
          <div style={{ fontSize: 13, fontWeight: 600, color: "#6B6B6B", marginBottom: 8 }}>Recipient</div>
          <div style={{ background: "#fff", borderRadius: 16, border: "1px solid #E8E5E0", overflow: "hidden" }}>
            {[
              { name: "Mahmoud Al-Khatib", phone: "+970 59 234 5678" },
              { name: "Layla Hammad", phone: "+970 59 871 2200" },
              { name: "Ahmad Saadi", phone: "+970 56 412 8870" },
            ].map((r, i) => (
              <div key={i} style={{ display: "flex", alignItems: "center", gap: 12, padding: 12, borderBottom: i < 2 ? "1px solid #E8E5E0" : "none", cursor: "pointer" }}>
                <div style={{ width: 36, height: 36, borderRadius: 999, background: "#EAF2EC", color: "#2D5F3F", display: "grid", placeItems: "center", fontWeight: 700, fontSize: 13 }}>
                  {r.name.split(" ").map(s => s[0]).slice(0,2).join("")}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontSize: 14, fontWeight: 600 }}>{r.name}</div>
                  <div style={{ fontSize: 12, color: "#6B6B6B", fontFamily: "'JetBrains Mono', monospace" }}>{r.phone}</div>
                </div>
                <IconChevron size={16} style={{ color: "#9A9A9A" }}/>
              </div>
            ))}
          </div>
        </div>

        <div style={{ marginTop: 20 }}>
          <Button onClick={onSend}>Continue</Button>
        </div>
      </div>
    </div>
  );
}

function OfflinePayScreen({ onBack, onConfirm }) {
  return (
    <div>
      <TopBar title="Pay offline" onBack={onBack} action={<StatusPill kind="offline" icon={<IconWifiOff size={11}/>}>Offline</StatusPill>}/>
      <div style={{ padding: "0 20px" }}>
        <div style={{
          background: "linear-gradient(160deg, #FBF3E1 0%, #FBEFE6 100%)",
          borderRadius: 24, padding: 24, textAlign: "center",
          border: "1px solid rgba(212,162,76,0.25)",
        }}>
          <div style={{ fontSize: 12, fontWeight: 600, color: "#A4582E", textTransform: "uppercase", letterSpacing: "0.08em" }}>Cryptographically signed</div>
          <div style={{ fontSize: 14, color: "#6B6B6B", marginTop: 4, marginBottom: 16 }}>Show this code to the recipient</div>

          {/* QR code mock */}
          <div style={{
            width: 200, height: 200, margin: "0 auto", background: "#FFFFFF",
            borderRadius: 16, padding: 12, boxShadow: "0 12px 32px rgba(26,26,26,0.08)",
            display: "grid", gridTemplateColumns: "repeat(11, 1fr)", gridAutoRows: "1fr", gap: 1.5,
          }}>
            {Array.from({ length: 121 }).map((_, i) => {
              const seed = (i * 73 + 17) % 100;
              const corner = (i < 11 && (i % 11 < 3 || i % 11 > 7)) || (i > 109 && (i % 11 < 3));
              const filled = corner || seed > 55;
              return <div key={i} style={{ background: filled ? "#1A1A1A" : "transparent", borderRadius: 1 }}/>;
            })}
          </div>

          <div style={{ marginTop: 16, fontSize: 28, fontWeight: 700, fontVariantNumeric: "tabular-nums", color: "#1A1A1A" }}>₪ 80.00</div>
          <div style={{ fontSize: 13, color: "#6B6B6B", marginTop: 4 }}>To Mahmoud Al-Khatib</div>

          <div style={{ marginTop: 16, padding: "10px 14px", background: "rgba(45,95,63,0.06)", borderRadius: 12, display: "inline-flex", alignItems: "center", gap: 8, color: "#2D5F3F", fontSize: 12, fontFamily: "'JetBrains Mono', monospace" }}>
            <IconKey size={14}/>
            sig: 7f3a · 9c21 · b8e4
          </div>
        </div>

        <div style={{ marginTop: 16, padding: 14, background: "#EAF2EC", borderRadius: 12, display: "flex", gap: 10, alignItems: "flex-start" }}>
          <span style={{ color: "#2D5F3F", marginTop: 1 }}><IconShield size={18}/></span>
          <div style={{ fontSize: 12, color: "#234B32", lineHeight: 1.5 }}>
            This payment is signed with your private key. The recipient verifies it offline; the network settles when either of you reconnects.
          </div>
        </div>

        <div style={{ marginTop: 16 }}>
          <Button onClick={onConfirm}>I've shown the code</Button>
        </div>
      </div>
    </div>
  );
}

function SuccessScreen({ onDone }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", padding: "60px 24px 24px", textAlign: "center", height: "100%" }}>
      <div style={{
        width: 88, height: 88, borderRadius: 999,
        background: "linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%)",
        display: "grid", placeItems: "center", color: "#fff",
        boxShadow: "0 12px 32px rgba(45,95,63,0.32)",
      }}><IconCheck size={44} stroke={2.5}/></div>

      <div style={{ fontSize: 26, fontWeight: 700, marginTop: 20, letterSpacing: "-0.01em" }}>Payment signed</div>
      <div style={{ fontSize: 14, color: "#6B6B6B", marginTop: 6, maxWidth: 280 }}>
        ₪ 80.00 to Mahmoud will settle automatically when one of you reconnects.
      </div>

      <div style={{ marginTop: 24, width: "100%", padding: 16, background: "#FFFFFF", borderRadius: 16, border: "1px solid #E8E5E0" }}>
        {[
          ["Amount", "₪ 80.00"],
          ["To", "Mahmoud Al-Khatib"],
          ["Status", "Signed · Pending settlement"],
          ["Reference", "KSH-7F3A9C21"],
        ].map(([k, v], i) => (
          <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "8px 0", borderBottom: i < 3 ? "1px solid #E8E5E0" : "none", fontSize: 13 }}>
            <span style={{ color: "#6B6B6B" }}>{k}</span>
            <span style={{ fontWeight: 600, fontFamily: k === "Reference" ? "'JetBrains Mono', monospace" : "inherit", fontVariantNumeric: "tabular-nums" }}>{v}</span>
          </div>
        ))}
      </div>

      <div style={{ width: "100%", marginTop: 20 }}>
        <Button onClick={onDone}>Done</Button>
      </div>
    </div>
  );
}

function ActivityScreen({ onBack }) {
  const txs = [
    { kind: "in", name: "From Bank of Palestine", sub: "via E-SADAD · Today, 9:42 AM", amount: 500 },
    { kind: "out", name: "Mahmoud Al-Khatib", sub: "Offline · Today, 2:14 PM", amount: 80, signed: true },
    { kind: "out", name: "iBuraq · Family", sub: "Yesterday, 6:30 PM", amount: 250 },
    { kind: "in", name: "From Layla", sub: "Yesterday, 11:00 AM", amount: 120 },
    { kind: "out", name: "Abu Salem Market", sub: "Offline · 24/04/2026", amount: 32.50, signed: true },
    { kind: "out", name: "Pharmacy Al-Quds", sub: "23/04/2026", amount: 56 },
  ];
  return (
    <div>
      <TopBar title="Activity" onBack={onBack}/>
      <div style={{ padding: "0 16px" }}>
        <div style={{ display: "flex", gap: 8, marginBottom: 12 }}>
          {["All", "Sent", "Received", "Offline"].map((t, i) => (
            <button key={t} style={{
              padding: "8px 14px", borderRadius: 999,
              border: i === 0 ? "1px solid #2D5F3F" : "1px solid #E8E5E0",
              background: i === 0 ? "#2D5F3F" : "#FFFFFF",
              color: i === 0 ? "#FAF8F5" : "#1A1A1A",
              fontSize: 12, fontWeight: 600, cursor: "pointer", fontFamily: "inherit"
            }}>{t}</button>
          ))}
        </div>
        <div style={{ background: "#FFFFFF", borderRadius: 16, padding: "0 16px", boxShadow: "0 4px 12px rgba(26,26,26,0.06)" }}>
          {txs.map((t, i) => <TxItem key={i} {...t}/>)}
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { HomeScreen, SendScreen, OfflinePayScreen, SuccessScreen, ActivityScreen });
