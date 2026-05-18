const STORAGE_KEY = "todayonly_tasks";

function loadTasks() {
  const raw = localStorage.getItem(STORAGE_KEY);
  return raw ? JSON.parse(raw) : [];
}

function saveTasks(tasks) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(tasks));
}

function todayStr() {
  return new Date().toISOString().slice(0, 10);
}

function isToday(dateStr) {
  return dateStr === todayStr();
}

// --- State ---

let tasks = loadTasks();
let addStep = null; // "title" | "doItNow" | "category"
let addTitle = "";

// --- Rollover ---

function getRolloverTasks() {
  return tasks.filter((t) => t.status === "pending" && !isToday(t.createdAt));
}

function checkRollover() {
  const rollover = getRolloverTasks();
  if (rollover.length === 0) {
    document.getElementById("rollover").classList.add("hidden");
    document.getElementById("app").style.display = "";
    return;
  }
  document.getElementById("app").style.display = "none";
  document.getElementById("rollover").classList.remove("hidden");
  renderRollover();
}

function renderRollover() {
  const list = document.getElementById("rollover-list");
  const rollover = getRolloverTasks();
  const btn = document.getElementById("btn-finish-rollover");
  btn.disabled = rollover.length > 0;

  list.innerHTML = rollover
    .map(
      (t) => `
    <div class="rollover-task">
      <span class="title">${esc(t.title)}</span>
      <div class="actions">
        <button class="btn-small carry" onclick="rolloverAction('${t.id}','carry')">Carry</button>
        <button class="btn-small done" onclick="rolloverAction('${t.id}','done')">Done</button>
        <button class="btn-small drop" onclick="rolloverAction('${t.id}','drop')">Drop</button>
      </div>
    </div>`
    )
    .join("");
}

window.rolloverAction = function (id, action) {
  const task = tasks.find((t) => t.id === id);
  if (!task) return;

  if (action === "carry") {
    task.createdAt = todayStr();
    task.status = "pending";
  } else if (action === "done") {
    task.status = "done";
  } else if (action === "drop") {
    task.status = "dropped";
  }

  saveTasks(tasks);
  renderRollover();
};

document.getElementById("btn-finish-rollover").addEventListener("click", () => {
  document.getElementById("rollover").classList.add("hidden");
  document.getElementById("app").style.display = "";
  render();
});

// --- Render ---

function render() {
  const today = todayStr();
  const todayTasks = tasks.filter(
    (t) => t.createdAt === today && t.status !== "dropped"
  );
  const mustDo = todayTasks.filter((t) => t.category === "mustDo");
  const bonus = todayTasks.filter((t) => t.category === "bonus");
  const container = document.getElementById("task-list");

  if (todayTasks.length === 0) {
    container.innerHTML = `
      <div class="empty-state">
        <div class="icon">✓</div>
        <div class="title">Nothing for today</div>
        <div class="subtitle">Click + to add a task</div>
      </div>`;
    return;
  }

  let html = "";
  if (mustDo.length > 0) html += renderSection("Must Do", "must-do", "🔥", mustDo);
  if (bonus.length > 0) html += renderSection("Bonus", "bonus", "⭐", bonus);
  container.innerHTML = html;
}

function renderSection(title, cls, icon, sectionTasks) {
  const pending = sectionTasks.filter((t) => t.status === "pending");
  const done = sectionTasks.filter((t) => t.status === "done");
  const allDone = pending.length === 0 && done.length > 0;
  const cardClass = allDone ? "all-done" : cls;

  let rows = pending.map((t) => taskRow(t, cls)).join("");
  rows += done.map((t) => taskRow(t, cls)).join("");

  return `
    <div class="section-card ${cardClass}">
      <div class="section-header ${cls}">
        <span class="icon">${icon}</span>
        <span class="label">${title}</span>
        <span class="count">${pending.length} left</span>
      </div>
      <div class="section-divider"></div>
      ${rows}
    </div>`;
}

