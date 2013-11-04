--This line will remove the status bar at the top of the screen,
--some apps you might want to keep it in, but not for games!
display.setStatusBar( display.HiddenStatusBar )

local sprite = require("sprite")

--these 2 variables will be the checks that control our event system.
local inEvent = 0
local eventRun = 0
--variable to see whether monster hit ground
local hitGround = 0

--variable to hold our game's score
local score = 0
--scoreText is another variable that holds a string that has the score information
--when we update the score we will always need to update this string as well
--*****Note for android users, you may need to include the file extension of the font
--that you choose here, so it would be BorisBlackBloxx.ttf there *****
local scoreText = display.newText( "score: " .. score, 0, 0, native.systemFont, 50 )
--This is important because if you don't have this line the text will constantly keep
--centering itself rather than aligning itself up neatly along a fixed point
scoreText:setReferencePoint(display.CenterLeftReferencePoint)
scoreText.x = 0
scoreText.y = 30

local player = display.newGroup( )
local screen = display.newGroup( )
--create a new group to hold all of our blocks
local blocks = display.newGroup( )

local ghosts = display.newGroup()
local spikes = display.newGroup()
local blasts = display.newGroup()

local gameOver = display.newImage( "img/gameOver.png" )
gameOver.name = "gameOver"
gameOver.x = 0
gameOver.y = 500

--adds an image to our game centered at x and y coordiantes
local backbackground = display.newImage("img/background.png")
backbackground.x = 240
backbackground.y = 160
local backgroundfar = display.newImage("img/backgroundfar.png")
backgroundfar.x = 480
backgroundfar.y = 160
local backgroundfar2 = display.newImage("img/backgroundfar.png")
backgroundfar.x = 1440
backgroundfar.y = 160
local backgroundnear1 = display.newImage("img/backgroundnear.png")
backgroundnear1.x = 240
backgroundnear1.y = 160
local backgroundnear2 = display.newImage("img/backgroundnear.png")
backgroundnear2.x = 760
backgroundnear2.y = 160


--setup some variables that we will use to position the ground
local groundMin = 420
local groundMax = 340
local groundLevel = groundMin
local speed = 5;

--create ghosts and set their position to be off-screen
for a = 1, 3, 1 do 
	ghost = display.newImage( "img/ghost.png" )
	ghost.name = ("ghost" .. a)
	ghost.id = a 
	ghost.x = 800
	ghost.y = 600
	ghost.speed = 0
	--variable used to determine if they are in play or not
	ghost.isAlive = false
	--make the ghosts transparent and more... ghostlike!
	ghost.alpha = .5 
	ghosts:insert(ghost)
end 
--create spikes
for a = 1, 3, 1 do 
	spike = display.newImage("img/spikeBlock.png")
	spike.name = ("spike" .. a)
	spike.id = a 
	spike.x = 900
	spike.y = 500
	spike.isAlive = false
	spikes:insert(spike)
end 
--create blasts
for a = 1, 3, 1 do 
	blast = display.newImage( "img/blast.png" )
	blast.name = ("blast" .. a)
	blast.id = a 
	blast.x = 800
	blast.y = 500
	blast.isAlive = false 
	blasts:insert(blast)
end 



--create our sprite sheet
local spriteSheet = sprite.newSpriteSheet( "img/monsterSpriteSheet.png", 100, 100 )
local monsterSet = sprite.newSpriteSet(spriteSheet, 1, 7 )
sprite.add(monsterSet, "running", 1, 6, 600, 0)
sprite.add(monsterSet, "jumping", 7, 7, 1, 1 )

--set the different variables we will use for our monster sprite
--also sets and starts the first animation for our monster
local monster = sprite.newSprite( monsterSet )
monster:prepare("running")
monster:play()
monster.x = 110
monster.y = 250
--these are 2 variables that will control the falling and jumping of the monster
monster.gravity = -9
monster.accel = 20
monster.isAlive = true

--rectangle used for our collision detection
--it will always be in front of the monster sprite
--that way we know if the monster hit into anything
local collisionRect = display.newRect(monster.x + 36, monster.y, 1, 70)
collisionRect.strokeWidth = 1
collisionRect:setFillColor(140, 140, 140)
collisionRect:setStrokeColor(180, 180, 180)
collisionRect.alpha = 0

