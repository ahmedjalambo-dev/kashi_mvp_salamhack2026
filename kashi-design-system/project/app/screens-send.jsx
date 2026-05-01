// Kashi · Receive / Top-up (6–7) and Offline P2P Send (8–12).

function ScreenReceive({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar title={dir==="rtl"?"استلام أموال":"Receive money"} onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", overflow: "auto" }}>
        <div style={{ background: K.surface, borderRadius: 20, padding: 20, boxShadow: "0 4px 12px rgba(26,26,26,0.06)" }}>
          <div style={{ fontSize: 12, color: K.fg2, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase" }}>{dir==="rtl"?"شارك بطاقتك":"Share your details"}</div>
          <div style={{ display: "grid", placeItems: "center", marginTop: 16 }}>
            <div style={{ padding: 10, background: K.olive50, borderRadius: 16 }}>
              <QRMock size={180} dark={K.olive} light={K.surface} seed={3}/>
            </div>
          </div>
          <div style={{ marginTop: 16, paddingTop: 16, borderTop: `1px dashed ${K.border}` }}>
            <CopyRow label={dir==="rtl"?"الهاتف":"Phone"} value="+970 59 123 4567"/>
            <CopyRow label={dir==="rtl"?"رقم الآيبان":"IBAN"} value="PS00 KASH 0000 0123 4567 89" mono/>
          </div>
        </div>
        <div style={{
          marginTop: 16, padding: 14, background: K.gold50, borderRadius: 16,
          display: "flex", gap: 12, alignItems: "flex-start",
        }}>
          <span style={{ color: K.terra700, marginTop: 2 }}><Ico.bank size={18}/></span>
          <div style={{ fontSize: 12, color: K.terra700, lineHeight: 1.6 }}>
            <strong>{dir==="rtl"?"الإيداع عبر E-SADAD":"Top up via E-SADAD"}</strong><br/>
            {dir==="rtl"?"افتح تطبيق بنكك واختر E-SADAD، ثم اختر «كاشي» وأدخل رقم الآيبان أعلاه.":"Open your bank app, choose E-SADAD, select \"Kashi\" and paste the IBAN above."}
          </div>
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px" }}>
        <Btn icon={<Ico.send size={18}/>}>{dir==="rtl"?"مشاركة البطاقة":"Share my details"}</Btn>
      </div>
    </Scaffold>
  );
}

function CopyRow({ label, value, mono }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 0" }}>
      <div>
        <div style={{ fontSize: 11, color: K.fg2, fontWeight: 500 }}>{label}</div>
        <div style={{ fontSize: 14, fontWeight: 600, marginTop: 2, fontFamily: mono ? "'JetBrains Mono', monospace" : "inherit", letterSpacing: mono ? "0.04em" : 0 }}>{value}</div>
      </div>
      <button style={{
        width: 36, height: 36, borderRadius: 999, border: 0, background: K.surface2,
        color: K.fg, display: "grid", placeItems: "center", cursor: "pointer",
      }}><Ico.copy size={16}/></button>
    </div>
  );
}

function ScreenReceiveSuccess({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", textAlign: "center" }}>
        <div style={{
          width: 96, height: 96, borderRadius: 999, background: K.olive, color: "#FAF8F5",
          display: "grid", placeItems: "center", animation: "kcheckPop 600ms cubic-bezier(.34,1.56,.64,1)",
        }}><Ico.check size={48} sw={2.5}/></div>
        <div style={{ fontSize: 24, fontWeight: 700, marginTop: 24 }}>{dir==="rtl"?"تم الاستلام":"Money received"}</div>
        <div style={{ fontSize: 38, fontWeight: 700, color: K.olive, marginTop: 6, fontVariantNumeric: "tabular-nums", letterSpacing: "-0.02em" }}>+ {fmtSh(500)}</div>
        <div style={{ fontSize: 13, color: K.fg2, marginTop: 8 }}>{dir==="rtl"?"من بنك فلسطين عبر E-SADAD":"From Bank of Palestine via E-SADAD"}</div>
        <div style={{ marginTop: 32, padding: "12px 18px", background: K.surface, borderRadius: 16, border: `1px solid ${K.border}` }}>
          <div style={{ fontSize: 11, color: K.fg2, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase" }}>{dir==="rtl"?"الرصيد الجديد":"New balance"}</div>
          <div style={{ fontSize: 22, fontWeight: 700, marginTop: 4, fontVariantNumeric: "tabular-nums" }}>{fmtSh(1750)}</div>
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px", display: "flex", gap: 8 }}>
        <Btn kind="secondary">{dir==="rtl"?"عرض المعاملة":"View transaction"}</Btn>
        <Btn>{dir==="rtl"?"تم":"Done"}</Btn>
      </div>
    </Scaffold>
  );
}

// ---------- Send Amount (8) ----------
function ScreenSendAmount({ dir = "ltr", offline = false }) {
  return (
    <Scaffold dir={dir}>
      <SyncHeader status={offline ? "offline" : "online"} dir={dir}/>
      <AppBar title={dir==="rtl"?"إرسال":"Send"} onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", display: "flex", flexDirection: "column" }}>
        <div style={{ marginTop: 4, textAlign: "center" }}>
          <div style={{ fontSize: 12, color: K.fg2, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase" }}>{dir==="rtl"?"المبلغ":"Amount"}</div>
          <div style={{ marginTop: 14, fontSize: 56, fontWeight: 700, letterSpacing: "-0.03em", fontVariantNumeric: "tabular-nums", display: "inline-flex", alignItems: "baseline", gap: 6, color: K.fg }}>
            <span style={{ fontSize: 28, color: K.fg2 }}>₪</span>
            <span>80</span><span style={{ color: K.fg3 }}>.00</span>
          </div>
          <div style={{ fontSize: 12, color: K.fg2, marginTop: 8 }}>{dir==="rtl"?"المتاح":"Available"} <span style={{ fontWeight: 600, color: K.fg }}>{fmtSh(1250)}</span></div>
        </div>
        <div style={{ marginTop: 18, fontSize: 12, fontWeight: 600, color: K.fg2 }}>{dir==="rtl"?"طريقة الدفع":"Payment method"}</div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 10, marginTop: 10 }}>
          <MethodCard active title={dir==="rtl"?"رمز QR":"QR Code"} sub={dir==="rtl"?"يعمل بدون اتصال":"Works offline"} icon={<Ico.qr size={22}/>}/>
          <MethodCard title="Bluetooth" sub={dir==="rtl"?"في النطاق":"Nearby devices"} icon={<Ico.bluetooth size={22}/>}/>
        </div>
        {offline && (
          <div style={{
            marginTop: 14, padding: "12px 14px", borderRadius: 12,
            background: K.gold50, color: K.terra700, display: "flex", gap: 10, alignItems: "flex-start",
          }}>
            <span style={{ marginTop: 2 }}><Ico.shield size={16}/></span>
            <div style={{ fontSize: 12, lineHeight: 1.6 }}>
              <strong>{dir==="rtl"?"حد الدفع بدون اتصال:":"Offline limit:"}</strong> {fmtSh(500)} {dir==="rtl"?"لكل معاملة. الحد المتبقي اليوم":"per tx · Remaining today"} <strong>{fmtSh(420)}</strong>.
            </div>
          </div>
        )}
        <div style={{ flex: 1 }}/>
        <div style={{ marginBottom: 12 }}><Numpad dec onKey={()=>{}}/></div>
        <Btn icon={<Ico.arrowRt size={18}/>}>{dir==="rtl"?"متابعة":"Continue"}</Btn>
        <div style={{ height: 16 }}/>
      </div>
    </Scaffold>
  );
}

function MethodCard({ active, title, sub, icon }) {
  return (
    <div style={{
      padding: 14, borderRadius: 16, background: active ? K.olive50 : K.surface,
      border: `1px solid ${active ? K.olive : K.border}`,
      boxShadow: active ? `0 0 0 3px ${K.olive50}` : "none",
    }}>
      <div style={{
        width: 36, height: 36, borderRadius: 999,
        background: active ? K.olive : K.surface2, color: active ? "#FAF8F5" : K.fg,
        display: "grid", placeItems: "center",
      }}>{icon}</div>
      <div style={{ fontSize: 14, fontWeight: 600, marginTop: 10 }}>{title}</div>
      <div style={{ fontSize: 11, color: K.fg2, marginTop: 2 }}>{sub}</div>
    </div>
  );
}

// ---------- Send QR display (9) — the ceremonial hero screen ----------
function ScreenSendQR({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir} bg="linear-gradient(180deg,#1a3a26 0%,#0f2418 100%)">
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "8px 12px 12px", color: "#FAF8F5" }}>
        <button style={{ ...iconBtn, color: "#FAF8F5" }}><Ico.close size={20}/></button>
        <div style={{ fontSize: 13, fontWeight: 600, opacity: 0.85, display: "flex", alignItems: "center", gap: 6 }}>
          <Ico.sun size={14}/> {dir==="rtl"?"السطوع تلقائي":"Brightness boosted"}
        </div>
        <div style={{ width: 40 }}/>
      </div>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", padding: "20px 24px" }}>
        <div style={{ display: "inline-flex", alignItems: "center", gap: 6, padding: "6px 14px", background: "rgba(212,162,76,0.18)", color: K.gold, borderRadius: 999, fontSize: 12, fontWeight: 700, letterSpacing: "0.04em" }}>
          <Ico.shield size={13} sw={2}/> {dir==="rtl"?"معاملة موقّعة بدون اتصال":"Offline · cryptographically signed"}
        </div>
        <div style={{ fontSize: 38, fontWeight: 700, color: "#FAF8F5", marginTop: 16, letterSpacing: "-0.02em", fontVariantNumeric: "tabular-nums" }}>{fmtSh(80)}</div>
        <div style={{ fontSize: 13, color: "rgba(250,248,245,0.6)", marginTop: 4 }}>{dir==="rtl"?"إلى محمود الخطيب":"to Mahmoud Al-Khatib"}</div>
        <div style={{
          marginTop: 22, padding: 14, background: "#FAF8F5", borderRadius: 24,
          boxShadow: "0 24px 64px rgba(0,0,0,0.5), 0 0 0 6px rgba(212,162,76,0.14)",
        }}>
          <QRMock size={240} dark="#0f2418" light="#FAF8F5" seed={9}/>
          <div style={{ display: "grid", placeItems: "center", marginTop: -130, marginBottom: 90 }}>
            <div style={{ width: 56, height: 56, borderRadius: 16, background: "#FAF8F5", display: "grid", placeItems: "center", boxShadow: "0 4px 12px rgba(0,0,0,0.18)" }}>
              <KashiMark size={36}/>
            </div>
          </div>
        </div>
        <div style={{
          marginTop: 18, fontFamily: "'JetBrains Mono', monospace", fontSize: 10,
          color: "rgba(250,248,245,0.55)", letterSpacing: "0.04em", textAlign: "center", direction: "ltr",
        }}>
          sig: a3f9·2b14·e870·61c2…
        </div>
        <div style={{ marginTop: 14, color: "rgba(250,248,245,0.78)", fontSize: 13, fontWeight: 500, display: "flex", alignItems: "center", gap: 8 }}>
          <span style={{ width: 8, height: 8, borderRadius: 999, background: K.gold, animation: "kpulse 1.4s ease-in-out infinite" }}/>
          {dir==="rtl"?"بانتظار المسح…":"Waiting for scan…"}
        </div>
      </div>
    </Scaffold>
  );
}

