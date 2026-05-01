// Kashi · Offline P2P Receive (13–16) and iBuraq Transfer (17–20).

// 13 — Receive Scan (camera viewfinder)
function ScreenScan({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir} bg="#0a0a0a">
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "8px 12px 12px", color: "#FAF8F5" }}>
        <button style={{ ...iconBtn, color: "#FAF8F5" }}><Ico.close size={20}/></button>
        <div style={{ fontSize: 16, fontWeight: 600 }}>{dir==="rtl"?"مسح للدفع":"Scan to pay"}</div>
        <button style={{ ...iconBtn, color: "#FAF8F5" }}><Ico.flash size={20}/></button>
      </div>
      <div style={{ flex: 1, position: "relative", display: "flex", alignItems: "center", justifyContent: "center" }}>
        {/* fake camera feed */}
        <div style={{
          position: "absolute", inset: 0,
          background: "radial-gradient(circle at 30% 40%, #2a2a2a 0%, #0a0a0a 70%)",
          backgroundImage: "linear-gradient(120deg, rgba(45,95,63,0.12) 0%, transparent 60%)",
        }}/>
        {/* viewfinder */}
        <div style={{ position: "relative", width: 260, height: 260 }}>
          {/* corners */}
          {[
            { top: 0, left: 0, br: "0 0 0 16px", b: "left top" },
            { top: 0, right: 0, br: "0 0 16px 0", b: "right top" },
            { bottom: 0, left: 0, br: "0 16px 0 0", b: "left bottom" },
            { bottom: 0, right: 0, br: "16px 0 0 0", b: "right bottom" },
          ].map((c, i) => (
            <div key={i} style={{
              position: "absolute", ...c, width: 36, height: 36,
              borderColor: K.gold, borderStyle: "solid",
              borderWidth: c.b.includes("top") ? "3px 3px 0 0" : "0 0 3px 3px",
              borderTopWidth: c.b === "left top" || c.b === "right top" ? 3 : 0,
              borderLeftWidth: c.b === "left top" || c.b === "left bottom" ? 3 : 0,
              borderRightWidth: c.b === "right top" || c.b === "right bottom" ? 3 : 0,
              borderBottomWidth: c.b === "left bottom" || c.b === "right bottom" ? 3 : 0,
              borderRadius: c.br,
            }}/>
          ))}
          {/* scanning line */}
          <div style={{ position: "absolute", left: 8, right: 8, top: "50%", height: 2, background: K.gold, boxShadow: `0 0 12px ${K.gold}`, animation: "kpulse 1.6s ease-in-out infinite" }}/>
        </div>
        <div style={{
          position: "absolute", top: 28, left: 24, right: 24,
          textAlign: "center", color: "rgba(250,248,245,0.85)", fontSize: 13,
        }}>
          {dir==="rtl"?"وجّه الكاميرا نحو رمز QR الخاص بكاشي":"Point your camera at a Kashi QR code"}
        </div>
      </div>
      <div style={{ padding: "20px 16px 24px", display: "flex", justifyContent: "center", gap: 10 }}>
        <button style={{ background: "rgba(255,255,255,0.12)", color: "#FAF8F5", border: 0, padding: "12px 20px", borderRadius: 999, fontSize: 13, fontWeight: 600, fontFamily: "inherit", display: "flex", alignItems: "center", gap: 8 }}>
          <Ico.copy size={16}/> {dir==="rtl"?"لصق رابط":"Paste from clipboard"}
        </button>
      </div>
    </Scaffold>
  );
}

