require "draw"
require "load"
require "logic"


function love.load()
	-- Set game window to full screen mode
	love.window.updateMode(0, 0)

	-- Get the display index the window is currently in and that desktop dimensions
	local _, _, flags = love.window.getMode()
    scr_width, scr_height = love.window.getDesktopDimensions(flags.display)

	-- Open images folder, look for files and save those files' names in imgs_files.
	local my_deck_imgs_files = love.filesystem.getDirectoryItems("images/myDeck")
	local opponent_deck_imgs_files = love.filesystem.getDirectoryItems("images/opponentDeck")

	initialize()

	-- Loop through all files in my_deck_imgs_files, creating a new image for each one and storing the returned data in elements.player.deck table
	for i, file in ipairs(my_deck_imgs_files) do
		local t = {}
		t.img = love.graphics.newImage("images/myDeck/" .. file)
		t.name = file:gsub("%.[^.]+$", "")
		t.on_screen = {}
		elements.player.deck[i] = t
	end

	-- Loop through all files in opponent_deck_imgs_files, creating a new image for each one and storing the returned data in elements.opponent.deck table
	for i, file in ipairs(opponent_deck_imgs_files) do
		local t = {}
		t.img = love.graphics.newImage("images/opponentDeck/" .. file)
		t.name = file:gsub("%.[^.]+$", "")
		t.on_screen = {}
		elements.opponent.deck[i] = t
	end

	for _, p in ipairs(turn.player.all) do
		for line in love.filesystem.lines("text/" .. p .. "_cards.txt") do
			quantity, card_name = line:match("^(%d) (.+)$")
			loadRemaining(quantity, card_name, elements[p].deck)
		end
	end 

	shuffle(elements.player.deck)
	shuffle(elements.opponent.deck)
	timer = 0
	turn.phase.current = 1
	turn.player.current = 1
	for _, p in ipairs(turn.player.all) do
		for i = 1, 3, 1 do
			table.insert(elements[p].hand, elements[p].deck[1])
			table.remove(elements[p].deck, 1)
		end
	end
end

function love.update(dt)
	timer = timer + dt

	if timer > 2 then
		if turn.phase.current == 1 then
			if #elements[turn.player.all[turn.player.current]].deck >= 1 and turn.round > 0 then
				for i = 1, 2, 1 do
					table.insert(elements[turn.player.all[turn.player.current]].hand, elements[turn.player.all[turn.player.current]].deck[1])
					table.remove(elements[turn.player.all[turn.player.current]].deck, 1)
				end
			end
			
			if global[turn.player.all[turn.player.current]].conditions.burning and global[turn.player.all[turn.player.current]].conditions.burning >= 1 then
				global[turn.player.all[turn.player.current]].hp = global[turn.player.all[turn.player.current]].hp - global[turn.player.all[turn.player.current]].conditions.burning
				global[turn.player.all[turn.player.current]].conditions.burning = global[turn.player.all[turn.player.current]].conditions.burning - 1
			end

			advanceTracker(turn.phase)
			timer = 0
		end

		if turn.phase.current == 3 then
			if turn.player.current == 2 then
				turn.round = turn.round + 1
			end
			advanceTracker(turn.player)
			advanceTracker(turn.phase)
			timer = 0
		end

		if turn.phase.current == 2 and turn.player.current == 2 then
			if #elements.opponent.hand >= 1 and not in_play.card then
				in_play.card, in_play.time = elements.opponent.hand[1], timer
				table.remove(elements.opponent.hand, 1)
			end

			if next(elements.opponent.hand) == nil and not in_play.card then
				advanceTracker(turn.phase)
				timer = 0
			end
		end
	end

	if in_play.card then
		if timer > in_play.time + 2 then
			require("effects." .. in_play.card.name)
			cardEffect()
			package.loaded["effects." .. in_play.card.name] = nil
			table.insert(elements[turn.player.all[turn.player.current]].discard, in_play.card)
			in_play.card, in_play.time = nil, nil
		end
	end

	if game.current == game.all.play then
		for card, table in ipairs(elements.player.hand) do
			local mouse_x, mouse_y = love.mouse.getPosition()
			local img_width, img_height = table.img:getDimensions()
			local check = table.on_screen.y or -(img_height / 2) * player_hand_scaling + scr_height
			table.on_screen.w = img_width * player_hand_scaling
			table.on_screen.h = img_height * player_hand_scaling
			table.on_screen.x = (img_width * (card - 1) - (img_width / 2) * #elements.player.hand) * player_hand_scaling + scr_width / 2
			if mouse_x > table.on_screen.x and mouse_x < table.on_screen.x + table.on_screen.w and mouse_y > check and mouse_y < check + table.on_screen.h then
				table.on_screen.y = -img_height * player_hand_scaling + scr_height
			else
				table.on_screen.y = -(img_height / 2) * player_hand_scaling + scr_height
			end
		end

		if global.opponent.hp <= 0 then
			game.current = game.all.victory
		elseif global.player.hp <= 0 then
			game.current = game.all.defeat
		end
	end
end

function love.draw()
	drawBackground()
	if game.current == game.all.play then
		drawTurn()
		drawPhase()
		drawBoard()
		drawSheets()
		drawMyBars()
		drawOpponentBars()
		drawTokens()
		drawMyDeck()
		drawOpponentDeck()
		drawMyDiscard()
		drawPass()
		drawMyHand()
		drawOpponentHand()
		if in_play.card then drawCardInPlay() end
	elseif game.current == game.all.victory then
		drawVictory()
	elseif game.current == game.all.defeat then
		drawDefeat()
	end
end

function love.mousepressed(x, y, button, istouch)
	if turn.phase.current == 2 and turn.player.current == 1 then
		for i, card in ipairs(elements.player.hand) do 
			if button == 1 and x > card.on_screen.x and x < card.on_screen.x + card.on_screen.w and y > card.on_screen.y and y < card.on_screen.y + card.on_screen.h and not in_play.card then
				card.on_screen = {}
				in_play.card, in_play.time = card, timer
				table.remove(elements.player.hand, i)
			end
		end

		if button == 1 and x > pass.on_screen.x and x < pass.on_screen.x + pass.on_screen.w and y > pass.on_screen.y and y < pass.on_screen.y + pass.on_screen.h then
			pass.state = "pressed"
		end
	end
 end

 function love.mousereleased(x, y, button, istouch, presses)
	if turn.phase.current == 2 and turn.player.current == 1 then
		if pass.state == "pressed" then pass.state = "normal" end

		if button == 1 and x > pass.on_screen.x and x < pass.on_screen.x + pass.on_screen.w and y > pass.on_screen.y and y < pass.on_screen.y + pass.on_screen.h then
			advanceTracker(turn.phase)
			timer = 0
		end
	end
 end

 function love.keypressed(k)
	-- Close the game window if Esc is pressed
	if k == 'escape' then
	   love.event.quit()
	end
 end