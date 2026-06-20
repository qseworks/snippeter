import { createInterface } from "node:readline";
import { stdin, stdout } from "node:process";

/** Prompt for a single line of visible input. */
export function promptLine(question: string): Promise<string> {
  const rl = createInterface({ input: stdin, output: stdout });
  return new Promise<string>((resolve) => {
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

/**
 * Prompt for a secret without echoing characters back to the terminal.
 * Falls back to plain (visible) input when stdin is not a TTY (e.g. piped),
 * so the command still works in scripts: `printf 'pw\n' | snip login`.
 */
export function promptSecret(question: string): Promise<string> {
  if (!stdin.isTTY) {
    return promptLine(question);
  }

  return new Promise<string>((resolve) => {
    stdout.write(question);

    const wasRaw = stdin.isRaw ?? false;
    stdin.setRawMode(true);
    stdin.resume();
    stdin.setEncoding("utf8");

    let value = "";

    const onData = (chunk: string) => {
      for (const ch of chunk) {
        switch (ch) {
          case "\n":
          case "\r":
          case "": // Ctrl-D
            cleanup();
            stdout.write("\n");
            resolve(value);
            return;
          case "": // Ctrl-C
            cleanup();
            stdout.write("\n");
            process.exit(130);
            return;
          case "": // Backspace / DEL
          case "\b":
            if (value.length > 0) {
              value = value.slice(0, -1);
            }
            break;
          default:
            // Ignore other control characters.
            if (ch >= " ") {
              value += ch;
            }
            break;
        }
      }
    };

    const cleanup = () => {
      stdin.removeListener("data", onData);
      stdin.setRawMode(wasRaw);
      stdin.pause();
    };

    stdin.on("data", onData);
  });
}
