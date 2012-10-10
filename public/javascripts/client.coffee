###
Game class
@contructor ip (ip to connect to), name (player.name), slider (what will become the controller)
###
class Game
	@_lastPosition: 0

	constructor: (ip, name, @slider) ->
		@settings =
			interval: 30
		@player =
			name: name
		@socket = io.connect ip
		@socket.on 'connect', @connected
		@socket.on 'yourcolor', @init
		#@socket.on 'nogamescreen', @disconnect

	setLastPosition: (position) -> @_lastPosition = position
	getLastPosition: -> @_lastPosition

	init: (controller) =>
		@controller = new Controller @slider, controller.color
		document.addEventListener 'touchstart', @onTouchStart
		document.addEventListener 'touchmove', @onTouchMove
		document.addEventListener 'mousemove', @onMouseMove
		setInterval @onTick, @settings.interval

	connected: =>
		@send 'newplayer', @player.name
		# fix for the game to work with the current flash gamescreen
		@send 'position', 0

	disconnect: () => noGameScreen()

	onTouchStart: (event) => if _isAndroid() then event.preventDefault()

	onTouchMove: (event) =>
		event.preventDefault()
		if _isAndroid() then x = event.touches[0].pageX else x = event.pageX
		@controller.setPosition x

	onMouseMove: (event) => @controller.setPosition event.pageX

	onTick: =>
		position = @controller.getPosition()
		if position isnt @getLastPosition()
			@send 'position', position
			@setLastPosition position

	send: (type, value) -> @socket.emit(type, value)

###
Controller class
@constructor slider (slider element), color (color of the slider)
###
class Controller
	@_color: '#FF0088'
	@_position: 0

	constructor: (@slider, color) -> @setColor color

	getPosition: -> @_position

	setPosition: (position) ->
		@_moveSlider(position)
		percentage = Math.round(position / document.body.clientWidth * 100)
		percentage = 100 if percentage > 100
		percentage = 0 if percentage < 0
		@_position = percentage

	_moveSlider: (position) -> @slider.style.left = _addPx position

	getColor: -> @_color

	setColor: (color) ->
		@_color = '#' + color
		@_changeColor()

	_changeColor: () ->
		@slider.style.backgroundColor = @getColor()
		@slider.style.boxShadow = '0px 0px 10px 2px' + @getColor()

# Helpers
_id = (id) -> document.getElementById id
_remove = (id) -> (element = _id id).parentNode.removeChild element
_isAndroid = -> navigator.userAgent.match /Android/i;
_addPx = (value) -> value + 'px'

# Site
onLoad = ->
	window.optionsHolder = _id 'options'
	window.connectButton = _id 'connectButton'
	bind()
	onResize()

bind = -> window.connectButton.addEventListener 'click', onConnectClick
unbind = -> window.connectButton.removeEventListener 'click', onConnectClick

onResize = ->
	middle = _addPx (window.innerHeight / 2) - (window.optionsHolder.offsetHeight / 2) - (window.connectButton.offsetHeight - 20)
	center = _addPx (window.innerWidth / 2) - (window.optionsHolder.offsetWidth / 2)
	window.optionsHolder.style.top = middle
	window.optionsHolder.style.left = center

hideConnectOptions = -> _id('connect').style.display = 'none'
showConnectOptions = -> _id('connect').style.display = 'block'

onConnectClick = (event) ->
	event.preventDefault()
	unbind()
	ip = _id('ip').value
	name = _id('nickname').value
	if ip.length > 0 and name.length > 0
		slider = _id 'slider'
		try
			window.game = new Game ip, name, slider
			hideConnectOptions()
		catch error
			window.alert 'Could not connect to the server: ' + ip
			showConnectOptions()
			bind()

noGameScreen = ->
	window.alert('No gamescreen connected')
	# TODO, find better way to undo io.connect
	window.location.reload()

window.onload = onLoad
window.onresize = onResize