// 14 — Receive Verify (the trust moment)
function ScreenVerify({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <SyncHeader status="offline" dir={dir}/>
      <AppBar title={dir==="rtl"?"تأكيد الدفعة":"Confirm payment"} onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", overflow: "auto" }}>
        <div style={{ background: "linear-gradient(135deg,#FBEFE6 0%,#FBF3E1 100%)", borderRadius: 24, padding: 24, textAlign: "center", border: `1px solid ${K.gold50}` }}>
          <Pill kind="info" icon={<Ico.shield size={12} sw={2.5}/>} large>{dir==="rtl"?"التوقيع موثوق":"Signature verified"}</Pill>
          <div style={{ marginTop: 14, fontSize: 12, color: K.fg2, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase" }}>{dir==="rtl"?"المرسل":"From"}</div>
          <div style={{ display: "inline-flex", alignItems: "center", gap: 10, marginTop: 8 }}>
            <Avatar name="Layla Hammad"/>
            <div style={{ textAlign: "left", direction: dir }}>
              <div style={{ fontSize: 16, fontWeight: 700 }}>{dir==="rtl"?"ليلى حمّاد":"Layla Hammad"}</div>
              <div style={{ fontSize: 11, color: K.fg2, fontFamily: "'JetBrains Mono', monospace", direction: "ltr" }}>+970 59 ••• 8821</div>
            </div>
          </div>
          <div style={{ marginTop: 18, fontSize: 12, color: K.fg2, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase" }}>{dir==="rtl"?"المبلغ":"Amount"}</div>
          <div style={{ fontSize: 44, fontWeight: 700, color: K.olive, fontVariantNumeric: "tabular-nums", marginTop: 6, letterSpacing: "-0.02em" }}>+ {fmtSh(120)}</div>
        </div>
        <div style={{ marginTop: 16, padding: 16, background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16 }}>
          <VerifyCheck label={dir==="rtl"?"توقيع كاشي صحيح":"Valid Kashi signature"}/>
          <VerifyCheck label={dir==="rtl"?"الرصيد متوفر لدى المرسل":"Sender's balance is sufficient"}/>
          <VerifyCheck label={dir==="rtl"?"لم تُستخدم هذه الدفعة من قبل":"Payment not seen before"}/>
          <div style={{ marginTop: 8, paddingTop: 8, borderTop: `1px solid ${K.border}`, fontFamily: "'JetBrains Mono', monospace", fontSize: 10, color: K.fg3, direction: "ltr" }}>
            sig · 7e2d·a318·9f04·6b21
          </div>
        </div>
        <div style={{ marginTop: 12, padding: 12, background: K.gold50, borderRadius: 12, display: "flex", gap: 10 }}>
          <span style={{ color: K.terra700 }}><Ico.cloudOff size={16}/></span>
          <div style={{ fontSize: 12, color: K.terra700, lineHeight: 1.6 }}>
            {dir==="rtl"?"ستتم تسوية المعاملة عند اتصال أي من الجهازين بالشبكة.":"Final settlement happens when either device reconnects."}
          </div>
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px", display: "flex", gap: 8 }}>
        <Btn kind="secondary">{dir==="rtl"?"رفض":"Reject"}</Btn>
        <Btn>{dir==="rtl"?"قبول":"Accept"}</Btn>
      </div>
    </Scaffold>
  );
}

function VerifyCheck({ label }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: 10, padding: "6px 0" }}>
      <div style={{ width: 22, height: 22, borderRadius: 999, background: K.olive50, color: K.olive, display: "grid", placeItems: "center" }}>
        <Ico.check size={13} sw={2.5}/>
      </div>
      <div style={{ fontSize: 13, fontWeight: 500 }}>{label}</div>
    </div>
  );
}

// 15 — Receive Pending
function ScreenReceivePending({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <SyncHeader status="pending" dir={dir}/>
      <AppBar dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
        <div style={{
          width: 96, height: 96, borderRadius: 999, background: K.olive, color: "#FAF8F5",
          display: "grid", placeItems: "center", marginTop: 32,
          animation: "kcheckPop 600ms cubic-bezier(.34,1.56,.64,1)",
        }}><Ico.check size={48} sw={2.5}/></div>
        <div style={{ fontSize: 24, fontWeight: 700, marginTop: 22 }}>{dir==="rtl"?"تم القبول":"Payment accepted"}</div>
        <div style={{ fontSize: 38, fontWeight: 700, color: K.olive, marginTop: 6, fontVariantNumeric: "tabular-nums" }}>+ {fmtSh(120)}</div>
        <div style={{ fontSize: 13, color: K.fg2, marginTop: 4 }}>{dir==="rtl"?"من ليلى حمّاد":"from Layla Hammad"}</div>
        <Pill kind="pending" large icon={<Ico.cloudOff size={12} sw={2}/>}>
          {dir==="rtl"?"بانتظار المزامنة":"Waiting to sync"}
        </Pill>
        <div style={{ marginTop: 22, width: "100%", padding: 16, background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16 }}>
          <div style={{ fontSize: 12, color: K.fg2, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase" }}>{dir==="rtl"?"الرصيد المتاح":"Available balance"}</div>
          <div style={{ fontSize: 24, fontWeight: 700, marginTop: 4, fontVariantNumeric: "tabular-nums" }}>{fmtSh(1370)}</div>
          <div style={{ fontSize: 11, color: K.fg3, marginTop: 6 }}>
            {dir==="rtl"?"يصبح متاحاً للسحب البنكي بعد المزامنة":"Bank withdrawal available after sync"}
          </div>
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px" }}>
        <Btn>{dir==="rtl"?"العودة للرئيسية":"Back to home"}</Btn>
      </div>
    </Scaffold>
  );
}

// 16 — Receive History Detail (synced)
function ScreenHistoryDetail({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar title={dir==="rtl"?"تفاصيل المعاملة":"Transaction"} onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", overflow: "auto" }}>
        <div style={{ textAlign: "center", padding: "20px 0" }}>
          <div style={{ display: "inline-grid", placeItems: "center", width: 64, height: 64, borderRadius: 999, background: K.successBg, color: K.successFg }}>
            <Ico.qr size={28}/>
          </div>
          <div style={{ fontSize: 36, fontWeight: 700, marginTop: 16, color: K.successFg, fontVariantNumeric: "tabular-nums", letterSpacing: "-0.02em" }}>+ {fmtSh(120)}</div>
          <div style={{ fontSize: 14, color: K.fg, marginTop: 4, fontWeight: 600 }}>{dir==="rtl"?"دفعة بدون اتصال":"Offline P2P"}</div>
          <div style={{ marginTop: 8, display: "inline-flex", gap: 6 }}>
            <Pill kind="success" icon={<Ico.check size={11} sw={2.5}/>}>{dir==="rtl"?"تمت المزامنة":"Synced"}</Pill>
            <Pill kind="info" icon={<Ico.shield size={11} sw={2.5}/>}>{dir==="rtl"?"موقّعة":"Signed"}</Pill>
          </div>
        </div>
        <div style={{ background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16, padding: "4px 16px" }}>
          <DetailRow label={dir==="rtl"?"المرسل":"Sender"} value="Layla Hammad"/>
          <DetailRow label={dir==="rtl"?"الطريقة":"Method"} value={dir==="rtl"?"رمز QR · بدون اتصال":"QR · offline"}/>
          <DetailRow label={dir==="rtl"?"التاريخ":"Date"} value={dir==="rtl"?"٤ يناير ٢٠٢٦ · ٢:١٤ م":"4 Jan 2026 · 2:14 PM"}/>
          <DetailRow label={dir==="rtl"?"المزامنة":"Settled"} value={dir==="rtl"?"٤ يناير · ٣:٤٢ م":"4 Jan · 3:42 PM"}/>
          <DetailRow label={dir==="rtl"?"التوقيع":"Signature"} value="7e2d·a318·9f04" mono verified/>
          <DetailRow label={dir==="rtl"?"المرجع":"Reference"} value="P2P-7K9F-2X3M" mono last/>
        </div>
        <button style={{ width: "100%", marginTop: 16, padding: 14, background: "transparent", border: `1px solid ${K.border}`, borderRadius: 12, fontFamily: "inherit", fontSize: 13, fontWeight: 600, color: K.fg2, cursor: "pointer", display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
          <Ico.send size={14}/> {dir==="rtl"?"إعادة إرسال إلى ليلى":"Send back to Layla"}
        </button>
      </div>
    </Scaffold>
  );
}

// 17 — iBuraq lookup
function ScreenLookup({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar title={dir==="rtl"?"تحويل بنكي":"Bank transfer"} onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px" }}>
        <div style={{ fontSize: 22, fontWeight: 700, letterSpacing: "-0.01em" }}>{dir==="rtl"?"إلى من ترسل؟":"Who are you paying?"}</div>
        <div style={{ fontSize: 13, color: K.fg2, marginTop: 6 }}>{dir==="rtl"?"أدخل رقم الهاتف للبحث في شبكة iBuraq.":"Enter a phone number to search the iBuraq network."}</div>
        <div style={{ marginTop: 20 }}>
          <Field label={dir==="rtl"?"رقم الهاتف":"Phone number"} dir={dir}>
            <div style={{ display: "flex", gap: 8 }}>
              <button style={{ minHeight: 52, padding: "0 12px", borderRadius: 12, background: K.surface, border: `1px solid ${K.border}`, fontFamily: "inherit", fontSize: 14, fontWeight: 600, color: K.fg, display: "flex", alignItems: "center", gap: 4 }}>
                🇵🇸 +970 <Ico.chevDn size={12}/>
              </button>
              <Input value="59 887 1234"/>
            </div>
          </Field>
        </div>
        <div style={{ fontSize: 12, fontWeight: 600, color: K.fg2, marginTop: 18 }}>{dir==="rtl"?"مرسل إليه مؤخراً":"Recent recipients"}</div>
        <div style={{ marginTop: 10 }}>
          {[
            { name: "Family · Bank of Palestine", sub: "•••• 1234", c: K.olive50, fg: K.olive },
            { name: "Sami Khoury", sub: "JawwalPay", c: K.gold50, fg: K.terra700 },
            { name: "Yara Aboud", sub: "Reflect Wallet", c: K.terra50, fg: K.terra700 },
          ].map((r, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 12, padding: "10px 0", borderBottom: i<2 ? `1px solid ${K.border}` : "none" }}>
              <Avatar name={r.name} size={36} bg={r.c} color={r.fg}/>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600 }}>{r.name}</div>
                <div style={{ fontSize: 11, color: K.fg2 }}>{r.sub}</div>
              </div>
              <Ico.chevRt size={16} color={K.fg3}/>
            </div>
          ))}
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px" }}>
        <Btn icon={<Ico.search size={18}/>}>{dir==="rtl"?"بحث في iBuraq":"Search iBuraq"}</Btn>
      </div>
    </Scaffold>
  );
}

// 18 — iBuraq destinations
function ScreenDestinations({ dir = "ltr" }) {
  const found = [
    { name: "Bank of Palestine", sub: "•••• 1234", icon: <Ico.bank size={20}/>, c: K.olive50, fg: K.olive, badge: dir==="rtl"?"الافتراضي":"Default" },
    { name: "JawwalPay", sub: dir==="rtl"?"محفظة رقمية":"Wallet", icon: <span style={{ fontSize: 18 }}>📱</span>, c: K.gold50, fg: K.terra700 },
    { name: "Reflect Wallet", sub: "ID R7-2913", icon: <Ico.wallet size={20}/>, c: K.terra50, fg: K.terra700 },
    { name: "Cairo Amman Bank", sub: "•••• 8821", icon: <Ico.bank size={20}/>, c: K.olive50, fg: K.olive },
  ];
  return (
    <Scaffold dir={dir}>
      <AppBar title={dir==="rtl"?"اختر الوجهة":"Pick destination"} onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", overflow: "auto" }}>
        <div style={{ padding: 14, background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16, display: "flex", alignItems: "center", gap: 12 }}>
          <Avatar name="Sami Khoury"/>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 15, fontWeight: 700 }}>Sami Khoury</div>
            <div style={{ fontSize: 11, color: K.fg2, fontFamily: "'JetBrains Mono', monospace", direction: "ltr" }}>+970 59 887 1234</div>
          </div>
          <Pill kind="success" icon={<Ico.check size={11} sw={2.5}/>}>{dir==="rtl"?"موجود":"Found"}</Pill>
        </div>
        <div style={{ fontSize: 12, fontWeight: 600, color: K.fg2, marginTop: 18, letterSpacing: "0.04em" }}>
          {dir==="rtl"?`٤ حسابات موجودة عبر iBuraq`:`4 accounts available via iBuraq`}
        </div>
        <div style={{ marginTop: 10, background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16, overflow: "hidden" }}>
          {found.map((f, i) => (
            <div key={i} style={{ display: "flex", alignItems: "center", gap: 12, padding: "14px 16px", borderBottom: i<found.length-1 ? `1px solid ${K.border}` : "none", cursor: "pointer", background: i===0 ? K.olive50 : "transparent" }}>
              <div style={{ width: 40, height: 40, borderRadius: 12, background: f.c, color: f.fg, display: "grid", placeItems: "center" }}>{f.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 14, fontWeight: 600, display: "flex", alignItems: "center", gap: 6 }}>
                  {f.name}{f.badge && <Pill kind="info">{f.badge}</Pill>}
                </div>
                <div style={{ fontSize: 11, color: K.fg2, marginTop: 2 }}>{f.sub}</div>
              </div>
              {i === 0 ? (
                <div style={{ width: 22, height: 22, borderRadius: 999, background: K.olive, color: "#FAF8F5", display: "grid", placeItems: "center" }}><Ico.check size={13} sw={2.5}/></div>
              ) : <Ico.chevRt size={16} color={K.fg3}/>}
            </div>
          ))}
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px" }}>
        <Btn>{dir==="rtl"?"التالي":"Continue"}</Btn>
      </div>
    </Scaffold>
  );
}