--used to put everything on the screen into the screen group
--this will let us change the order in which sprites appear on
--the screen if we want. The earlier it is put into the group the
--further back it will go
screen:insert(backbackground)
screen:insert(backgroundfar)
screen:insert(backgroundfar2)
screen:insert(backgroundnear1)
screen:insert(backgroundnear2)
screen:insert(blocks)
screen:insert(spikes)
screen:insert(blasts)
screen:insert(ghosts)
screen:insert(monster)
screen:insert(scoreText)
screen:insert(gameOver)
screen:insert(collisionRect)
--this for loop will generate all of your ground pieces, we are going to 
--make 8 in all.
for a = 1, 12, 1 do 
	isDone = false 
	--get a random number between 1 and 2, this is what we will use to decide which
	--texture to use for our ground sprites. Doing this will give us random ground
	--pieces so it seems like the ground goes on forever. You can have as many
	--textures as you want. The more you have the more random it will be, just remembert o
	--up the number in math.random(x) to however many textures you have.
	numGen = math.random(2)

	local newBlock
	print (numGen)

	if(numGen == 1 and isDone == false) then
		newBlock = display.newImage( "img/ground1.png" ) 
		isDone = true 
	end

	if(numGen == 2 and isDone == false) then
		newBlock = display.newImage( "img/ground2.png" )
		isDone = true
	end

	--now that we have the right image for the block we are going
	--to give it some member variables that will help us keep track
	--of each block as well as position them where we want them.
	newBlock.name = ("block" .. a)
	newBlock.id = a 
	--because a is a variable that is being changed each run we can assign
	--values to the block based on a. In this case we want the x position to
	--be positioned the width of a block apart.
	newBlock.x = (a * 79) - 79
	newBlock.y = groundLevel
	blocks:insert(newBlock)
end


--the update function will control most everything tghat happens in our game
--this will be called every frame(30 frames per second in our case, which is the Corona SDK default)
local function update(event)
	-- updateBackgrounds will call a function made specifically to handle the background movement
	updateBackgrounds()
	updateSpeed()
	updateMonster()
	updateBlocks()
	updateBlasts()
	updateSpikes()
	updateGhosts()
	checkCollisions()
end

function updateSpeed()
	speed = speed + .0005
end 

function checkCollisions()
     wasOnGround = onGround
     --checks to see if the collisionRect has collided with anything. This is why it is lifted off of the ground
     --a little bit, if it hits the ground that means we have run into a wall. We check this by cycling through
     --all of the ground pieces in the blocks group and comparing their x and y coordinates to that of the collisionRect
     for a = 1, blocks.numChildren, 1 do
          if(collisionRect.y - 10 > blocks[a].y - 170 and blocks[a].x - 40 < collisionRect.x and blocks[a].x + 40 > collisionRect.x) then
               speed = 0
               hitGround = 1

          end
     end
     --this is where we check to see if the monster is on the ground or in the air, if he is in the air then he can't jump(sorry no double
     --jumping for our little monster, however if you did want him to be able to double jump like Mario then you would just need
     --to make a small adjustment here, by adding a second variable called something like hasJumped. Set it to false normally, and turn it to
     --true once the double jump has been made. That way he is limited to 2 hops per jump.
     --Again we cycle through the blocks group and compare the x and y values of each.
     for a = 1, blocks.numChildren, 1 do
          if(monster.y >= blocks[a].y - 170 and blocks[a].x < monster.x + 60 and blocks[a].x > monster.x - 60) then
               monster.y = blocks[a].y - 171
               onGround = true
               break
          else
               onGround = false
          end
     end
     --stop the game if the monster runs into a spike wall
     for a = 1, spikes.numChildren, 1 do 
     	if(spikes[a].isAlive == true) then 
     		if(collisionRect.y - 10 > spikes[a].y - 170 and spikes[a].x - 40 < collisionRect.x and spikes[a].x + 40 > collisionRect.x) then 
     			--stop the monster
     			speed = 0
     			monster.isAlive = false
     			gameOver.x = display.contentWidth * .65
     			gameOver.y = display.contentHeight / 2
     			--this simply pauses the current animation
     			monster:pause()
     		end 
     	end 
     end 
     --make sure the player didn't get hit by a ghost!
     for a=1, ghosts.numChildren, 1 do 
     	if(ghosts[a].isAlive == true) then
     		if(((((monster.y - ghosts[a].y)) < 70) and ((monster.y - ghosts[a].y) > -70)) and (ghosts[a].x - 40 < collisionRect.x and ghosts[a].x + 40 > collisionRect.x)) then 
     			--stop the monster
     			speed = 0
     			monster.isAlive = false
     			gameOver.x = display.contentWidth * .65
     			gameOver.y = display.contentHeight / 2
     			--this simply pauses the current animation
     			monster:pause()
     		end 
     	end 
     end 
