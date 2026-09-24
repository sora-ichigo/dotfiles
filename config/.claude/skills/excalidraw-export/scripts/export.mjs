import { readFile, writeFile } from "node:fs/promises";
import { createRequire } from "node:module";
import path from "node:path";
import { parseArgs } from "node:util";

const usage = `Usage: export.sh <input.excalidraw> [-o output.png] [--scale 2] [--padding 10] [--dark] [--transparent] [--svg output.svg]`;

const { values, positionals } = parseArgs({
  allowPositionals: true,
  options: {
    output: { type: "string", short: "o" },
    scale: { type: "string", default: "2" },
    padding: { type: "string", default: "10" },
    dark: { type: "boolean", default: false },
    transparent: { type: "boolean", default: false },
    svg: { type: "string" },
    help: { type: "boolean", short: "h", default: false },
  },
});

if (values.help || positionals.length !== 1) {
  console.error(usage);
  process.exit(values.help ? 0 : 1);
}

const depsDir = process.env.EXCALIDRAW_EXPORT_DEPS_DIR;
if (!depsDir) {
  console.error("EXCALIDRAW_EXPORT_DEPS_DIR is not set. Run via export.sh.");
  process.exit(1);
}

const require = createRequire(path.join(depsDir, "package.json"));
const { chromium } = require("playwright");
const utilsDir = path.join(depsDir, "node_modules/@excalidraw/utils/dist/prod");

const input = path.resolve(positionals[0]);
const output = path.resolve(
  values.output ?? input.replace(/\.excalidraw(\.json)?$/i, "") + ".png",
);
const scale = Number(values.scale);
const padding = Number(values.padding);

const scene = JSON.parse(await readFile(input, "utf8"));
if (!Array.isArray(scene.elements)) {
  console.error(`${input} is not an Excalidraw scene (missing "elements").`);
  process.exit(1);
}

const origin = "http://excalidraw-export.local";
const browser = await chromium.launch();
try {
  const page = await browser.newPage({ deviceScaleFactor: scale });
  await page.route(`${origin}/**`, async (route) => {
    const { pathname } = new URL(route.request().url());
    if (pathname === "/") {
      return route.fulfill({
        contentType: "text/html",
        body: "<!doctype html><meta charset=utf-8><style>html,body{margin:0;background:transparent}svg{display:block}</style><body></body>",
      });
    }
    const file = path.join(utilsDir, decodeURIComponent(pathname));
    if (!file.startsWith(utilsDir)) return route.abort();
    try {
      return await route.fulfill({ path: file });
    } catch {
      return route.fulfill({ status: 404 });
    }
  });
  await page.goto(`${origin}/`);

  const svgText = await page.evaluate(
    async ({ origin, scene, padding, dark, transparent }) => {
      window.EXCALIDRAW_ASSET_PATH = `${origin}/`;
      const { exportToSvg } = await import(`${origin}/index.js`);
      const svg = await exportToSvg({
        data: {
          elements: scene.elements.filter((element) => !element.isDeleted),
          appState: { ...scene.appState, exportScale: 1, exportWithDarkMode: dark, exportBackground: !transparent },
          files: scene.files ?? {},
        },
        config: {
          theme: dark ? "dark" : "light",
          padding,
          ...(transparent ? { canvasBackgroundColor: false } : {}),
        },
      });
      const svgText = new XMLSerializer().serializeToString(svg);
      svg.id = "excalidraw-export";
      document.body.append(svg);
      await Promise.all([...svg.querySelectorAll("image")].map((image) => image.decode?.().catch(() => {})));
      const families = new Set(
        [...svg.querySelectorAll("text")].flatMap((text) =>
          (text.getAttribute("font-family") ?? "").split(",").map((family) => family.trim()),
        ),
      );
      const size = Math.max(...[...svg.querySelectorAll("text")].map((text) => parseFloat(text.getAttribute("font-size")) || 16), 16);
      const content = [...svg.querySelectorAll("text")].map((text) => text.textContent).join("");
      await Promise.all([...families].map((family) => document.fonts.load(`${size}px "${family}"`, content || "a")));
      await document.fonts.ready;
      await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
      return svgText;
    },
    { origin, scene, padding, dark: values.dark, transparent: values.transparent },
  );

  const svgElement = page.locator("#excalidraw-export");
  const box = await svgElement.boundingBox();
  await page.setViewportSize({ width: Math.ceil(box.width), height: Math.ceil(box.height) });
  await svgElement.screenshot({ path: output, omitBackground: values.transparent });
  if (values.svg) await writeFile(path.resolve(values.svg), svgText);
  console.log(`${output} (${Math.round(box.width * scale)}x${Math.round(box.height * scale)})`);
} finally {
  await browser.close();
}
