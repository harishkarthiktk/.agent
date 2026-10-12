export type Task = { label: string; status: 'pending' | 'in_progress' | 'done' }

declare module 'claude-code' {
  interface PluginState {
    'subtask-tracker': { tasks: Task[] }
  }
}