end

function updateBlasts()
	--for each blast that we instantiated check to see what it is doing
	for a = 1, blasts.numChildren, 1 do 
		--if that blast is not in play we don't need to check anything else
		if(blasts[a].isAlive == true) then 
			(blasts[a]):translate(5, 0)
			--if the blast has moved off of the screen, then kill it and return it to its original place
			if(blasts[a].x > 550) then 
				blasts[a].x = 800
				blasts[a].y = 500
				blasts[a].isAlive = false 
			end 
		end 

		--check for collisions between blasts and the spikes
		for b = 1, spikes.numChildren, 1 do 
			if(spikes[b].isAlive == true) then 
				if(blasts[a].y - 25 > spikes[b].y - 120 and blasts[a].y + 25 < spikes[b].y + 120 and spikes[b].x - 40 < blasts[a].x + 25 and spikes[b].x + 40 > blasts[a].x - 25) then 
					blasts[a].x = 800
					blasts[a].y = 500
					blasts[a].isAlive = false
					if(speed > 0.1) then
						spikes[b].x = 900
						spikes[b].y = 500
						spikes[b].isAlive = false 
					end
				end 
			end 
		end 

		--check for collisions between the blasts and the ghosts
		for b = 1, ghosts.numChildren, 1 do 
			if(ghosts[b].isAlive == true) then 
				if(blasts[a].y - 25 > ghosts[b].y -120 and blasts[a].y + 25 < ghosts[b].y + 120 and ghosts[b].x - 40 < blasts[a].x + 25 and ghosts[b].x + 40 > blasts[a].x - 25) then 
					blasts[a].x = 800
					blasts[a].y = 500
					blasts[a].isAlive = false 
					if(speed > 0.1) then
						ghosts[b].x = 800
						ghosts[b].y = 600
						ghosts[b].isAlive = false
						ghosts[b].speed = 0
					end 
				end 
			end 
		end 
	end 
end 

--check to see if the spikes are alive or not, if they are
--then update them appropriately
function updateSpikes()
	for a = 1, spikes.numChildren, 1 do 
		if(spikes[a].isAlive == true) then 
			(spikes[a]):translate(speed * -1, 0)
			if(spikes[a].x < -80) then 
				spikes[a].x = 900
				spikes[a].y = 500
				spikes[a].isAlive = false
			end 
		end 
	end 
end 

--update the ghosts if they are alive
function updateGhosts()
	for a=1, ghosts.numChildren, 1 do 
		if(ghosts[a].isAlive == true) then 
			(ghosts[a]):translate(speed * -1, 0)

			if(ghosts[a].y > monster.y) then
				ghosts[a].y = ghosts[a].y + 1
			end 
			if(ghosts[a].x < -80) then
				ghosts[a].x = 800
				ghosts[a].y = 600
				ghosts[a].speed = 0
				ghosts[a].isAlive = false 
			end 
		end 
	end 