// 19 — iBuraq confirm
function ScreenTransferConfirm({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar title={dir==="rtl"?"تأكيد التحويل":"Confirm transfer"} onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", overflow: "auto" }}>
        <div style={{ padding: 16, background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16, display: "flex", alignItems: "center", gap: 12 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: K.olive50, color: K.olive, display: "grid", placeItems: "center" }}>
            <Ico.bank size={22}/>
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 11, color: K.fg2, fontWeight: 600 }}>{dir==="rtl"?"إلى":"To"}</div>
            <div style={{ fontSize: 14, fontWeight: 700, marginTop: 2 }}>Sami Khoury</div>
            <div style={{ fontSize: 11, color: K.fg2, fontFamily: "'JetBrains Mono', monospace", direction: "ltr" }}>Bank of Palestine •••• 1234</div>
          </div>
          <button style={{ background: "transparent", border: 0, color: K.olive, fontSize: 12, fontWeight: 600 }}>{dir==="rtl"?"تغيير":"Change"}</button>
        </div>
        <div style={{ marginTop: 16, padding: "20px 16px", background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16, textAlign: "center" }}>
          <div style={{ fontSize: 11, fontWeight: 600, color: K.fg2, letterSpacing: "0.06em", textTransform: "uppercase" }}>{dir==="rtl"?"المبلغ":"Amount"}</div>
          <div style={{ fontSize: 44, fontWeight: 700, letterSpacing: "-0.02em", marginTop: 6, fontVariantNumeric: "tabular-nums" }}>{fmtSh(250)}</div>
        </div>
        <div style={{ marginTop: 12, padding: "4px 16px", background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16 }}>
          <DetailRow label={dir==="rtl"?"رسوم iBuraq":"iBuraq fee"} value={fmtSh(0.5)}/>
          <DetailRow label={dir==="rtl"?"وقت الوصول المتوقع":"Estimated arrival"} value={dir==="rtl"?"خلال دقيقتين":"~2 minutes"}/>
          <DetailRow label={dir==="rtl"?"المتاح بعد التحويل":"Available after"} value={fmtSh(999.5)}/>
          <DetailRow label={dir==="rtl"?"الإجمالي":"Total"} value={fmtSh(250.5)} bold last/>
        </div>
        <Field label={dir==="rtl"?"ملاحظة (اختياري)":"Note (optional)"} dir={dir}>
          <Input value="" placeholder={dir==="rtl"?"إيجار يناير":"January rent"}/>
        </Field>
      </div>
      <div style={{ padding: "12px 20px 20px" }}>
        <Btn>{dir==="rtl"?"تأكيد التحويل":"Confirm transfer"}</Btn>
        <div style={{ fontSize: 11, color: K.fg3, textAlign: "center", marginTop: 10, display: "flex", alignItems: "center", justifyContent: "center", gap: 6 }}>
          <Ico.shield size={12}/> {dir==="rtl"?"محمي بالتشفير من طرف إلى طرف":"End-to-end encrypted via iBuraq"}
        </div>
      </div>
    </Scaffold>
  );
}

