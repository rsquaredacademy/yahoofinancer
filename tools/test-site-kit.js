// Run with: node tools/test-site-kit.js  (offline helper tests for the vendored site-kit)
const assert = require('assert');
const a = require('../pkgdown/assets/site-kit/rsa-analytics.js');

const shown = ['Europe/Paris', 'Asia/Nicosia', 'Asia/Famagusta', 'Atlantic/Azores',
               'Atlantic/Madeira', 'Atlantic/Canary', 'Atlantic/Reykjavik'];
const hidden = ['Asia/Kolkata', 'America/New_York', 'Asia/Tokyo', '', null];

for (const z of shown) assert.strictEqual(a.shouldShowBanner(z, null), true, z);
for (const z of hidden) assert.strictEqual(a.shouldShowBanner(z, null), false, String(z));
assert.strictEqual(a.shouldShowBanner('Asia/Nicosia', 'granted'), false);
assert.strictEqual(a.shouldShowBanner('Asia/Nicosia', 'denied'), false);
console.log('site-kit helper tests passed');
