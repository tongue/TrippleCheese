
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Tripple Cheese', host: '192.168.0.10:3000'})
};

exports.gamescreen = function(req, res){
    res.render('gamescreen', { title: 'Tripple Cheese', host: '192.168.0.10:3000'})
};