// 20 — Transfer Success
function ScreenTransferSuccess({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", display: "flex", flexDirection: "column", alignItems: "center", textAlign: "center" }}>
        <div style={{ width: 96, height: 96, borderRadius: 999, background: K.olive, color: "#FAF8F5", display: "grid", placeItems: "center", marginTop: 32, animation: "kcheckPop 600ms cubic-bezier(.34,1.56,.64,1)" }}>
          <Ico.check size={48} sw={2.5}/>
        </div>
        <div style={{ fontSize: 24, fontWeight: 700, marginTop: 22 }}>{dir==="rtl"?"تم التحويل":"Transfer sent"}</div>
        <div style={{ fontSize: 38, fontWeight: 700, marginTop: 6, fontVariantNumeric: "tabular-nums" }}>− {fmtSh(250)}</div>
        <div style={{ fontSize: 13, color: K.fg2, marginTop: 4 }}>{dir==="rtl"?"إلى Sami Khoury · بنك فلسطين":"to Sami Khoury · Bank of Palestine"}</div>
        <Pill kind="success" large icon={<Ico.check size={12} sw={2.5}/>}>{dir==="rtl"?"عبر iBuraq":"via iBuraq"}</Pill>
        <div style={{ marginTop: 22, width: "100%", padding: "4px 16px", background: K.surface, border: `1px solid ${K.border}`, borderRadius: 16 }}>
          <DetailRow label={dir==="rtl"?"رقم المرجع":"Reference"} value="iB-2026-0104-7K9F" mono/>
          <DetailRow label={dir==="rtl"?"وقت الوصول":"Arriving"} value={dir==="rtl"?"خلال دقيقتين":"in ~2 minutes"} last/>
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px", display: "flex", gap: 8 }}>
        <Btn kind="secondary" icon={<Ico.send size={16}/>}>{dir==="rtl"?"مشاركة الإيصال":"Share receipt"}</Btn>
        <Btn>{dir==="rtl"?"تم":"Done"}</Btn>
      </div>
    </Scaffold>
  );
}

window.ScreenScan = ScreenScan;
window.ScreenVerify = ScreenVerify;
window.ScreenReceivePending = ScreenReceivePending;
window.ScreenHistoryDetail = ScreenHistoryDetail;
window.ScreenLookup = ScreenLookup;
window.ScreenDestinations = ScreenDestinations;
window.ScreenTransferConfirm = ScreenTransferConfirm;
window.ScreenTransferSuccess = ScreenTransferSuccess;
