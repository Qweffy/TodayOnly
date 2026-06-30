# Just Today - Roadmap

> One "today only" task manager, in sync across every device. Open-source (MIT).
>
> **Progress (jun 2026):** multiplatform target builds for macOS + iOS (Fase 0 + Fase 1 done), CI pipeline added. Next: iOS UI for iPhone (Fase 2), then CloudKit sync (Fase 3).

Status: planning. Estimates are rough, solo-dev relative sizes: **S** ≈ <1 día, **M** ≈ 1–3 días, **L** ≈ 3–7 días, **XL** ≈ 1–3 semanas.

---

## Estado actual (jun 2026)

- **macOS** - SwiftUI + SwiftData, local-only. Secciones Must Do / Bonus, prompt "do it now" (<5 min), review de rollover, notas, reorder dentro de cada sección, modal de edición.
- **Windows** - app Tauri (Rust + HTML/CSS/JS), codebase aparte, local-only.
- **Distribución** - manual (Archive → Copy to /Applications). Sin sync.
- **Licencia** - MIT, open-source.

---

## Decisiones que enmarcan todo

1. **MVP = solo Apple (macOS + iOS) con sync por CloudKit.** Es el camino más barato: la app ya es SwiftUI + SwiftData, y CloudKit da sync casi gratis, sin backend, privado por usuario.
2. **Windows + Android van después y cambian la arquitectura.** CloudKit es solo-Apple: para sumar Windows/Android hay que introducir un **backend de sync real** (ver Fase 5). El sync de la fase MVP se diseña detrás de una abstracción para poder cambiarlo/duplicarlo más adelante.
3. **Nativo, no rewrite.** No se reescribe en React Native para el MVP: se comparte el código SwiftUI/SwiftData entre macOS e iOS.
4. **Todo open-source (MIT).** Sin secrets en el repo. MIT evita el conflicto GPL ↔ App Store.

---

## Fase 0 - Lock-in y setup · **S**

- [ ] Confirmar MVP solo-Apple + camino nativo (sin RN).
- [ ] Fijar deployment targets: macOS 14, iOS 17 (requeridos por SwiftData).
- [ ] Crear el target/scheme de iOS vacío y que buildee.

## Fase 1 - Refactor a código compartido · **M**

- [ ] Mover `Models/`, `ViewModels/`, `Views/` a membership compartida (o un Swift package / framework shared).
- [ ] Gatear las APIs solo-macOS con `#if os(macOS)`:
  - `.defaultSize` / `.frame(minWidth:minHeight:)` en `TodayOnlyApp` / `ContentView`.
  - `Color(nsColor:)` en `dragPreview` (TaskListView) → equivalente cross-platform.
  - Cualquier uso de AppKit.
- [ ] Verificar que todas las vistas compilan para iOS.

## Fase 2 - App iOS · **L**

- [ ] Target iOS compartiendo los fuentes.
- [ ] Shell de iPhone: `NavigationStack`, adaptar el layout de dos secciones, el alta de tarea y el sheet de rollover al tamaño teléfono.
- [ ] Paridad de interacción:
  - `.contextMenu` ya funciona en iOS (long-press).
  - Reorder: evaluar `EditMode` + `.onMove` nativo en iOS vs el drag actual.
  - Flujo "do it now".
- [ ] Ícono iOS full-bleed (ya tenemos el arte; iOS sí quiere borde a borde).

## Fase 3 - Sync con CloudKit · **L**

- [ ] Activar capability iCloud + CloudKit (container).
- [ ] Hacer el schema SwiftData compatible con CloudKit:
  - Atributos opcionales o con default (✔ `notes`, `sortIndex` ya tienen default).
  - **Sin `@Attribute(.unique)`**; relaciones opcionales.
  - Cambiar el `ModelContainer` a base CloudKit (`cloudKitDatabase`).
- [ ] Migrar el store local existente al backed-by-CloudKit (sin perder data).
- [ ] Conflictos: CloudKit hace last-writer-wins por campo; probar multi-device.
- [ ] Fallback sin cuenta de iCloud → modo local.

## Fase 4 - Ship del MVP Apple · **M**

- [ ] macOS: notarización (Developer ID) y/o Mac App Store.
- [ ] iOS: TestFlight → App Store.
- [ ] Privacy label: data en el iCloud privado del usuario, sin colección de datos.
- [ ] Assets de store (screenshots, descripción) para ambos.

---

## Fase 5+ - Más allá de Apple (Windows + Android) · **XL**

> El salto grande: CloudKit no habla con Windows/Android. Acá se mete un backend de sync.

- [ ] Backend/BaaS (Supabase / Firebase / API custom + Postgres) con auth.
- [ ] Abstraer la capa de sync para que macOS/iOS puedan cambiar de CloudKit al backend (o correr ambos).
- [ ] **Android** - decisión pendiente: nativo (Kotlin/Compose), KMP, o rewrite mobile en React Native (reusando stack tipo SyncUp).
- [ ] **Windows** - la app Tauri consume el mismo backend.
- [ ] Modelo de datos y migración unificados entre las 3+ plataformas.

Esto es scope nivel producto, no feature. Se estima en detalle cuando se llegue.

---

## Riesgos / preguntas abiertas

- **Restricciones de CloudKit** (sin unique, reglas de schema) condicionan el modelo.
- **Dos codebases** (Swift + Tauri) divergen hasta que un backend común unifique la data.
- **UX de iPhone**: la app es de "ventana de escritorio", hay que repensar el layout para teléfono.
- **Clones en stores**: al ser open-source, alguien podría intentar subir un clon. Mitiga: MIT + guidelines anti-copycat de Apple (4.1/4.3), que suelen favorecer al autor original.

## Open-source & stores (resumen)

- Licencia **MIT** → sin conflicto GPL ↔ App Store. Google Play sin restricciones.
- **Nunca** commitear secrets: certs de firma, provisioning profiles, App Store Connect API keys, y (a futuro) keys del backend → secrets de CI / keychain local.
