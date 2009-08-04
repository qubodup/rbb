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
	
	-- Keys
	keydown = {
		up    = false,
		down  = false,
		left  = false,
		right = false,
		space = false,
	}
	-- Image loading
	images = {
		plane = {
			left = love.graphics.newImage("plane_left.png"),
			right = love.graphics.newImage("plane_left.png"),
			up = love.graphics.newImage("plane_up.png"),
			down = love.graphics.newImage("plane_down.png"),
		},
		soldier = {
			left = love.graphics.newImage("soldier_left.png"),
			right = love.graphics.newImage("soldier_right.png"),
			up = love.graphics.newImage("soldier_up.png"),
			down = love.graphics.newImage("soldier_down.png"),
		},
		tank = {
			left = love.graphics.newImage("tank_left.png"),
			right = love.graphics.newImage("tank_right.png"),
			up = love.graphics.newImage("tank_up.png"),
			down = love.graphics.newImage("tank_down.png"),
		},
		bull = {
			left = love.graphics.newImage("bull_left.png"),
			right = love.graphics.newImage("bull_right.png"),
			up = love.graphics.newImage("bull_up.png"),
			down = love.graphics.newImage("bull_down.png"),
		}
	}

	-- Animation baking
	animations = {
		plane = {
		},
		soldier = {
			left = love.graphics.newAnimation(images.soldier.left, 8, 8, 0.120),
			right = love.graphics.newAnimation(images.soldier.right, 8, 8, 0.120),
			up = love.graphics.newAnimation(images.soldier.up, 8, 8, 0.120),
			down = love.graphics.newAnimation(images.soldier.down, 8, 8, 0.120),
		},
		bull =  {
			left = love.graphics.newAnimation(images.bull.left, 8, 8, 0.120)
		},
	}	

	-- Parameters for customizing the game
	conf = {
		screen = {800, 600}, -- Screen resolution
		amount_soldiers = 50,
		amount_tanks = 25,
		reload_time_needed = 1, -- Time between shots
		reload_time = 0, -- Time since last shot
	}
	
	-- Units
	soldiers = {}
	for i = 1,conf.amount_soldiers do
		soldiers[i] = {
			coords = { math.random( 10, conf.screen[1] - 10 ), math.random( conf.screen[2]/2 + 10, conf.screen[2] - 10 ) },
			direction = { math.random()*2-1, math.random()*2-1 },
			speed = 10,
		}
	end

	tanks = {}
	for i = 1,conf.amount_tanks do
		tanks[i] = {
			coords = { math.random( 10, conf.screen[1] - 10 ), math.random( conf.screen[2]/2 + 10, conf.screen[2] - 10 ) },
			direction = { math.random()*2-1, math.random()*2-1 },
			speed = 10,
		}
	end
	-- Player and bulls
	player = {
		coords		= {conf.screen[1]/2, conf.screen[2]/4},
        direction	= {1,0},
        speed		= 100,
	}
	

	bulls = {}
	
end


function enemy_update(dt)

	animations.soldier.left:update(dt)

	for u,v in pairs(soldiers) do
	
		v.coords[1] = v.coords[1] + v.direction[1] * v.speed * dt
		v.coords[2] = v.coords[2] + v.direction[2] * v.speed * dt

		-- border
		if v.coords[1] > conf.screen[1] - 10 then
			v.direction[1] = -1
		end
		if v.coords[1] <  10 then
			v.direction[1] = 1
		end
		if v.coords[2] > conf.screen[2] - 10 then
			v.direction[2] = -1
		end
		if v.coords[2] < conf.screen[2]/2 + 10 then
			v.direction[2] = 1
		end
	end
end

function update(dt)
	player_update(dt)
	enemy_update(dt)
	bulls_update(dt)
end

function bulls_update(delta)
	
	animations.bull.left:update(delta)

	-- Dropping new bulls
	if keydown.space == true and conf.reload_time > 1 then
		create_bull()
		conf.reload_time = 0
	end

	for u,v in pairs(bulls) do
		for w,x in pairs(soldiers) do
			if x.coords[1] <= v.coords[1] + 4 and x.coords[1] >= v.coords[1] - 4 and x.coords[2] <= v.coords[2] + 4 and x.coords[2] >= v.coords[2] - 4 and v.running == true then
				soldier_kill(w)
			end
			-- Bull landing (start running)
			if v.coords[2] >= v.aim and v.running == false then
				v.coords[2] = v.aim
				v.running = true
				love.audio.play(sounds.moo)
			end
		end
		if v.running == true then
			v.coords[1] = v.coords[1] - delta*v.speed
			v.speed = v.speed + .5
		else v.coords[2] = v.coords[2] + delta*v.fallspeed
		end
		if v.coords[1] < -10 then
			table.remove(bulls,u)
		end
	end
	if conf.reload_time <= 1 then
		conf.reload_time = conf.reload_time + delta
	end
end

function create_bull()
	bulls[#bulls+1] = {
		coords = { player.coords[1], player.coords[2] },
		direction = { -1},
		speed = 40,
		fallspeed = 200,
		running = false,
		aim = player.coords[2] + conf.screen[2]/2,
	}
end

function player_update(dt)
	if  keydown.right == true and player.coords[1] < conf.screen[1]-10 then player.coords[1] = player.coords[1] + dt * player.speed end
	if  keydown.left  == true and player.coords[1] >  10 then player.coords[1] = player.coords[1] - dt * player.speed end
	if  keydown.up    == true and player.coords[2] >  10 then player.coords[2] = player.coords[2] - dt * player.speed end
	if  keydown.down  == true and player.coords[2] < conf.screen[2]/2 - 10 then player.coords[2] = player.coords[2] + dt * player.speed end
end

function draw()
	
	-- Text
	love.graphics.setFont(fonts.big)
	love.graphics.setColor(colors.white)
	love.graphics.draw("Rouge Bull Bombardment!", 64, 64)
	love.graphics.setFont(fonts.small)
	love.graphics.draw("Arrwos & Space to Bombard!\nScore: " .. score, 64, 96)
	love.graphics.setFont(fonts.tiny)
	love.graphics.draw("Soldier, tank & plane by clasic_traveller_diehard (cc0/pd)\
PixAntiqua font by Gerhard Grossmann (ofl)\
Code, sounds & bull by qubodup (cc0/pd)\
March music by c418 (sa3+)\
", 396, 88)
	-- ofl is open font license
	-- cc0/pd is creative commons zero/public domain
	-- sa3+ is creative commons attributioon-sharealike 3.0 or later
	
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
	for v,u in pairs(soldiers) do
		love.graphics.draw(animations.soldier.left, math.floor(u.coords[1] + 4), math.floor(u.coords[2] + 4))
	end
	
	-- Bulls
	for v,u in pairs(bulls) do
		love.graphics.draw(animations.bull.left, math.floor(u.coords[1] + 4), math.floor(u.coords[2] + 4))
	end
	
end

function soldier_kill(soldier)
	score = score + 1
	love.audio.play(sounds.ouch)
	table.remove(soldiers,soldier)
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
