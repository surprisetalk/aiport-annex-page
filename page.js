
var annex = require('../aiport-dev/dev.js').annex;
var page = require('../aiport-pile-page/page.js');
var scraps = require('../aiport-scrap/scraps.js');

// TODO: make an easier interface for serving files

var pages = annex( 
    __dirname + "/pages.jade",
    query => page.fetch().then( p => ({ pages: p, scraps: scraps }) ) );

module.exports = pages;

