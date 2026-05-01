// Kashi · Onboarding & Auth screens (1–4) and Home (5).

function ScreenSplash({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir} bg={K.olive}>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", color: "#FAF8F5", padding: 24 }}>
        <KashiMark size={84} color="#FAF8F5" bg="rgba(255,255,255,0.08)"/>
        <div style={{ fontSize: 32, fontWeight: 700, marginTop: 20, letterSpacing: "-0.02em" }}>Kashi</div>
        <div style={{ fontFamily: "'IBM Plex Sans Arabic', sans-serif", fontSize: 22, fontWeight: 600, marginTop: 4, opacity: 0.9 }}>كاشي</div>
        <div style={{ fontSize: 14, opacity: 0.78, marginTop: 24, textAlign: "center", maxWidth: 280, lineHeight: 1.6 }}>
          {dir === "rtl" ? "محفظة فلسطينية تعمل دائماً — حتى بدون اتصال." : "A Palestinian wallet that always works — even offline."}
        </div>
      </div>
      <div style={{ padding: "0 0 28px", display: "flex", justifyContent: "center", gap: 6 }}>
        <div style={{ width: 24, height: 4, borderRadius: 2, background: K.gold }}/>
        <div style={{ width: 6, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.3)" }}/>
        <div style={{ width: 6, height: 4, borderRadius: 2, background: "rgba(255,255,255,0.3)" }}/>
      </div>
    </Scaffold>
  );
}

function ScreenPhone({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", display: "flex", flexDirection: "column" }}>
        <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: "-0.01em", fontFamily: dir==="rtl"?"'IBM Plex Sans Arabic',sans-serif":"inherit" }}>
          {dir === "rtl" ? "أهلاً بك في كاشي" : "Welcome to Kashi"}
        </div>
        <div style={{ fontSize: 14, color: K.fg2, marginTop: 6, fontFamily: dir==="rtl"?"'IBM Plex Sans Arabic',sans-serif":"inherit" }}>
          {dir === "rtl" ? "أدخل رقم هاتفك للبدء." : "Enter your phone number to get started."}
        </div>
        <div style={{ marginTop: 28 }}>
          <Field label={dir==="rtl"?"رقم الهاتف":"Phone number"} dir={dir}>
            <div style={{ display: "flex", gap: 8 }}>
              <button style={{
                minHeight: 52, padding: "0 14px", borderRadius: 12,
                background: K.surface, border: `1px solid ${K.border}`,
                fontFamily: "inherit", fontSize: 16, fontWeight: 600, color: K.fg,
                display: "flex", alignItems: "center", gap: 6, cursor: "pointer",
              }}>🇵🇸 +970 <Ico.chevDn size={14}/></button>
              <Input value="59 123 4567" placeholder="59 123 4567"/>
            </div>
          </Field>
          <div style={{ fontSize: 12, color: K.fg2, marginTop: 8, lineHeight: 1.6 }}>
            {dir === "rtl"
              ? "سنرسل لك رمز تحقق برسالة نصية."
              : "We'll send a verification code by SMS."}
          </div>
        </div>
        <div style={{ flex: 1 }}/>
        <Btn>{dir==="rtl"?"متابعة":"Continue"}</Btn>
        <div style={{ fontSize: 11, color: K.fg3, textAlign: "center", marginTop: 14, marginBottom: 16, lineHeight: 1.6 }}>
          {dir==="rtl"?"بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية.":"By continuing, you agree to the Terms of Use and Privacy Policy."}
        </div>
      </div>
    </Scaffold>
  );
}

function ScreenOTP({ dir = "ltr" }) {
  const code = ["1","2","3","4","",""];
  return (
    <Scaffold dir={dir}>
      <AppBar onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px" }}>
        <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: "-0.01em" }}>
          {dir==="rtl"?"رمز التحقق":"Verify your number"}
        </div>
        <div style={{ fontSize: 14, color: K.fg2, marginTop: 6 }}>
          {dir==="rtl"?"أرسلنا رمزاً إلى ":"We sent a 6-digit code to "}
          <span style={{ color: K.fg, fontWeight: 600, fontFamily: "'JetBrains Mono', monospace", direction: "ltr" }}>+970 59 123 4567</span>
        </div>
        <div style={{ display: "flex", gap: 8, marginTop: 28, direction: "ltr" }}>
          {code.map((d, i) => (
            <div key={i} style={{
              flex: 1, height: 64, borderRadius: 12, background: K.surface,
              border: `1px solid ${d ? K.olive : K.border}`,
              display: "grid", placeItems: "center",
              fontSize: 24, fontWeight: 700, fontFamily: "'JetBrains Mono', monospace",
              color: d ? K.fg : K.fg3,
              boxShadow: i === 4 ? `0 0 0 3px ${K.olive50}` : "none",
            }}>{d || (i === 4 ? "│" : "")}</div>
          ))}
        </div>
        <div style={{ marginTop: 18, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div style={{ fontSize: 12, color: K.fg2 }}>{dir==="rtl"?"إعادة الإرسال خلال":"Resend in"} <span style={{ color: K.fg, fontWeight: 600 }}>0:42</span></div>
          <button style={{ background: "transparent", border: 0, color: K.fg3, fontWeight: 600, fontSize: 13, cursor: "not-allowed" }}>{dir==="rtl"?"إعادة الإرسال":"Resend"}</button>
        </div>
        <div style={{ marginTop: 24 }}>
          <Numpad onKey={()=>{}}/>
        </div>
      </div>
    </Scaffold>
  );
}

