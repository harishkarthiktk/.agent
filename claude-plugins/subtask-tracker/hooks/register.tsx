import { atom, read, update } from "claude-code";
import type { Register } from "claude-code";

import type { Task } from "../types";

const PANE = "subtask-tracker";
const tasks = atom(
  { plugin: "subtask-tracker", key: "tasks" } as const,
  [] as Task[],
);

function parseTodo(text: string): Task[] {
  return text.split("\n").flatMap((line) => {
    const m = line.match(/^- \[(.)\] (.+)/);
    if (!m) return [];
    const [, marker, label] = m;
    const status: Task["status"] =
      marker === "x" ? "done" : marker === ">" ? "in_progress" : "pending";
    return [{ label: label.trim(), status }];
  });
}

export const register: Register = (on) => {
  on("session.start", async ($, e, next) => {
    void $.ui.open({ id: PANE, title: "Tasks" });

    $.clock.every(2000, async () => {
      try {
        const text = await $.fs.read(".todo");
        const list = parseTodo(typeof text === "string" ? text : "");
        await update($, tasks, () => list);
        const done = list.filter((t) => t.status === "done").length;
        void $.ui.open({ id: PANE, title: `Tasks (${done}/${list.length})` });
      } catch {
        // .todo absent or unreadable — leave list as-is
      }
    });

    return next(e);
  });

  on("ui.render", { component: "Pane", requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e);
    const list = await read($, tasks);

    const viewCols = e.viewport?.columns ?? 40;
    // paddingX=1 takes 2 cols; '[' + '] XX%' takes 7 cols
    const barInner = Math.max(6, viewCols - 2 - 9) * 0.8;
    const cols = viewCols - 4;
    const done = list.filter((t) => t.status === "done").length;
    const total = list.length;
    const pct = total > 0 ? Math.round((done / total) * 100) : 0;
    const complete = pct === 100;
    const filled = total > 0 ? Math.round((done / total) * barInner) : 0;
    const bar =
      "[" + "█".repeat(filled) + "░".repeat(barInner - filled) + `] ${pct}%`;

    return (
      <Box flexDirection="column" paddingX={1} paddingTop={1} paddingBottom={1}>
        {/* Header */}
        <Box marginBottom={1}>
          <Text bold color="green">
            ■ TASKS ■
          </Text>
          <Text dimColor>
            {"  "}
            {done} / {total}
          </Text>
        </Box>

        {/* Progress bar */}
        {total > 0 && (
          <Box marginBottom={1}>
            <Text color="green" dimColor={complete} wrap="truncate">
              {bar}
            </Text>
          </Box>
        )}

        {/* Double-rule separator */}
        <Box marginBottom={1}>
          <Text dimColor wrap="truncate">
            {"═".repeat(cols)}
          </Text>
        </Box>

        {/* Task list */}
        {list.length === 0 ? (
          <Text dimColor>[□] No .todo file in project root.</Text>
        ) : (
          list.map((task, i) => {
            if (task.status === "done") {
              return (
                <Box key={i}>
                  <Text dimColor> [■] {task.label}</Text>
                </Box>
              );
            }
            if (task.status === "in_progress") {
              return (
                <Box key={i}>
                  <Text bold color="yellow" inverse>
                    {" "}
                    [►] {task.label}{" "}
                  </Text>
                </Box>
              );
            }
            return (
              <Box key={i}>
                <Text color="white"> [□] {task.label}</Text>
              </Box>
            );
          })
        )}
      </Box>
    );
  });
};