// ---------- Send Bluetooth radar (10) ----------
function ScreenSendBT({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir} bg={K.olive700}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "8px 12px 12px", color: "#FAF8F5" }}>
        <button style={{ ...iconBtn, color: "#FAF8F5" }}><Ico.chevLt size={20}/></button>
        <div style={{ fontSize: 16, fontWeight: 600 }}>{dir==="rtl"?"بحث قريب":"Find nearby"}</div>
        <div style={{ width: 40 }}/>
      </div>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", padding: "20px 24px", color: "#FAF8F5" }}>
        <div style={{ fontSize: 32, fontWeight: 700, fontVariantNumeric: "tabular-nums" }}>{fmtSh(80)}</div>
        <div style={{ fontSize: 13, opacity: 0.7, marginTop: 4 }}>{dir==="rtl"?"عبر Bluetooth":"via Bluetooth"}</div>
        <div style={{ position: "relative", width: 260, height: 260, marginTop: 28 }}>
          {[0, 0.5, 1].map((delay, i) => (
            <div key={i} style={{
              position: "absolute", inset: 0, borderRadius: "50%",
              border: "2px solid rgba(212,162,76,0.5)",
              animation: `kradar 2.4s ease-out ${delay}s infinite`,
            }}/>
          ))}
          <div style={{
            position: "absolute", inset: "30%", borderRadius: "50%",
            background: "rgba(212,162,76,0.16)", display: "grid", placeItems: "center",
          }}>
            <div style={{
              width: 72, height: 72, borderRadius: 999, background: K.gold, color: K.olive700,
              display: "grid", placeItems: "center", boxShadow: "0 12px 32px rgba(212,162,76,0.42)",
            }}><Ico.bluetooth size={32} sw={2}/></div>
          </div>
          {/* Found device blip */}
          <div style={{
            position: "absolute", top: 30, right: 36, width: 12, height: 12, borderRadius: 999,
            background: "#7BD389", boxShadow: "0 0 16px #7BD389",
          }}/>
        </div>
        <div style={{ marginTop: 24, fontSize: 14, fontWeight: 600 }}>{dir==="rtl"?"جاري البحث عن الأجهزة القريبة…":"Looking for nearby devices…"}</div>
        <div style={{ marginTop: 24, width: "100%" }}>
          <div style={{ background: "rgba(255,255,255,0.08)", borderRadius: 16, padding: "14px 16px", display: "flex", alignItems: "center", gap: 12 }}>
            <Avatar name="Mahmoud Al" size={40} bg="rgba(212,162,76,0.24)" color={K.gold}/>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 600 }}>Mahmoud's Pixel 7</div>
              <div style={{ fontSize: 11, opacity: 0.65 }}>{dir==="rtl"?"على بُعد ٣ أمتار":"~3 m away"}</div>
            </div>
            <Btn kind="accent" fullWidth={false} style={{ minHeight: 40, padding: "0 16px", fontSize: 14, borderRadius: 999 }}>{dir==="rtl"?"إرسال":"Send"}</Btn>
          </div>
        </div>
      </div>
    </Scaffold>
  );
}

