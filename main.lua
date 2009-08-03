 --[[  Rouge Bull Bombardment

   Copyright (C) 2009 Iwan Gabovitch

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

]]--

function load()

	-- Resolution
	screen = {800, 600}

	-- Colors
	colors = {
		white = love.graphics.newColor(222,222,222),
		black = love.graphics.newColor(051,051,051),
		green = love.graphics.newColor(070,210,010),
		blue  = love.graphics.newColor(010,170,245),
	}
	
	love.graphics.setBackgroundColor(colors.blue)
	
	-- Audio system
	love.audio.setChannels(16)
	love.audio.setVolume(.3)
	
	-- Sounds
	
	sounds = {
		moo  = love.audio.newSound("moo2.wav"),
		ouch = love.audio.newSound("ouch2.wav")
	}
	
	-- Score
	score = 0
	
	-- Sound
	
	music = love.audio.newMusic("march.ogg")
	love.audio.play(music, 0)
	
	-- Font
	
	fonts = {
		big = love.graphics.newFont("PixAntiqua.ttf",48),
		small = love.graphics.newFont("PixAntiqua.ttf",24),
		tiny = love.graphics.newFont("PixAntiqua.ttf",12),
	}
	
	-- Entities
	
	player = {
		coords		= {320,240},
        direction	= {1,0},
        speed		= 100,
        spritesize	= { 17, 33 },
	}
	
	-- Keys
	keydown = {
		up    = false,
		down  = false,
		left  = false,
		right = false,
		space = false,
	}
	
	images = {
		plane = {
			left = love.graphics.newImage("plane_left.png"),
			right = love.graphics.newImage("plane_left.png"),
			up = love.graphics.newImage("plane_up.png"),
			down = love.graphics.newImage("plane_down.png"),
		},
		soldier = {
			left = love.graphics.newImage("soldier_left.png")
		},
		bull = {
			left = love.graphics.newImage("bull_left.png")
		}
	}
	
	animations = {
		plane = {
		},
		soldier = {
			left = love.graphics.newAnimation(images.soldier.left, 8, 8, 0.120)
		},
		bull =  {
			left = love.graphics.newAnimation(images.bull.left, 8, 8, 0.120)
		},
	}
	
	soldier_count = 50

	soldiers = {}
	for i = 1,soldier_count do
		soldiers[i] = {
			coords = { math.random( 10, screen[1] - 10 ), math.random( screen[2]/2 + 10, screen[2] - 10 ) },
			direction = { math.random()*2-1, math.random()*2-1 },
			speed = 10,
			dead = false,
		}
	end
	
	bulls = {}
	reload = 1
end


function enemy_update(dt)

	animations.soldier.left:update(dt)

	for i=1,#soldiers do
	
		for i=1,#bulls do
			if soldiers[i].coords[1] == bulls[i].coords[1] and bulls[i].running == true then soldier_kill(i) end
		end

		soldiers[i].coords[1] = soldiers[i].coords[1] + soldiers[i].direction[1] * soldiers[i].speed * dt
		soldiers[i].coords[2] = soldiers[i].coords[2] + soldiers[i].direction[2] * soldiers[i].speed * dt

		-- border
		if soldiers[i].coords[1] > 790 then
			soldiers[i].direction[1] = -1
		end
		if soldiers[i].coords[1] <  10 then
			soldiers[i].direction[1] = 1
		end
		if soldiers[i].coords[2] > 590 then
			soldiers[i].direction[2] = -1
		end
		if soldiers[i].coords[2] < 310 then
			soldiers[i].direction[2] = 1
		end
	end
end

function update(dt)
	player_update(dt)
	enemy_update(dt)
	bulls_update(dt)
end

function bulls_update(dt)

	animations.bull.left:update(dt)

	if keydown.space == true and reload > 1 then
		create_bull()
		reload = 0
		love.audio.play(sounds.moo)
	end
	for i,f in pairs(bulls) do
		for j=1, #soldiers do
			if soldiers[j].coords[1] <= bulls[i].coords[1] + 4 and soldiers[j].coords[1] >= bulls[i].coords[1] - 4 and soldiers[j].coords[2] <= bulls[i].coords[2] + 4 and soldiers[j].coords[2] >= bulls[i].coords[2] - 4 and bulls[i].running == true then
				soldier_kill(j)
			end
			if bulls[i].coords[2] <= bulls[i].aim then
				bulls[i].coords[2] = bulls[i].aim
				bulls[i].running = true
			end
		end
		if bulls[i].running == true then
			bulls[i].coords[1] = bulls[i].coords[1] - dt*bulls[i].speed
			bulls[i].speed = bulls[i].speed + .5
		else bulls[i].coords[2] = bulls[i].coords[2] - dt.bulls[i].fallspeed
		end
		if bulls[i].coords[1] < -10 then
			table.remove(bulls,i)
		end
	end
	if reload <= 1 then
		reload = reload + dt
	end
