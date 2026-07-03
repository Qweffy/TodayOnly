# Just Today

A minimal daily task manager. Not a todo app — it only manages **today**.

Two sections: **Must Do** and **Bonus**. Tasks don't carry over automatically — when you open the app on a new day, you review what's left and decide what to keep.

When adding a task, if it takes less than 5 minutes, the app tells you: **"Do it now."**

## macOS

Native SwiftUI app with SwiftData persistence.

### Install from source

1. Open `JustToday.xcodeproj` in Xcode
2. `Cmd+R` to run, or:
3. **Product → Archive → Distribute App → Custom → Copy App**
4. Move `Just Today.app` to `/Applications`

**Requirements:** Xcode 15+, macOS 14+

## Windows

Lightweight native app built with [Tauri](https://tauri.app) (Rust + HTML/CSS/JS).

### Install from source

1. Install [Rust](https://rustup.rs) and [Node.js](https://nodejs.org) (v18+)
2. Clone this repo and run:

```bash
cd windows
npm install
npm run tauri build
```

3. Find the installer at `windows/src-tauri/target/release/bundle/`

### Run in dev mode

```bash
cd windows
npm install
npm run tauri dev
```

## How it works

- **Add a task** → asked if it takes more than 5 minutes
  - **Less than 5 min** → "Do it now." Mark as done or add anyway
  - **More than 5 min** → Choose: Must Do or Bonus
- **Check off tasks** as you complete them
- **Delete tasks** you don't need
- **Next day** → review unfinished tasks: carry to today, mark done, or drop

No backlog. No reminders. No notifications. No sync. Just today.

## License

MIT
