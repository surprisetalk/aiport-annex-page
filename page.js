
var annex = require('../aiport-dev/dev.js').annex;
// TODO: aiport-scaffold, aiport-scrap, aiport-plugin
// var page = require('../aiport-scaffold/scaffold.js').annex;

var pages = annex( 
    __dirname + "/annexes.jade",
    query => Promise.resolve({ annexes: page.installed().annex }) );

module.exports = pages;