function taskRow(task, sectionCls) {
  const isDone = task.status === "done";
  const checkCls = isDone ? "checked" : sectionCls;
  const rowCls = isDone ? "done" : "";

  return `
    <div class="task-row ${rowCls}">
      <button class="task-check ${checkCls}" onclick="toggleTask('${task.id}')">
        ${isDone ? "✓" : ""}
      </button>
      <span class="task-title ${isDone ? "done" : ""}">${esc(task.title)}</span>
      <button class="task-delete" onclick="deleteTask('${task.id}')">🗑</button>
    </div>`;
}

// --- Actions ---

window.toggleTask = function (id) {
  const task = tasks.find((t) => t.id === id);
  if (!task) return;
  task.status = task.status === "done" ? "pending" : "done";
  saveTasks(tasks);
  render();
};

window.deleteTask = function (id) {
  tasks = tasks.filter((t) => t.id !== id);
  saveTasks(tasks);
  render();
};

function addTask(title, category, status) {
  tasks.push({
    id: crypto.randomUUID(),
    title,
    category,
    status,
    createdAt: todayStr(),
  });
  saveTasks(tasks);
  closeModal();
  render();
}

// --- Modal ---

function openModal() {
  addStep = "title";
  addTitle = "";
  document.getElementById("add-modal").classList.remove("hidden");
  renderModal();
}

function closeModal() {
  document.getElementById("add-modal").classList.add("hidden");
}

function renderModal() {
  const content = document.getElementById("modal-content");

  if (addStep === "title") {
    content.innerHTML = `
      <h2>New Task</h2>
      <input type="text" id="task-input" placeholder="What do you need to do?" value="${esc(addTitle)}" />
      <div id="duration-btns" style="display:none">
        <button class="btn btn-primary" onclick="modalAction('short')">🐇 Less than 5 min</button>
        <button class="btn btn-secondary" onclick="modalAction('long')">🕐 More than 5 min</button>
      </div>`;

    const input = document.getElementById("task-input");
    const btns = document.getElementById("duration-btns");
    input.focus();

    function update() {
      addTitle = input.value;
      btns.style.display = input.value.trim() ? "" : "none";
    }

    input.addEventListener("input", update);
    input.addEventListener("keydown", (e) => {
      if (e.key === "Escape") closeModal();
    });
    update();
  } else if (addStep === "doItNow") {
    content.innerHTML = `
      <div class="step-content">
        <div class="bolt-icon">⚡</div>
        <h3>Do it now.</h3>
        <p class="task-preview">"${esc(addTitle)}"</p>
        <button class="btn btn-primary green" onclick="modalAction('markDone')">✓ Already done</button>
        <button class="btn btn-secondary" onclick="modalAction('addAnyway')">+ Add to today anyway</button>
      </div>`;
  } else if (addStep === "category") {
    content.innerHTML = `
      <div class="step-content">
        <h2>Is this required today?</h2>
        <p class="task-preview">"${esc(addTitle)}"</p>
        <button class="btn btn-primary" onclick="modalAction('mustDo')">🔥 I have to do it today</button>
        <button class="btn btn-secondary" onclick="modalAction('bonus')">⭐ Bonus if I do it</button>
      </div>`;
  }
}

window.modalAction = function (action) {
  if (action === "short") {
    addStep = "doItNow";
    renderModal();
  } else if (action === "long") {
    addStep = "category";
    renderModal();
  } else if (action === "markDone") {
    addTask(addTitle, "mustDo", "done");
  } else if (action === "addAnyway") {
    addTask(addTitle, "mustDo", "pending");
  } else if (action === "mustDo") {
    addTask(addTitle, "mustDo", "pending");
  } else if (action === "bonus") {
    addTask(addTitle, "bonus", "pending");
  }
};

// --- Util ---

function esc(str) {
  const d = document.createElement("div");
  d.textContent = str;
  return d.innerHTML;
}

// --- Init ---

document.getElementById("btn-open-add").addEventListener("click", openModal);
document.getElementById("btn-close-modal").addEventListener("click", closeModal);
document.getElementById("add-modal").addEventListener("click", (e) => {
  if (e.target === e.currentTarget) closeModal();
});

checkRollover();
render();
