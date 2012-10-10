
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Tripple Cheese', host: '192.168.8.146:3000', view: 'index' })
};

exports.gamescreen = function(req, res){
  res.render('gamescreen', { title: 'Tripple Cheese Gamescreen', host: '192.168.8.146:3000', view: 'gamescreen' })
};