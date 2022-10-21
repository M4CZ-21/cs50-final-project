function drawBackground()
	love.graphics.push()

	-- Set origin to the middle of the screen
	love.graphics.translate(scr_width / 2, scr_height / 2)

	-- Fill the whole screen with the background image
	local scaling = math.max(scr_width / background_width, scr_height / background_height)
	love.graphics.draw(background, (-background_width * scaling) / 2, (-background_height * scaling) / 2, 0, scaling, scaling)

	love.graphics.pop()
end

function drawBoard()
	love.graphics.push()

	-- Set origin to the middle of the screen
	love.graphics.translate(scr_width / 2, scr_height / 2)

	-- Draw the board image
	local position = {x = -(board_width / 2) * board_scaling, y = 0}
	love.graphics.draw(board, position.x, position.y, 0, board_scaling, board_scaling)
	love.graphics.draw(board, position.x, position.y, 0, -board_scaling, -board_scaling, board_width)

	love.graphics.pop()
end

function drawSheets()
	love.graphics.push()

	-- Set origin to the middle of the screen
	love.graphics.translate(scr_width / 2, scr_height / 2)

	-- Draw the sheet image
	local position = {x = -(board_width / 2) * board_scaling + sheet_position.x * board_scaling, y = sheet_position.y * board_scaling}
	love.graphics.draw(sheet, position.x, position.y, 0, board_scaling, board_scaling)
	love.graphics.draw(sheet, -position.x, -position.y, 0, -board_scaling, -board_scaling)

	love.graphics.pop()
end

function drawTokens()
	love.graphics.push()

	-- Set origin to the middle of the screen
	love.graphics.translate(scr_width / 2, scr_height / 2)

	-- Set each token's position
	local position = {}
	position.char = {x = (char_token.x - board_width / 2) * board_scaling, y = char_token.y * board_scaling}
	position.hp = {x = (hp_token.x - board_width / 2) * board_scaling, y = hp_token.y * board_scaling}
	position.mp = {x = (mp_token.x - board_width / 2) * board_scaling, y = mp_token.y * board_scaling}

	-- Draw character tokens
	love.graphics.draw(my_token, position.char.x, position.char.y, 0, board_scaling, board_scaling)
	love.graphics.draw(opponent_token, -position.char.x, -position.char.y, 0, -board_scaling, -board_scaling)
	
	-- Draw HP tokens
	love.graphics.draw(hp_token.img, position.hp.x, position.hp.y, 0, board_scaling, board_scaling)
	love.graphics.draw(hp_token.img, -position.hp.x, -position.hp.y, 0, -board_scaling, -board_scaling)
	
	-- Draw MP tokens
	love.graphics.draw(mp_token.img, position.mp.x, position.mp.y, 0, board_scaling, board_scaling)
	love.graphics.draw(mp_token.img, -position.mp.x, -position.mp.y, 0, -board_scaling, -board_scaling)

	-- Draw the player conditions, if they have any
	if next(global.player.conditions) ~= nil then
		position.condition = {x = (char_token.x - board_width / 2) * board_scaling, y = hp_token.y * board_scaling}
		for condition, counter in pairs(global.player.conditions) and counter >= 1 do
			if counter >= 1 then
				if global.conditions[condition] == nil then
					loadCondition(condition)
				end
				love.graphics.draw(global.conditions[condition], position.condition.x, position.condition.y, 0, board_scaling, board_scaling)
				love.graphics.print(counter, position.condition.x, position.condition.y, 0, 1.5, 1.5)
				position.condition.x = position.condition.x + token_width * 1.2 * board_scaling
			end
		end
	end

	-- Draw the opponent conditions, if they have any
	if next(global.opponent.conditions) ~= nil then
		position.condition = {x = -(char_token.x - board_width / 2) * board_scaling, y = -hp_token.y * board_scaling}
		for condition, counter in pairs(global.opponent.conditions) do
			if counter >= 1 then
				if global.conditions[condition] == nil then
					loadCondition(condition)
				end
				love.graphics.draw(global.conditions[condition], position.condition.x, position.condition.y, 0, -board_scaling, -board_scaling)
				love.graphics.print(counter, position.condition.x, position.condition.y, 0, -1.5, -1.5)
				position.condition.x = position.condition.x - token_width * 1.2 * board_scaling
			end
		end
	end

	love.graphics.pop()