end 
function updateMonster()
    --if our monster is jumping then switch to the jumping animation
    --if not keep playing the running animation
	if(monster.isAlive == true) then
	    if(onGround) then
	        --if we are already on the ground we don't need to prepare anything new
	        if(wasOnGround) then
	        else
	            monster:prepare("running")
	            monster:play()
	        end
	    else
	        monster:prepare("jumping")
	        monster:play()
	        if(hitGround == 1) then
	        	if(monster.y > groundMin - 95) then
     				speed = 0
     				monster.isAlive = false
     				gameOver.x = display.contentWidth * .65
     				gameOver.y = display.contentHeight / 2
     				--this simply pauses the current animation
     				monster:pause()
               	end
	          	speed = 5
	          	hitGround = 0
	        end 
	    end

	    if(monster.accel > 0) then
	        monster.accel = monster.accel - 1
	    end
	    --update the monsters position accel is used for our jump and
	    --gravity keeps the monster coming down. You can play with those 2 variables
	    --to make lots of interesting combinations of gameplay like 'low gravity' situations
	    monster.y = monster.y - monster.accel
	    monster.y = monster.y - monster.gravity
	else 
	 	monster:rotate(5)
	end 
    --update the collisionRect to stay in front of the monster
    collisionRect.y = monster.y
end

function restartGame()
	--move menu
	gameOver.x = 0 
	gameOver.y = 500
	--reset the score
	score = 0
	--reset the game speed
	speed = 5
	--reset the monster
	monster.isAlive = true
	monster.x = 110
	monster.y = 250
	monster:prepare("running")
	monster:play()
	monster.rotation = 0
	--reset the groundLevel
	groundLevel = groundMin 
	for a = 1, blocks.numChildren, 1 do 
		blocks[a].x = (a * 79) - 79
		blocks[a].y = groundLevel
	end 
	--reset the ghosts
	for a = 1, ghosts.numChildren, 1 do 
		ghosts[a].x = 800
		ghosts[a].y = 600
	end 
	--reset the spikes
	for a = 1, spikes.numChildren, 1 do 
		spikes[a].x = 900
		spikes[a].y = 500
	end 
	--reset the blasts
	for a = 1, blasts.numChildren, 1 do 
		blasts[a].x = 800
		blasts[a].y = 500
	end 
	--reset the backgrounds
	backgroundfar.x = 480
	backgroundfar.y = 160
	backgroundfar2.x = 1440
	backgroundfar2.y = 160
	backgroundnear1.x = 240
	backgroundnear1.y = 160
	backgroundnear2.x = 760
	backgroundnear2.y = 160
end 

--this is the function that handles the jump events. If the screen is touched on the left side
--then make the monster jump
function touched( event )
	if(event.x < gameOver.x + 150 and event.x > gameOver.x - 150 and event.y < gameOver.y + 95 and event.y > gameOver.y - 95 ) then 
		restartGame()
	else 
		if(monster.isAlive == true) then
		     if(event.phase == "began") then
		          if(event.x < 241) then
		               if(onGround) then
		                    monster.accel = monster.accel + 20
		               end
		           else 
			           	for a=1, blasts.numChildren, 1 do 
			           		if(blasts[a].isAlive == false) then 
			           			blasts[a].isAlive = true
			           			blasts[a].x = monster.x + 50
			           			blasts[a].y = monster.y 
			           			break 
			           		end 
			          end
			      end 
		     end
		 end 
	end 
end

function updateBlocks()
	for a = 1, blocks.numChildren, 1 do 
		if(a > 1) then 
			newX = (blocks[a - 1]).x + 79
		else 
			newX = (blocks[8]).x + 79 - speed
		end

		if((blocks[a]).x < -40) then
			score = score + 1
			scoreText.text = "score: " .. score 
			scoreText:setReferencePoint(display.CenterLeftReferencePoint)
			scoreText.x = 0
			scoreText.y = 30
			if(inEvent == 11) then 
				(blocks[a]).x, (blocks[a]).y = newX, 600
			else 
				(blocks[a]).x, (blocks[a]).y = newX, groundLevel
			end 
			--by setting up the spikes this way we are guaranteed to 
			--only have 3 spikes out at most at a time.
			if(inEvent == 12) then 
				for a=1, spikes.numChildren, 1 do 
					if(spikes[a].isAlive == true) then 
						--do nothing
					else 
						spikes[a].isAlive = true
						spikes[a].y = groundLevel - 200
						spikes[a].x = newX 
						break
					end 
				end 
			end 
			checkEvent()
		else 
			(blocks[a]):translate(speed * -1,0)
		end 
	end 
end 


