
# -------------------

class App extends Backbone.Router
	views: {}
	models: {}

	players: []
	activePlayer: undefined
	timer: undefined
	resetState: 0

	routes:
		'*path': 'pageChange'

	initialize: ()->
		Backbone.history.start()
		$('#add_player_button').on('click', @addPlayer)
		$('#pause_button').on('click', @playPause)
		$('#reset_button').on('click', @resetTimer)
		$('body').on('click', @checkResetState)

	addPlayer: () =>
		newPlayer = {
			number: @players.length
			lastReset: 0
			time: 0
			name: "Player #{@players.length + 1}"
			image: "assets/img/person.png"
			}
		@players.push(newPlayer)

		playerDiv = "<div class='col-md-4 player-panel' id='player_panel_#{newPlayer.number}'>"
		playerDiv += "<img src='#{newPlayer.image}'></img>"
		playerDiv += "<input type='file' class='custom-file-button' capture='camera' accept='image/*'' id='takePictureField_#{newPlayer.number}'>"
		playerDiv += "<h1>#{newPlayer.name}</h1>"
		playerDiv += "<h2 class='time'>0:00:00:00</h2>"
		playerDiv += "<h2 class='current-time'>0:00:00:00</h2>"
		playerDiv += "</div>"
		$('#player_panels').append(playerDiv)

		$('#player_panel_' + newPlayer.number).on('click', @selectPlayer)
		$('img', "#player_panel_#{newPlayer.number}").on('click', () => $("#takePictureField_#{newPlayer.number}").trigger("click"))
		$("#takePictureField_#{newPlayer.number}").on("change", @gotPic)

	gotPic: (event) =>
		if event.originalEvent?
			container = event.originalEvent.currentTarget
		else
			container = event.currentTarget
		player_number = +container.id.substring(container.id.lastIndexOf('_') + 1)

		if event.target.files.length == 1 && event.target.files[0].type.indexOf("image/") == 0
			@players[player_number].image = URL.createObjectURL(event.target.files[0])
			$("img", "#player_panel_#{player_number}").attr("src", @players[player_number].image)

	selectPlayer: (evt) =>
		if event.originalEvent?
			container = event.originalEvent.currentTarget
		else
			container = event.currentTarget
		player_number = +container.id.substring(container.id.lastIndexOf('_') + 1)

		@activePlayer = player_number
		$(".player-panel").removeClass('active')
		$(container).addClass('active')

		@players[player_number].lastReset = @players[player_number].time

		if not @timer
			@playPause()

	formatTime: (t) ->
		orig_t = new Date(t)
		return "#{orig_t.getUTCHours()}:#{('0' + orig_t.getUTCMinutes()).slice(-2)}:#{('0' + orig_t.getUTCSeconds()).slice(-2)}:#{orig_t.getUTCMilliseconds()/10}"

	timerStep: () =>
		@players[@activePlayer].time += 10
		$(".time", "#player_panel_#{@activePlayer}").text(@formatTime(@players[@activePlayer].time - @players[@activePlayer].lastReset))
		$(".current-time", "#player_panel_#{@activePlayer}").text(@formatTime(@players[@activePlayer].time))

	playPause: () =>
		if not @timer
			# init timer
			@timer = setInterval(@timerStep, 10)

			if @activePlayer?
				$("#player_panel_#{@activePlayer}").addClass('active')

			$('#pause_button').text('Pause')
		else
			# pause timer
			clearInterval(@timer)
			@timer = undefined

			$('.player-panel').removeClass('active')

			$('#pause_button').text('Play')

	checkResetState: (evt) =>
		if evt.originalEvent?
			event = evt.originalEvent
		else
			event = evt

		if not event.target.id? or event.target.id != "reset_button"
			@resetResetState()

	resetResetState: () =>
		@resetState = 0
		$("#reset_button").removeClass("really").text("Reset")

	resetTimer: () =>
		if @resetState == 0
			@resetState = 1
			$("#reset_button").addClass("really").text("Really Reset?")
		else
			if @timer?
				@playPause()

			for p in @players
				p.time = 0
				p.lastReset = 0
				$(".time", "#player_panel_#{p.number}").text(@formatTime(p.time - p.lastReset))
				$(".current-time", "#player_panel_#{p.number}").text(@formatTime(p.time))

			@resetResetState()


	pageChange: (path)->
		console.log "page change", path

# -------------------

app = new App()
