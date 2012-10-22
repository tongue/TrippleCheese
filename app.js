/**
 * Module dependencies.
 */

var express = require('express')
	, routes = require('./routes');

var app = module.exports = express.createServer();

// Configuration

app.configure(function () {
	app.set('views', __dirname + '/views');
	app.set('view engine', 'jade');
	app.use(express.bodyParser());
	app.use(express.methodOverride());
	app.use(app.router);
	app.use(express.static(__dirname + '/public'));
});

app.configure('development', function () {
	app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function () {
	app.use(express.errorHandler());
});

// Routes

app.get('/', routes.index);
app.get('/gamescreen', routes.gamescreen)

app.listen(3000, function () {
	console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);
});

/**
 * Socket.io
 */
// , { transports: ['flashsocket', 'websocket', 'htmlfile', 'xhr-polling', 'jsonp-polling'] }
var io = require('socket.io').listen(app);

var clients = [],
	gameScreenIsSet = false,
	gameScreen;

io.enable('browser client minification');  // send minified client
io.enable('browser client etag');          // apply etag caching logic based on version number
io.enable('browser client gzip');          // gzip the file
io.set('log level', 1);                    // reduce logging
io.set('transports', [                     // enable all transports (optional if you want flashsocket)
	'websocket'
	, 'flashsocket'
	, 'htmlfile'
	, 'xhr-polling'
	, 'jsonp-polling'
]);

io.sockets.on('connection', function (socket) {
	socket.on('setgamescreen', function (gamescreen) {
		gameScreen = socket;
		gameScreenIsSet = true;
		console.log('### GAMESCREEN CONNECTED');
	});

	socket.on('position', function (xPos) {
		var pos = {
			'id': socket.id,
			'xpos': xPos
		};

		if (gameScreenIsSet) {
			gameScreen.emit('position', pos);
		} else {
			console.log('### NO GAMESCREEN AVAILABLE!');
		}
	});

	socket.on('color', function (player) {
		for (var i = 0; i < clients.length; i++) {
			if (clients[i][0] === player.id) {
				clients[i][1].emit('yourcolor', player);
			}
		}
	});

	socket.on('newplayer', function (player) {
		if (gameScreenIsSet) {
			var client = [socket.id, socket]
			clients.push(client);
			gameScreen.emit('newplayer', socket.id);
			console.log('### CLIENT CONNECTED');
		} else {
			socket.emit('nogamescreen', true);
			console.log('### NO GAMESCREEN AVAILABLE!');
			socket.disconnect();
		}
	});

	socket.on('disconnect', function () {
		if (socket === gameScreen) {
			gameScreenIsSet = false;
			console.log('### GAMESCREEN DISCONNECTED');
		}
	});

});