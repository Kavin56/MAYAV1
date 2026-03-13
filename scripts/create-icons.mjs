import sharp from 'sharp';
import path from 'path';
import { fileURLToPath } from 'url';

import fs from 'fs';
const __dirname = process.cwd();
const logoPath = "C:\\Users\\Surya\\Downloads\\images\\AI_Generated\\Gemini_Generated_Image_30iwyo30iwyo30iw__1_-removebg-preview.png";

const sizes = {
  'favicon-16x16.png': 16,
  'favicon-32x32.png': 32,
  'favicon.png': 32,
};

const tauriIcons = {
  'icon.png': 512,
  '128x128.png': 128,
  '128x128@2x.png': 256,
  '64x64.png': 64,
  '32x32.png': 32,
  'Square310x310Logo.png': 310,
  'Square284x284Logo.png': 284,
  'Square150x150Logo.png': 150,
  'Square142x142Logo.png': 142,
  'Square107x107Logo.png': 107,
  'Square89x89Logo.png': 89,
  'Square71x71Logo.png': 71,
  'Square44x44Logo.png': 44,
  'Square30x30Logo.png': 30,
  'StoreLogo.png': 50,
};

console.log('Loading logo...');
console.log('Logo path:', logoPath);
console.log('Exists:', fs.existsSync(logoPath));
const logo = sharp(logoPath);

// Create favicons
const faviconDir = path.join(__dirname, 'packages/app/public');
console.log('Favicon dir:', faviconDir);
for (const [name, size] of Object.entries(sizes)) {
  const outPath = path.join(faviconDir, name);
  await logo.clone().resize(size, size, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toFile(outPath);
  console.log(`Created ${name}`);
}

// Create Tauri icons
const tauriDir = path.join(__dirname, 'packages/desktop/src-tauri/icons');
console.log('Tauri dir:', tauriDir);
for (const [name, size] of Object.entries(tauriIcons)) {
  const outPath = path.join(tauriDir, name);
  await logo.clone().resize(size, size, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toFile(outPath);
  console.log(`Created ${name}`);
}

// Create ICO (Windows) - use 256x256 PNG as base
await logo.clone().resize(256, 256, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toFile(path.join(tauriDir, 'icon.ico.png'));
console.log('Created icon.ico.png (convert to .ico manually if needed)');

// Create ICNS placeholder (macOS)
await logo.clone().resize(512, 512, { fit: 'contain', background: { r: 0, g: 0, b: 0, alpha: 0 } }).png().toFile(path.join(tauriDir, 'icon.icns.png'));
console.log('Created icon.icns.png (convert to .icns manually if needed)');

console.log('All icons created!');
