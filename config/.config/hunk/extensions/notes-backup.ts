import { mkdirSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join } from "node:path";

export default function (hunk: any) {
  const notes = new Map<string, unknown>();
  const paths = new Map<string, string>();
  const startedAt = new Date().toISOString().replace(/[:.]/g, "-");
  let file: string | undefined;

  hunk.on("note_created", (event: any) => {
    paths.set(event.note.id, event.note.filePath);
  });

  hunk.on("note_changed", (event: any, ctx: any) => {
    if (event.kind === "removed") {
      notes.delete(event.note.id);
    } else {
      notes.set(event.note.id, { path: paths.get(event.note.id), ...event.note });
    }
    if (!file) {
      const dir = join(process.env.XDG_STATE_HOME ?? join(homedir(), ".local", "state"), "hunk", "notes");
      mkdirSync(dir, { recursive: true });
      file = join(dir, `${startedAt}-${basename(ctx.cwd)}.json`);
    }
    writeFileSync(file, JSON.stringify({ cwd: ctx.cwd, notes: [...notes.values()] }, null, 2) + "\n");
  });
}
