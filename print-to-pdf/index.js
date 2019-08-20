const puppeteer = require('puppeteer');
const argv = require('yargs').argv;

let url = argv.url;
let path = argv.path;
let format = argv.format || 'Letter';

(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.setViewport({ width: 1250, height: 1650 }); // by trial-and-error, this makes charts render at the right width
  await page.goto(url, { waitUntil: 'networkidle0' });
  await page.pdf({ path, format, printBackground: true });
  await browser.close();
})();
