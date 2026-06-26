// Minimal ICO packer: bundles PNG files into a single multi-resolution .ico.
// Windows Vista+ reads PNG-compressed ICO entries directly, so we embed each
// PNG verbatim (no BMP re-encode). Usage: node png2ico.mjs out.ico a.png b.png …
import { readFileSync, writeFileSync } from 'node:fs';

const [out, ...pngs] = process.argv.slice(2);
if (!out || pngs.length === 0) {
  console.error('usage: node png2ico.mjs <out.ico> <png...>');
  process.exit(1);
}

const entries = pngs.map((p) => {
  const data = readFileSync(p);
  // PNG IHDR width/height are big-endian uint32 at byte offsets 16 and 20.
  const w = data.readUInt32BE(16);
  const h = data.readUInt32BE(20);
  return { data, w, h };
});

const count = entries.length;
const header = Buffer.alloc(6);
header.writeUInt16LE(0, 0); // reserved
header.writeUInt16LE(1, 2); // type: icon
header.writeUInt16LE(count, 4);

const dir = Buffer.alloc(16 * count);
let offset = 6 + 16 * count;
entries.forEach((e, i) => {
  const o = i * 16;
  dir.writeUInt8(e.w >= 256 ? 0 : e.w, o + 0); // 0 encodes 256
  dir.writeUInt8(e.h >= 256 ? 0 : e.h, o + 1);
  dir.writeUInt8(0, o + 2); // palette
  dir.writeUInt8(0, o + 3); // reserved
  dir.writeUInt16LE(1, o + 4); // color planes
  dir.writeUInt16LE(32, o + 6); // bits per pixel
  dir.writeUInt32LE(e.data.length, o + 8);
  dir.writeUInt32LE(offset, o + 12);
  offset += e.data.length;
});

writeFileSync(out, Buffer.concat([header, dir, ...entries.map((e) => e.data)]));
console.log(`wrote ${out} (${count} sizes: ${entries.map((e) => e.w).join(', ')})`);
