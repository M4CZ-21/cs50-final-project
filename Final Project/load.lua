function initialize()
	-- Get background image and set its variables
	background = love.graphics.newImage("images/background.png")
	background_width, background_height = background:getDimensions()

	-- Get board image and set its variables
	board = love.graphics.newImage("images/board.png")
	board_width, board_height = board:getDimensions()
	board_scaling = 0.3

	-- Get card backing image and set its variables
	my_card_backing = love.graphics.newImage("images/my_backing.png")
	opponent_card_backing = love.graphics.newImage("images/opponent_backing.png")
	backing_width, backing_height = my_card_backing:getDimensions()

	-- Get sheet image and set its variables
	sheet = love.graphics.newImage("images/sheet.png")
	sheet_width, sheet_height = sheet:getDimensions()

	-- Get token images
	my_token = love.graphics.newImage("images/tokens/mage.png")
	opponent_token = love.graphics.newImage("images/tokens/goblin.png")

	-- Get victory/defeat images
	victory, defeat = {}, {}
	victory.img = love.graphics.newImage("images/victory.png")
	victory.width, victory.height = victory.img:getWidth(), victory.img:getHeight()
	defeat.img = love.graphics.newImage("images/defeat.png")
	defeat.width, defeat.height = defeat.img:getWidth(), defeat.img:getHeight()

	-- Get pass turn button image
	pass = {}
	pass.img, pass.on_screen, pass.quad, pass.state = love.graphics.newImage("images/pass.png"), {}, {}, "normal"
	pass.on_screen.w, pass.on_screen.h = pass.img:getWidth(), pass.img:getHeight()
	pass.on_screen.x, pass.on_screen.y = scr_width / 2 + board_width * board_scaling / 2, scr_height / 2
	pass.quad.normal = love.graphics.newQuad(0, 0, pass.on_screen.w, pass.on_screen.h / 2, pass.on_screen.w, pass.on_screen.h)
	pass.quad.pressed = love.graphics.newQuad(0, pass.on_screen.h / 2, pass.on_screen.w, pass.on_screen.h / 2, pass.on_screen.w, pass.on_screen.h)

	-- Set element specifications 
    deck_position = {x = 40, y = 710}
    sheet_position = {x = 540, y = 40}
    discard_position = {x = 1960, y = 710}
    exile_position = {x = 2460, y = 710}
    char_token = {x = 620, y = 120}
    hp_token = {x = 1456, y = 1108, img = love.graphics.newImage("images/tokens/hp.png")}
    mp_token = {x = 1688, y = 1108, img = love.graphics.newImage("images/tokens/mp.png")}
	token_width, token_height = hp_token.img:getDimensions()
    hp_bar = {x = 1502, y = 200, w = 100, h = 868}
    mp_bar = {x = 1735, y = 200, w = 100, h = 868}

	-- Create a table to keep track of the game state
	game = {}
	game.all, game.current = {menu = "menu", play = "play", victory = "victory", defeat = "defeat"}, "play"

	-- Create a table to keep track of what card is being played currently
	in_play = {}
	in_play.card, in_play.time = nil, nil

	-- Create a table to keep track of what phase the game is currently in
	turn = {}
	turn.phase, turn.player, turn.round = {}, {}, 0
	turn.phase.current, turn.phase.all = nil, {"draw", "action", "end"}
	turn.phase.img, turn.phase.on_screen, turn.phase.quad = love.graphics.newImage("images/phases.png"), {}, {}
	turn.phase.on_screen.w, turn.phase.on_screen.h = turn.phase.img:getWidth(), turn.phase.img:getHeight()
	turn.phase.on_screen.x, turn.phase.on_screen.y = scr_width / 2 - board_width * board_scaling / 2 - turn.phase.on_screen.w, scr_height / 2
	turn.phase.quad.draw = love.graphics.newQuad(0, 0, turn.phase.on_screen.w, turn.phase.on_screen.h / 3, turn.phase.on_screen.w, turn.phase.on_screen.h)
	turn.phase.quad.action = love.graphics.newQuad(0, turn.phase.on_screen.h / 3, turn.phase.on_screen.w, turn.phase.on_screen.h / 3, turn.phase.on_screen.w, turn.phase.on_screen.h)
	turn.phase.quad["end"] = love.graphics.newQuad(0, turn.phase.on_screen.h * 2 / 3, turn.phase.on_screen.w, turn.phase.on_screen.h / 3, turn.phase.on_screen.w, turn.phase.on_screen.h)
	turn.player.current, turn.player.all = nil, {"player", "opponent"}
	turn.player.img, turn.player.on_screen, turn.player.quad = love.graphics.newImage("images/turns.png"), {}, {}
	turn.player.on_screen.w, turn.player.on_screen.h = turn.player.img:getWidth(), turn.player.img:getHeight()
	turn.player.on_screen.x, turn.player.on_screen.y = scr_width / 2 - board_width * board_scaling / 2 - turn.player.on_screen.w / 2, scr_height / 2
	turn.player.quad.player = love.graphics.newQuad(0, 0, turn.player.on_screen.w / 2, turn.player.on_screen.h, turn.player.on_screen.w, turn.player.on_screen.h)
	turn.player.quad.opponent = love.graphics.newQuad(turn.player.on_screen.w / 2, 0, turn.player.on_screen.w / 2, turn.player.on_screen.h, turn.player.on_screen.w, turn.player.on_screen.h)

	-- Create a table for each group of cards in the game
	elements = {}
	elements.player, elements.opponent = {}, {}
	elements.player.deck, elements.player.hand, elements.player.discard, elements.player.exile = {}, {}, {}, {}
	elements.opponent.deck, elements.opponent.hand, elements.opponent.discard, elements.opponent.exile = {}, {}, {}, {}

	-- Create a table to keep track of each relevant info about the player/opponent
	global = {}
	global.player, global.opponent, global.conditions = {}, {}, {}
	global.player.max_hp, global.player.max_mp, global.player.hp, global.player.mp, global.player.conditions = 10, 10, 10, 10, {}
	global.opponent.max_hp, global.opponent.max_mp, global.opponent.hp, global.opponent.mp, global.opponent.conditions = 12, 2, 12, 0, {}

	player_hand_scaling = 0.5
	opponent_hand_scaling = 0.4
end

function loadCondition(condition)
	global.conditions[condition] = love.graphics.newImage("images/tokens/conditions/" .. condition .. ".png")
end

function shuffle(t)
    for i = 1, #t - 1 do
        local r = love.math.random(i, #t)
        t[i], t[r] = t[r], t[i]
    end
end

function loadRemaining(quantity, card_name, deck)
	local c, quantity = 0, tonumber(quantity)
	local t = {}
	for _, card in pairs(deck) do
		if card.name == card_name then
			t.name, t.img, t.on_screen = card.name, card.img, {}
			c = c + 1
		end
	end
	while c < quantity do
		table.insert(deck, love.math.random(#deck), t)
		c = c + 1
	end
end

function advanceTracker(table)
	table.current = table.current % #table.all + 1
end