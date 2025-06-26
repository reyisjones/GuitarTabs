/**
 * Script to copy AlphaTab resources from node_modules to public directory
 * This ensures the resources are available in production builds
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const SOURCE_DIR = path.resolve(__dirname, '../node_modules/@coderline/alphatab/dist');
const TARGET_DIR = path.resolve(__dirname, '../public/assets/alphatab');

// Ensure target directories exist
fs.mkdirSync(path.join(TARGET_DIR, 'font'), { recursive: true });
fs.mkdirSync(path.join(TARGET_DIR, 'soundfont'), { recursive: true });

// Copy font files
const fontFiles = fs.readdirSync(path.join(SOURCE_DIR, 'font'));
fontFiles.forEach(file => {
  fs.copyFileSync(
    path.join(SOURCE_DIR, 'font', file),
    path.join(TARGET_DIR, 'font', file)
  );
  console.log(`Copied font file: ${file}`);
});

// Copy soundfont files
try {
  const soundfontFiles = fs.readdirSync(path.join(SOURCE_DIR, 'soundfont'));
  soundfontFiles.forEach(file => {
    fs.copyFileSync(
      path.join(SOURCE_DIR, 'soundfont', file),
      path.join(TARGET_DIR, 'soundfont', file)
    );
    console.log(`Copied soundfont file: ${file}`);
  });
} catch (error) {
  console.warn('Warning: Unable to copy soundfont files. Some features may not work correctly.', error);
  
  // Create a placeholder file to explain the issue
  fs.writeFileSync(
    path.join(TARGET_DIR, 'soundfont', 'README.txt'),
    'AlphaTab soundfont files were not copied. Please manually download sonivox.sf2 from https://cdn.jsdelivr.net/npm/@coderline/alphatab@1.6.0/dist/soundfont/ and place it in this directory.'
  );
}

console.log('AlphaTab resources copied successfully!');
