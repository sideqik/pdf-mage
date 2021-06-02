const puppeteer = require('puppeteer');
const argv = require('yargs').argv;
const Promise = require('bluebird');

let url = argv.url;
let path = argv.path;

// Landscape / Portrait
let isPixels = true;
let isLandscape = true;
let longerLengthValue = isPixels ? 1270 : '11in';
let shorterLengthValue = isPixels ? 720 : '8.5in';
let width = argv.width || isLandscape ? longerLengthValue : shorterLengthValue;
let height = argv.height || isLandscape ? shorterLengthValue : longerLengthValue;

let safetySeconds = argv.delay;
let scale = parseFloat(argv.scale) || 1;

const TIME_SINCE_LAST_REQUEST = 3000;
const MAX_RENDER_WAIT = 15000;

// https://github.com/GoogleChrome/puppeteer/issues/1353#issuecomment-356561654
function waitForNetworkIdle(page, timeout, maxInflightRequests = 0) {
  page.on('request', onRequestStarted);
  page.on('requestfinished', onRequestFinished);
  page.on('requestfailed', onRequestFinished);

  let inflight = 0;
  let fulfill;
  let promise = new Promise(x => fulfill = x);
  let timeoutId = setTimeout(onTimeoutDone, timeout);
  return promise;

  function onTimeoutDone() {
    page.removeListener('request', onRequestStarted);
    page.removeListener('requestfinished', onRequestFinished);
    page.removeListener('requestfailed', onRequestFinished);
    fulfill();
  }

  function onRequestStarted() {
    ++inflight;
    if (inflight > maxInflightRequests)
      clearTimeout(timeoutId);
  }

  function onRequestFinished() {
    if (inflight === 0)
      return;
    --inflight;
    if (inflight === maxInflightRequests)
      timeoutId = setTimeout(onTimeoutDone, timeout);
  }
}

function delay(timeout) {
  return new Promise((resolve) => {
    setTimeout(resolve, timeout);
  });
}

(async () => {
	const browser = await puppeteer.launch();
	const page = await browser.newPage();
	await page.setViewport({ width, height });

	await Promise.all([
		// IF a) all requests have resolved an no new requests have been made in 3 seconds, OR
		//    b) 15 seconds have elapsed
		// THEN move on to rendering to PDF
		Promise.any([
			new Promise((resolve) => setTimeout(resolve, MAX_RENDER_WAIT)),
			waitForNetworkIdle(page, TIME_SINCE_LAST_REQUEST),
		]),
		page.goto(url),
	]).catch(() => process.exit(1));

	await delay(safetySeconds * 1000);

	await page
    .pdf({
      path,
      width: width + 'px',
      height: height + 'px',
      scale,
      printBackground: true
    })
		.catch(() => process.exit(1));
	await browser.close();
})();