// ---------- Send Pending Sync (11) ----------
function ScreenSendPending({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <SyncHeader status="offline" dir={dir}/>
      <AppBar dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
        <div style={{
          width: 96, height: 96, borderRadius: 999, background: K.olive, color: "#FAF8F5",
          display: "grid", placeItems: "center", marginTop: 36,
          animation: "kcheckPop 600ms cubic-bezier(.34,1.56,.64,1)",
        }}><Ico.check size={48} sw={2.5}/></div>
        <div style={{ fontSize: 24, fontWeight: 700, marginTop: 24 }}>{dir==="rtl"?"تم الإرسال":"Payment sent"}</div>
        <div style={{ fontSize: 38, fontWeight: 700, color: K.fg, marginTop: 6, fontVariantNumeric: "tabular-nums" }}>− {fmtSh(80)}</div>
        <div style={{ fontSize: 13, color: K.fg2, marginTop: 6 }}>{dir==="rtl"?"إلى محمود الخطيب":"to Mahmoud Al-Khatib"}</div>
        <div style={{ marginTop: 24, padding: 16, background: K.gold50, borderRadius: 16, width: "100%", textAlign: "left" }}>
          <div style={{ display: "flex", gap: 10, alignItems: "flex-start" }}>
            <span style={{ color: K.terra700, marginTop: 2 }}><Ico.cloudOff size={20}/></span>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14, fontWeight: 700, color: K.terra700 }}>{dir==="rtl"?"ستتم المزامنة عند الاتصال":"Will sync when online"}</div>
              <div style={{ fontSize: 12, color: K.terra700, marginTop: 4, lineHeight: 1.6 }}>
                {dir==="rtl"?"المعاملة موقّعة وآمنة. يحتاج كلا الطرفين للاتصال بالشبكة لتسوية الرصيد.":"This payment is signed and safe. Both wallets need network access for final settlement."}
              </div>
            </div>
          </div>
        </div>
        <div style={{ marginTop: 14, padding: "12px 14px", background: K.surface, borderRadius: 12, border: `1px dashed ${K.border}`, fontFamily: "'JetBrains Mono', monospace", fontSize: 11, color: K.fg2, width: "100%", direction: "ltr" }}>
          ref · 7K9F-2X3M-A1B8
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px", display: "flex", gap: 8 }}>
        <Btn kind="secondary">{dir==="rtl"?"التفاصيل":"Details"}</Btn>
        <Btn>{dir==="rtl"?"تم":"Done"}</Btn>
      </div>
    </Scaffold>
  );
}