function updateBackgrounds()
	--far background movement
	backgroundfar.x = backgroundfar.x - (speed/55)
	backgroundfar2.x = backgroundfar2.x - (speed/55)
	if(backgroundfar.x < -478) then 
		backgroundfar.x = 760
	end 


	--near background movement
	backgroundnear1.x = backgroundnear1.x - (speed/5)
	--if the sprite has moved off the screen move it back to the 
	--other side so it will move back on 
	if(backgroundnear1.x < -239) then
		backgroundnear1.x = 760
	end 

	backgroundnear2.x = backgroundnear2.x - (speed/5)
	if(backgroundnear2.x < -239) then 
		backgroundnear2.x = 760
	end 
end 

function checkEvent()
	--first check to see if we are already in an event, we only want 1 event going on at a time
	if(eventRun > 0) then
		--if we are in an event decrease eventRun. eventRun is a variable that tells us how
		--much longer the event is going to take place. Every time we check we need to decrement
		--it. Then if at this point eventRun is 0 then the event has ended so we set inEvent back
		--to 0.
		eventRun = eventRun - 1
		if(eventRun == 0) then 
			inEvent = 0
		end 
	end 

	--if we are in an event then do nothing
	if(inEvent > 0 and eventRun > 0) then
		--Do nothing
	else 
		--if we are not in an event to check to see if we are going to start a new event. To do this
		--we generate a random number between 1 and 100. We then check to see if our 'check' is
		--going to start an event. We are using 100 here in the example because it is easy to determiine
		--the likelihood that an event will fire(We could just as easily chosen 10 or 1000).
		--For example, if we decide that an event is going to 
		--start everytime check is over 80 then we know that everytime a block is reset there is a 20%
		--chance that an event will start. So one in every five blocks should start a new event. This
		--is where you will have to fit the needs of your game.
		check = math.random( 100 )

		--this first event is going to cause the elevation of the ground to change. For this game we
		--only want the elevation to change 1 block at a time so we don't get long runs of changing
		--elevation that is impossible to pass so we set eventRun to 1.
		if(check > 80 and check < 99) then 
			--since we are in an event we need to decide what we want to do. By making inEvent another
			--random number we can now randomly choose which direction we want the elevation to change.
			inEvent = math.random( 10 )
			eventRun = 1
		end 
		--pit event
		if(check > 98) then
			inEvent = 11
			eventRun = 2
		end 

		--Spike event
		--the more frequently you want events to happen then
		--greater you should make the checks
		if(check > 72 and check < 81) then
			inEvent = 12
			eventRun = 1
		end 

		--Ghost event
		if(check > 60 and check < 73) then
			inEvent = 13
			eventRun = 1
		end 
	end 
	--if we are in an event call runEvent to figure out if anything special needs to be done
	if(inEvent > 0) then 
		runEvent()
	end 
end 

--this function is pretty simple it just checks to see what event should be happening, then
--updates the appropriate items. Notice that we check to make sure the ground is within a
--certain range, we don't want the ground to spawn above or below whats visible on the screen.
function runEvent()
	if(inEvent < 6) then 
		groundLevel = groundLevel + 40
	end 
	if(inEvent > 5 and inEvent < 11) then
		groundLevel = groundLevel - 40
	end 
	if(groundLevel < groundMax) then 
		groundLevel = groundMax
	end 
	if(groundLevel > groundMin) then
		groundLevel = groundMin
	end 

	--this will be a little bit different as we want this to really
	--make the game feel even more random. change where the ghosts
	--spawn and how fast they come at a monster.
	if(inEvent == 13) then
		for a=1, ghosts.numChildren, 1 do 
			if(ghosts[a].isAlive == false) then
				ghosts[a].isAlive = true
				ghosts[a].x = 500
				ghosts[a].y = math.random( -50, 400)
				ghosts[a].speed = math.random( 2, 4)
				break 
			end 
		end 
	end 
end 

--this is how we call the update function, make sure this line comes after the
--actual function or it will not be able to find it
--timer.performWithDelay(how often it will run in milliseconds, function to call,
	--how many times to call(-1 means forever))
	timer.performWithDelay( 1, update, -1 )
	Runtime:addEventListener("touch", touched, -1)