end

function create_bull()
	num = #bulls + 1
	bulls[num] = {
			coords = { player.coords[1], player.coords[2] },
			direction = { -1},
			speed = 40,
			fallspeed = 80,
			running = false,
			aim = player.coords[2]+300,
		}
end

function player_update(dt)
	if  keydown.right == true and player.coords[1] < 790 then player.coords[1] = player.coords[1] + dt * player.speed end
	if  keydown.left  == true and player.coords[1] >  10 then player.coords[1] = player.coords[1] - dt * player.speed end
	if  keydown.up    == true and player.coords[2] >  10 then player.coords[2] = player.coords[2] - dt * player.speed end
	if  keydown.down  == true and player.coords[2] < 290 then player.coords[2] = player.coords[2] + dt * player.speed end
end

function draw()
	
	-- Text
	love.graphics.setFont(fonts.big)
	love.graphics.setColor(colors.white)
	love.graphics.draw("Rouge Bull Bombardment!", 64, 64)
	love.graphics.setFont(fonts.small)
	love.graphics.draw("Arrwos & Space to Bombard!\nScore: " .. score, 64, 96)
	love.graphics.setFont(fonts.tiny)
	love.graphics.draw("Soldier & tank by clasic_traveller_diehard (cc0/pd)\
PixAntiqua font by Gerhard Grossmann (ofl)\
Code, sounds & bull by qubodup (cc0/pd)\
March music by c418 (??)\
", 396, 88)
	
	-- Ground
	love.graphics.setColor(colors.green)
	love.graphics.rectangle(0, 0, 300, 800, 300)
	
	-- Aim line
	love.graphics.setColor(colors.white)
	love.graphics.rectangle(0, 0, player.coords[2]+300, player.coords[1], 8)
	
	-- Plane
	if player.direction[1] == 1 then
		love.graphics.draw(images.plane.right, math.floor(player.coords[1]), math.floor(player.coords[2]))
	elseif player.direction[1] == -1 then 
		love.graphics.draw(images.plane.left, math.floor(player.coords[1]), math.floor(player.coords[2]))
	elseif player.direction[2] == -1 then
		love.graphics.draw(images.plane.up, math.floor(player.coords[1]), math.floor(player.coords[2]))
	elseif player.direction[2] == 1 then
		love.graphics.draw(images.plane.down, math.floor(player.coords[1]), math.floor(player.coords[2]))
	end
	
	-- Soldiers
	for i=1,#soldiers do
		if soldiers[i].dead == false then love.graphics.draw(animations.soldier.left, math.floor(soldiers[i].coords[1] + 4), math.floor(soldiers[i].coords[2] + 4)) end
	end
	
	-- Bulls
	for i=1,#bulls do
		love.graphics.draw(animations.bull.left, math.floor(bulls[i].coords[1] + 4), math.floor(bulls[i].coords[2] + 4))
	end
	
end

function soldier_kill(i)
	if soldiers[i].dead == false then
		score = score + 1
		love.audio.play(sounds.ouch)
	end
	soldiers[i].dead = true
end

function keypressed(key)
	if     key == love.key_up     then
		keydown.up    = true
		player.direction[2] = -1
	elseif key == love.key_down   then
		keydown.down  = true
		player.direction[2] = 1
	elseif key == love.key_left   then
		keydown.left  = true
		player.direction[1] = -1
	elseif key == love.key_right  then
		keydown.right = true
		player.direction[1] = 1
	elseif key == love.key_space  then keydown.space = true
	elseif key == love.key_escape then love.system.exit() end
end

function keyreleased(key)
	if     key == love.key_up    then keydown.up    = false
	elseif key == love.key_down  then keydown.down  = false
	elseif key == love.key_left  then keydown.left  = false
	elseif key == love.key_right then keydown.right = false
	elseif key == love.key_space then keydown.space = false end
end