// ---------- Send Online Confirmed (12) ----------
function ScreenSendConfirmed({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
        <div style={{
          width: 96, height: 96, borderRadius: 999, background: K.olive, color: "#FAF8F5",
          display: "grid", placeItems: "center", marginTop: 32,
          animation: "kcheckPop 600ms cubic-bezier(.34,1.56,.64,1)",
        }}><Ico.check size={48} sw={2.5}/></div>
        <div style={{ fontSize: 24, fontWeight: 700, marginTop: 22 }}>{dir==="rtl"?"تمت التسوية":"Settled & confirmed"}</div>
        <Pill kind="success" large icon={<Ico.check size={12} sw={2.5}/>}>
          {dir==="rtl"?"تمت المزامنة":"Synced to network"}
        </Pill>
        <div style={{ fontSize: 38, fontWeight: 700, marginTop: 16, fontVariantNumeric: "tabular-nums" }}>− {fmtSh(80)}</div>
        <div style={{ fontSize: 13, color: K.fg2, marginTop: 6 }}>{dir==="rtl"?"إلى محمود الخطيب · 2:14 م":"to Mahmoud Al-Khatib · 2:14 PM"}</div>
        <div style={{ marginTop: 28, width: "100%", padding: 16, background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16 }}>
          <DetailRow label={dir==="rtl"?"الرسوم":"Fee"} value={fmtSh(0)}/>
          <DetailRow label={dir==="rtl"?"الرصيد الجديد":"New balance"} value={fmtSh(1170)} bold/>
          <DetailRow label={dir==="rtl"?"التوقيع":"Signature"} value="a3f9·2b14·e870" mono verified/>
          <DetailRow label={dir==="rtl"?"المرجع":"Reference"} value="7K9F-2X3M-A1B8" mono last/>
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px" }}>
        <Btn>{dir==="rtl"?"العودة للرئيسية":"Back to home"}</Btn>
      </div>
    </Scaffold>
  );
}

function DetailRow({ label, value, bold, mono, verified, last }) {
  return (
    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "10px 0", borderBottom: last ? "none" : `1px solid ${K.border}` }}>
      <div style={{ fontSize: 12, color: K.fg2 }}>{label}</div>
      <div style={{ display: "flex", alignItems: "center", gap: 6, fontSize: 13, fontWeight: bold ? 700 : 600, color: K.fg, fontFamily: mono ? "'JetBrains Mono', monospace" : "inherit", direction: "ltr" }}>
        {value}{verified && <Ico.shield size={13} sw={2} color={K.olive}/>}
      </div>
    </div>
  );
}

window.ScreenReceive = ScreenReceive;
window.ScreenReceiveSuccess = ScreenReceiveSuccess;
window.ScreenSendAmount = ScreenSendAmount;
window.ScreenSendQR = ScreenSendQR;
window.ScreenSendBT = ScreenSendBT;
window.ScreenSendPending = ScreenSendPending;
window.ScreenSendConfirmed = ScreenSendConfirmed;
