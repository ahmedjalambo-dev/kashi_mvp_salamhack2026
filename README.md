<div align="center">

# كاشي · Kashi

**Offline-first peer-to-peer digital wallet**
*Built for SalamHack 2026 — Gaza*

[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-RPC-3ECF8E?logo=supabase)](https://supabase.com)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](#license)

</div>

---

## 🎥 Demo

Watch the full walkthrough on Google Drive:

**▶ [Kashi — Video Presentation](https://drive.google.com/file/d/12T43t-Z0u_f5vRcYSy29kXi2do25EvED/view?usp=sharing)**

[![Watch the demo](https://img.shields.io/badge/Google%20Drive-Watch%20Demo-4285F4?logo=googledrive&logoColor=white)](https://drive.google.com/file/d/12T43t-Z0u_f5vRcYSy29kXi2do25EvED/view?usp=sharing)

---

## What is Kashi?

Kashi lets two people transfer value **without an internet connection** — using
nothing but their phones and a QR code. The sender signs a payment payload
locally with an ECDSA (secp256r1) private key, the receiver scans, verifies the
signature, and stores the transaction. When either device comes back online, a
background sync process settles the ledger atomically on Supabase.

It is designed for environments where network availability is intermittent or
unreliable — for example, blackouts and outages in Gaza — while still giving
users a strong cryptographic guarantee that the money they "received" is real.

---

## How it works

```
┌──────────────┐                    ┌──────────────┐
│   Sender     │                    │   Receiver   │
│              │  ─── QR (offline)──►              │
│ sign(payload)│                    │ verify(sig)  │
└──────┬───────┘                    └──────┬───────┘
       │                                   │
       │   pending_sync (sqflite)          │   pending_sync (sqflite)
       │                                   │
       └──────────► [ when online ] ◄──────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  Supabase RPC         │
              │  sync_transaction()   │  ← atomic balance transfer
              │  SECURITY DEFINER     │     (idempotent on id)
              └───────────────────────┘
```

1. **Sign** — sender constructs a `PaymentPayload`, hashes its canonical JSON
   bytes, signs with secp256r1 / SHA-256.
2. **Encode** — payload + signature are wrapped in `base64(json({...}))` and
   shown as a QR.
3. **Scan & verify** — receiver scans, recomputes the canonical bytes, and
   verifies the signature against the sender's public key.
4. **Persist** — both sides write a row to `pending_transactions` with status
   `pending_sync`.
5. **Sync** — `SyncCubit` listens to connectivity; on every online edge it
   drains pending rows through the `sync_transaction` RPC, then reconciles with
   the server-side ledger.

---

## Tech stack

| Concern              | Library                                          |
| -------------------- | ------------------------------------------------ |
| Framework            | Flutter (`sdk: ^3.10.4`)                         |
| Backend / Auth / RPC | `supabase_flutter`                               |
| State management     | `flutter_bloc` (Cubits only)                     |
| Dependency injection | `get_it`                                         |
| Local DB             | `sqflite`                                        |
| Secure storage       | `flutter_secure_storage` (encrypted prefs)       |
| Crypto               | `pointycastle` — secp256r1 + SHA-256/ECDSA       |
| QR                   | `qr_flutter` (display) + `mobile_scanner` (scan) |
| Connectivity         | `connectivity_plus`                              |
| Tests                | `bloc_test`, `mocktail`                          |

---

## Project structure

```
lib/
├── main.dart
├── app.dart                      # MaterialApp + global cubit providers
├── core/
│   ├── crypto/                   # ecdsa_signer · payload_codec
│   ├── di/injector.dart          # get_it singletons
│   ├── network/                  # Result<T> · ErrorHandler · NetworkCubit
│   ├── routes/                   # route_generator · route names
│   ├── services/                 # local_db · secure_storage · connectivity
│   ├── theme/                    # app_theme
│   └── components/               # loading_view · error_view · offline_banner
└── features/
    ├── wallet/                   # balance, profile, public-key bootstrap
    ├── send/                     # build + sign payload, render QR
    ├── receive/                  # scan QR, verify, accept
    ├── history/                  # local-first transaction history
    └── sync/                     # global SyncCubit (drain + reconcile)
```

Each feature follows a strict unidirectional flow:

```
UI (Screen)  →  Cubit  →  Repository  →  Service
                                          (Supabase / sqflite / crypto)
```

- **Service** — direct calls; throws on failure.
- **Repository** — wraps services in try/catch, returns `Result<T>` =
  `Success(data) | Failure(ErrorModel)`.
- **Cubit** — orchestrates state. Zero UI imports.
- **UI** — reacts to states. Zero business logic.

---

## Crypto contract

| Item              | Value                                                                |
| ----------------- | -------------------------------------------------------------------- |
| Curve             | **secp256r1 (P-256)**                                                |
| Hash / signature  | SHA-256 / ECDSA, 64-byte `r‖s` then base64                           |
| Public key        | uncompressed point bytes (`Q.getEncoded(false)`), base64             |
| Private key       | unsigned 32-byte big-endian `d`, base64                              |
| Canonical JSON    | sorted keys, recursive, no whitespace (`PayloadCodec.canonicalBytes`)|

QR payload format:

```
base64( json({ payload: <SignedPayloadJson>, signature: <base64> }) )
```

`PaymentPayload` fields: `id`, `sender_public_key`, `receiver_public_key`,
`amount`, `nonce`, `client_created_at`, `expires_at`.

---

## Local SQLite

Database: `kashi.db` (schema **v5**), managed in `core/services/local_db.dart`.

| Table                  | Purpose                                                                 |
| ---------------------- | ----------------------------------------------------------------------- |
| `pending_transactions` | Outgoing/incoming QRs. `status ∈ {pending_sync, synced, rejected, voided_locally}` |
| `transactions_cache`   | Mirror of the remote ledger for the History screen                      |
| `wallet_cache`         | Single-row balance cache per public key                                 |

Schema bumps must increment `version` and add an `onUpgrade` branch for every
prior version (`if (oldVersion < N)`).

---

## Sync semantics

- `SyncCubit` and `NetworkCubit` are global singletons; `OfflineBanner` wraps
  every route via `MaterialApp.builder`.
- On any online transition, `SyncCubit.runOnce()` drains
  `pending_sync` through the `sync_transaction` RPC.
  - `PostgrestException` → row marked `rejected` with `last_error`.
  - `SocketException` → drain stops, row stays pending.
  - Success → row marked `synced`.
- After draining, `pullAndReconcile` flips any `voided_locally` rows the server
  already settled to `synced`.
- If anything is still pending, a 30-second retry timer is scheduled so
  transient failures self-heal.
- Idempotency lives server-side: the RPC uses `on conflict (id) do nothing` and
  only mutates balances on a true insert.

---

## Getting started

### 1. Prerequisites

- Flutter `3.10+`
- A Supabase project with the `wallets` and `transactions` tables and the
  `sync_transaction` RPC (`SECURITY DEFINER`, granted to `authenticated`).

### 2. Configure environment

Copy `.env.example` to `.env` at the project root:

```env
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon-key>
```

`.env` is gitignored and bundled as a Flutter asset.

### 3. Run

```bash
flutter pub get
flutter run
```

### 4. Build a release APK

```bash
flutter build apk --release
```

---

## Commands

```bash
flutter pub get                                              # install deps
flutter run                                                  # run on device/emulator
dart format .                                                # format
flutter analyze                                              # static analysis
flutter test                                                 # all tests
flutter test test/features/send/send_repository_test.dart    # single file
flutter test --plain-name "rejects tampered"                 # filter by name
flutter build apk --release                                  # release APK
```

---

## Testing

- `bloc_test` for cubit transitions; `mocktail` for repositories/services.
- Crypto round-trip and tamper-rejection tests in `test/widget_test.dart`.
- Network is never hit — mocks are injected at the service layer.
- Cubit tests that touch `GlobalKey` need
  `TestWidgetsFlutterBinding.ensureInitialized()`.

---

## Conventions

- Files: `snake_case.dart`. Classes: `UpperCamelCase`. Cubits: `<Feature>Cubit`.
  States: `<Feature><Variant>` (e.g. `SendReady`, `WalletFailure`).
- Sealed state hierarchies with `Equatable`.
- Files under ~150 lines; one widget per file; subtrees deeper than 3 levels
  extracted to `ui/components/`.
- Default to `const` and `StatelessWidget`; prefer `BlocBuilder` over derived
  `setState`.
- Lints: `package:flutter_lints/flutter.yaml`.

---

## Git workflow

- Branch off `dev`: `feature/<name>` or `fix/<name>`.
- Conventional Commits (`feat(send): ...`, `fix(sync): ...`).
- Open a PR only after `flutter analyze` and `flutter test` are green.

---

## License

MIT — see [LICENSE](LICENSE) (add one if you ship this).

<div align="center">

*Made with care for SalamHack 2026.*

</div>
