import pngToIco from 'png-to-ico';
import fs from 'fs';
import path from 'path';

const iconDir = "C:\\Users\\Surya\\Downloads\\MAYA\\packages\\desktop\\src-tauri\\icons";
const logoPath = path.join(iconDir, 'icon.png');

async function convert() {
  const buf = await pngToIco(logoPath);
  fs.writeFileSync(path.join(iconDir, 'icon.ico'), buf);
  console.log('Created icon.ico');
}

convert().catch(console.error);