function ScreenProfile({ dir = "ltr" }) {
  return (
    <Scaffold dir={dir}>
      <AppBar onBack={()=>{}} dir={dir}/>
      <div style={{ flex: 1, padding: "0 20px", overflow: "auto" }}>
        <div style={{ fontSize: 26, fontWeight: 700, letterSpacing: "-0.01em" }}>{dir==="rtl"?"معلوماتك":"Your profile"}</div>
        <div style={{ fontSize: 14, color: K.fg2, marginTop: 6 }}>{dir==="rtl"?"سنستخدمها لإصدار رقم آيبان فلسطيني.":"We'll use this to issue your Palestinian IBAN."}</div>
        <div style={{ marginTop: 24 }}>
          <Field label={dir==="rtl"?"الاسم الكامل":"Full name"}><Input value="Mohammed Al-Najjar"/></Field>
          <Field label={dir==="rtl"?"رقم الهوية":"National ID"} hint={dir==="rtl"?"9 أرقام":"9 digits"}><Input value="412938470"/></Field>
          <Field label={dir==="rtl"?"تاريخ الميلاد":"Date of birth"}><Input value="14 / 03 / 1992"/></Field>
        </div>
        <div style={{ marginTop: 12, padding: 14, background: K.olive50, borderRadius: 12, display: "flex", gap: 10 }}>
          <span style={{ color: K.olive }}><Ico.shield size={18}/></span>
          <div style={{ fontSize: 12, color: K.olive700, lineHeight: 1.6 }}>
            {dir==="rtl"?"تُحفظ بياناتك مشفّرة على جهازك ولا تُشارك مع أي طرف ثالث.":"Your details are encrypted on your device and never shared with third parties."}
          </div>
        </div>
      </div>
      <div style={{ padding: "12px 20px 20px" }}>
        <Btn>{dir==="rtl"?"إنشاء المحفظة":"Create my wallet"}</Btn>
      </div>
    </Scaffold>
  );
}

function ScreenHome({ dir = "ltr", sync = "online" }) {
  return (
    <Scaffold dir={dir}>
      <SyncHeader status={sync} dir={dir}/>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "12px 16px 16px" }}>
        <div>
          <div style={{ fontSize: 12, color: K.fg2, fontWeight: 500, fontFamily: dir==="rtl"?"'IBM Plex Sans Arabic',sans-serif":"inherit" }}>{dir==="rtl"?"أهلاً":"Welcome"}</div>
          <div style={{ fontSize: 18, fontWeight: 700, marginTop: 2, fontFamily: dir==="rtl"?"'IBM Plex Sans Arabic',sans-serif":"inherit" }}>{dir==="rtl"?"محمد":"Mohammed"}</div>
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <button style={{ ...iconBtn, background: K.surface, border: `1px solid ${K.border}` }}><Ico.bell size={18}/></button>
          <Avatar name="Mohammed Al" size={40}/>
        </div>
      </div>
      <div style={{ flex: 1, overflow: "auto", padding: "0 16px 16px" }}>
        <BalanceCard amount={1250} online={sync==="online"} dir={dir}/>
        <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
          <ActionTile icon={Ico.send} label={dir==="rtl"?"إرسال":"Send"}/>
          <ActionTile icon={Ico.arrowDn} label={dir==="rtl"?"استلام":"Receive"}/>
          <ActionTile icon={Ico.qr} label={dir==="rtl"?"دفع بدون اتصال":"Pay offline"} accent="gold"/>
          <ActionTile icon={Ico.bank} label={dir==="rtl"?"تحويل بنكي":"To bank"}/>
        </div>
        <SectionTitle dir={dir} action={<button style={{ background: "none", border: 0, color: K.olive, fontSize: 13, fontWeight: 600 }}>{dir==="rtl"?"عرض الكل":"See all"}</button>}>
          {dir==="rtl"?"النشاط الأخير":"Recent activity"}
        </SectionTitle>
        <div style={{ background: K.surface, borderRadius: 16, padding: "0 16px", boxShadow: "0 4px 12px rgba(26,26,26,0.06)" }}>
          <TxTile kind="topup" name={dir==="rtl"?"بنك فلسطين":"Bank of Palestine"} sub={dir==="rtl"?"عبر E-SADAD · اليوم":"via E-SADAD · Today"} amount={500}/>
          <TxTile kind="p2pOut" name="Mahmoud Al-Khatib" sub={dir==="rtl"?"دفع بدون اتصال · 2:14 م":"Offline · 2:14 PM"} amount={80} signed pending dir={dir}/>
          <TxTile kind="bank" name="iBuraq · Family" sub={dir==="rtl"?"البارحة":"Yesterday"} amount={250}/>
          <TxTile kind="p2pIn" name="Layla Hammad" sub={dir==="rtl"?"بدون اتصال · أمس":"Offline · Yesterday"} amount={120} signed/>
        </div>
      </div>
      <BottomNav active="home" dir={dir}/>
    </Scaffold>
  );
}

window.ScreenSplash = ScreenSplash;
window.ScreenPhone = ScreenPhone;
window.ScreenOTP = ScreenOTP;
window.ScreenProfile = ScreenProfile;
window.ScreenHome = ScreenHome;