end

function drawMyHand()
	-- Loop through all cards in elements.player.hand
	for card, table in ipairs(elements.player.hand) do
		-- Check if the current card already has a position
		if next(table.on_screen) ~= nil then
			love.graphics.draw(table.img, table.on_screen.x, table.on_screen.y, 0, player_hand_scaling, player_hand_scaling)
		end
	end
end

function drawOpponentHand()
	love.graphics.push()

	-- Set origin to top mid of the screen
	love.graphics.translate(scr_width / 2, 0)

	-- Draw cards in elements.opponent.hand table
	for card, table in ipairs(elements.opponent.hand) do
		local scaling = 0.4
		local position = {x = (backing_width * (card - 1) - (backing_width / 2) * #elements.opponent.hand) * scaling, y = -(backing_height / 2) * scaling}
		love.graphics.draw(opponent_card_backing, position.x, position.y, 0, -scaling, -scaling, backing_width, backing_height)
	end

	love.graphics.pop()
end

function drawMyDeck()
	-- Draw cards in elements.opponent.hand table
	if #elements.player.deck >= 1 then
		love.graphics.push()
	
		-- Set origin to the middle of the screen
		love.graphics.translate(scr_width / 2, scr_height / 2)
	
		local position = {x = (-(board_width / 2) + deck_position.x) * board_scaling, y = deck_position.y * board_scaling}
		love.graphics.draw(my_card_backing, position.x, position.y, 0, board_scaling, board_scaling)

		love.graphics.pop()
	end
end

function drawOpponentDeck()
	-- Draw cards in elements.opponent.hand table
	if #elements.opponent.deck >= 1 then
		love.graphics.push()
	
		-- Set origin to the middle of the screen
		love.graphics.translate(scr_width / 2, scr_height / 2)
	
		local position = {x = (-(board_width / 2) + deck_position.x) * board_scaling, y = deck_position.y * board_scaling}
		love.graphics.draw(opponent_card_backing, -position.x, -position.y, 0, -board_scaling, -board_scaling)

		love.graphics.pop()
	end
end

function drawMyBars()
	love.graphics.push('all')

	-- Set origin to the top left of the board
	love.graphics.translate(scr_width / 2 - board_width * board_scaling / 2, scr_height / 2)
	
	-- Draw HP bar
	local missing_hp_bar = {x = hp_bar.x * board_scaling, y = hp_bar.y * board_scaling, w = hp_bar.w * board_scaling, h = hp_bar.h * board_scaling * (global.player.max_hp - global.player.hp) / global.player.max_hp}
	local current_hp_bar = {x = hp_bar.x * board_scaling, y = hp_bar.y * board_scaling + missing_hp_bar.h, w = hp_bar.w * board_scaling, h = hp_bar.h * board_scaling * global.player.hp / global.player.max_hp}
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', missing_hp_bar.x, missing_hp_bar.y, missing_hp_bar.w, missing_hp_bar.h)
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle('fill', current_hp_bar.x, current_hp_bar.y, current_hp_bar.w, current_hp_bar.h)
	
	-- Draw MP bar
	local missing_mp_bar = {x = mp_bar.x * board_scaling, y = mp_bar.y * board_scaling, w = mp_bar.w * board_scaling, h = mp_bar.h * board_scaling * (global.player.max_mp - global.player.mp) / global.player.max_mp}
	local current_mp_bar = {x = mp_bar.x * board_scaling, y = mp_bar.y * board_scaling + missing_mp_bar.h, w = mp_bar.w * board_scaling, h = mp_bar.h * board_scaling * global.player.mp / global.player.max_mp}
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', missing_mp_bar.x, missing_mp_bar.y, missing_mp_bar.w, missing_mp_bar.h)
	love.graphics.setColor(0, 0, 1)
	love.graphics.rectangle('fill', current_mp_bar.x, current_mp_bar.y, current_mp_bar.w, current_mp_bar.h)

	love.graphics.pop()
end

function drawOpponentBars()
	love.graphics.push('all')

	-- Set origin to the top left of the board
	love.graphics.translate(scr_width / 2 + board_width * board_scaling / 2, scr_height / 2)
	
	-- Draw HP bar
	local missing_hp_bar = {x = hp_bar.x * board_scaling, y = hp_bar.y * board_scaling, w = hp_bar.w * board_scaling, h = hp_bar.h * board_scaling * (global.opponent.max_hp - global.opponent.hp) / global.opponent.max_hp}
	local current_hp_bar = {x = hp_bar.x * board_scaling, y = hp_bar.y * board_scaling + missing_hp_bar.h, w = hp_bar.w * board_scaling, h = hp_bar.h * board_scaling * global.opponent.hp / global.opponent.max_hp}
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', -missing_hp_bar.x, -missing_hp_bar.y, -missing_hp_bar.w, -missing_hp_bar.h)
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle('fill', -current_hp_bar.x, -current_hp_bar.y, -current_hp_bar.w, -current_hp_bar.h)
	
	-- Draw MP bar
	local missing_mp_bar = {x = mp_bar.x * board_scaling, y = mp_bar.y * board_scaling, w = mp_bar.w * board_scaling, h = mp_bar.h * board_scaling * (global.opponent.max_mp - global.opponent.mp) / global.opponent.max_mp}
	local current_mp_bar = {x = mp_bar.x * board_scaling, y = mp_bar.y * board_scaling + missing_mp_bar.h, w = mp_bar.w * board_scaling, h = mp_bar.h * board_scaling * global.opponent.mp / global.opponent.max_mp}
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', -missing_mp_bar.x, -missing_mp_bar.y, -missing_mp_bar.w, -missing_mp_bar.h)
	love.graphics.setColor(0, 0, 1)
	love.graphics.rectangle('fill', -current_mp_bar.x, -current_mp_bar.y, -current_mp_bar.w, -current_mp_bar.h)

	love.graphics.pop()
end

function drawCardInPlay()
	local img_width, img_height = in_play.card.img:getDimensions()
	love.graphics.draw(in_play.card.img, scr_width / 2 - img_width / 2, scr_height / 2 - img_height / 2, 0)
end

function drawMyDiscard()
	-- Draw cards in elements.player.discard table
	if #elements.player.discard >= 1 then
		love.graphics.push()
	
		-- Set origin to the middle of the screen
		love.graphics.translate(scr_width / 2, scr_height / 2)
	
		local position = {x = (-(board_width / 2) + discard_position.x) * board_scaling, y = discard_position.y * board_scaling}
		love.graphics.draw(elements.player.discard[#elements.player.discard].img, position.x, position.y, 0, board_scaling, board_scaling)

		love.graphics.pop()
	end
end

function drawOpponentDiscard()
	-- Draw cards in elements.opponent.discard table
	if #elements.opponent.deck >= 1 then
		love.graphics.push()
	
		-- Set origin to the middle of the screen
		love.graphics.translate(scr_width / 2, scr_height / 2)
	
		local position = {x = (-(board_width / 2) + discard_position.x) * board_scaling, y = discard_position.y * board_scaling}
		love.graphics.draw(elements.opponent.discard[#elements.opponent.discard].img, -position.x, -position.y, 0, -board_scaling, -board_scaling)

		love.graphics.pop()
	end
end

function drawPass()
	love.graphics.draw(pass.img, pass.quad[pass.state], pass.on_screen.x, pass.on_screen.y)
end

function drawTurn()
	love.graphics.draw(turn.player.img, turn.player.quad[turn.player.all[turn.player.current]], turn.player.on_screen.x, turn.player.on_screen.y)
end

function drawPhase()
	love.graphics.draw(turn.phase.img, turn.phase.quad[turn.phase.all[turn.phase.current]], turn.phase.on_screen.x, turn.phase.on_screen.y)
end

function drawVictory()
	love.graphics.draw(victory.img, (scr_width - victory.width) / 2, (scr_height - victory.height) / 2)
end

function drawDefeat()
	love.graphics.draw(defeat.img, (scr_width - defeat.width) / 2, (scr_height - defeat.height) / 2)
end