#include "tdmp/networking.lua"
#include "tdmp/hooks.lua"
#include "tdmp/player.lua"

disruptors = {}
fireSound1 = nil
fireSound2 = nil
fireSound3 = nil
fireSound4 = nil


function init()
	RegisterTool("disruptor", "Disruptor", "MOD/vox/Disruptor.vox")
	SetBool("game.tool.disruptor.enabled", true)
	SetInt("game.tool.disruptor.ammo", 100) -- Ammo ammount
	originalFov = GetInt("options.gfx.fov")
	fireSound1 = LoadSound("MOD/snd/fire1.ogg")
	fireSound2 = LoadSound("MOD/snd/fire2.ogg")
	fireSound3 = LoadSound("MOD/snd/fire3.ogg")
	fireSound4 = LoadSound("MOD/snd/fire4.ogg")
		

	TDMP_RegisterEvent('disruptor_shoot_unpressed',function(jsonData)
		cooldownTimer = 0 -- Cooldown Ammount
			recoil = 1 -- Recoil Ammount

			local orgData = jsonData;

			local jsonData = json.decode(jsonData)

			local ct = jsonData[2]
			local pos = ct.pos
			local dir = TransformToParentVec(ct, Vec(0, 0, -1))
			local hit, dist, normal, shape = QueryRaycast(pos, dir, 100) -- Range of Small Disruptor	 	

			if not hit then
				PlaySound(fireSound3, pos, 0.3) -- Small Disruptor Sound Volume
			end

			if hit then
				local hitPoint = VecAdd(VecAdd(pos, VecScale(dir, dist)), Vec(0, 0.5, 0))
				PlaySound(fireSound4, pos, 0.5) -- Small Disruptor Sound Volume
				PlaySound(fireSound1, hitPoint, 1) -- Small Disruptor Sound Volume
				PointLight(hitPoint, 1, 1, 1, 10)
				PointLight(hitPoint, 1, 0, 0, 100)
				MakeHole(hitPoint, 2, 2, 2) -- Small Explosion Hole Size
				disruptors[#disruptors + 1] = {
					["id"] = #disruptors + 1,
					["location"] = hitPoint,
					["direction"] = rndVec2D(1),
					["size"] = 1, -- Small Disruptor Size
					["speed"] = 0,
					["age"] = 0
				}
			end

			TDMP_ServerStartEvent('disruptor_shoot_unpressed',{
				Reciever = TDMP.Enums.Reciever.ClientsOnly,
				Reliable=true,
				DontPack = true,
				Data=orgData
			})
	end)

	TDMP_RegisterEvent('disruptor_shoot_aiming',function(jsonData)
		cooldownTimer = .4 -- Cooldown Ammount Multiplied by Slower Time Scale bringing it to 4 seconds
		recoil = 4 -- Recoil Ammount
					
			local orgData = jsonData;
			local jsonData = json.decode(jsonData)

			local ct = jsonData[2]
			local pos = ct.pos
			local dir = TransformToParentVec(ct, Vec(0, 0, -1))
			local hit, dist, normal, shape = QueryRaycast(pos, dir, 300) -- Range of Zoomed Disruptor

			if hit then		
				local hitPoint = VecAdd(VecAdd(pos, VecScale(dir, dist)), Vec(0, 0.5, 0))
				local hitPoint2 = VecAdd(hitPoint, Vec(1, 0, 0))
				local hitPoint3 = VecAdd(hitPoint, Vec(0, 0, 1))
				local hitPoint4 = VecAdd(hitPoint, Vec(-1, 0, 0))
				local hitPoint5 = VecAdd(hitPoint, Vec(0, 0, -1))
				local hitPoint6 = VecAdd(hitPoint, Vec(0, 1, 0))
				local hitPoint7 = VecAdd(hitPoint, Vec(0, -1, 0))
					
				PlaySound(fireSound2, pos, 1) -- Large Disruptor Sound Volume
				PointLight(pos, 1, 0, 0, 50) -- Point Blank Red Flash
				MakeHole(hitPoint, 4, 4, 4) -- Large Hole Size
				Explosion(hitPoint, 3) -- Large Explosion Size

				ParticleReset()					
				ParticleTile(5)
				ParticleRadius(.1*math.random(30, 50), math.random(40, 70))
				ParticleAlpha(0.5, 0)
				ParticleCollide(0)
				ParticleColor(1,1,.01*math.random(75, 100))
				ParticleEmissive(1, 0) 

				SpawnParticle(hitPoint, Vec(-20+math.random(10, 30), 10+math.random(20, 40), -20+math.random(10, 30)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint2, Vec(-20+math.random(10, 30), -70+math.random(20, 40), -20+math.random(10, 30)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint3, Vec(10+math.random(20, 40), -20+math.random(10, 30), -20+math.random(10, 30)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint4, Vec(-70+math.random(20, 40), -20+math.random(10, 30), -20+math.random(10, 30)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint5, Vec(-20+math.random(10, 30), -20+math.random(10, 30), 10+math.random(20, 40)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint6, Vec(-20+math.random(10, 30), -20+math.random(10, 30), -70+math.random(20, 40)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint7, Vec(-20+math.random(10, 30), -20+math.random(10, 30), -20+math.random(10, 30)), .1*(math.random(3,10)))

				ParticleReset()					
				ParticleTile(5)
				ParticleRadius(.1*math.random(30, 50), math.random(40, 70))
				ParticleAlpha(0.5, 0)
				ParticleCollide(0)
				ParticleColor(1,.01*math.random(0, 20),0)
				ParticleEmissive(.5, 0)

				SpawnParticle(hitPoint, Vec(10+math.random(20, 40), -20+math.random(10, 30), -20+math.random(10, 30)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint2, Vec(-20+math.random(10, 30), -20+math.random(10, 30), -70+math.random(20, 40)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint3, Vec(-20+math.random(10, 30), 10+math.random(20, 40), -20+math.random(10, 30)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint4, Vec(-20+math.random(10, 30), -20+math.random(10, 30), -70+math.random(20, 40)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint5, Vec(-20+math.random(10, 30), 10+math.random(20, 40), -20+math.random(10, 30)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint6, Vec(-70+math.random(20, 40), -20+math.random(10, 30), -20+math.random(10, 30)), .1*(math.random(3,10)))
				SpawnParticle(hitPoint7, Vec(-20+math.random(10, 30), -20+math.random(10, 30), -20+math.random(10, 30)), .1*(math.random(3,10)))

				disruptors[#disruptors + 1] = {
					["id"] = #disruptors + 1,
					["location"] = hitPoint,
					["direction"] = rndVec2D(1),
					["size"] = 4, -- Large Disruption Size
					["speed"] = 0,
					["age"] = 0
				}
			end

			TDMP_ServerStartEvent('disruptor_shoot_aiming',{
				Reciever = TDMP.Enums.Reciever.ClientsOnly,
				Reliable=true,
				DontPack = true,
				Data=orgData
			})
	end)


	TDMP_RegisterEvent('disruptor_shoot_basic',function(jsonData)
		cooldownTimer = 0 -- Cooldown Ammount
			recoil = 1 -- Recoil Ammount

			local orgData = jsonData;
			local jsonData = json.decode(jsonData)

			local ct = jsonData[2]
			local pos = ct.pos
			local dir = TransformToParentVec(ct, Vec(0, 0, -1))
			local hit, dist, normal, shape = QueryRaycast(pos, dir, 100) -- Range of Small Disruptor	 	

			if not hit then
				PlaySound(fireSound3, pos, 0.3) -- Small Disruptor Sound Volume
			end

			if hit then
				local hitPoint = VecAdd(VecAdd(pos, VecScale(dir, dist)), Vec(0, 0.5, 0))
				PlaySound(fireSound4, pos, 0.5) -- Small Disruptor Sound Volume
				PlaySound(fireSound1, hitPoint, 1) -- Small Disruptor Sound Volume
				PointLight(hitPoint, 1, 1, 1, 10)
				PointLight(hitPoint, 1, 0, 0, 100)
				MakeHole(hitPoint, 2, 2, 2) -- Small Explosion Hole Size
				disruptors[#disruptors + 1] = {
					["id"] = #disruptors + 1,
					["location"] = hitPoint,
					["direction"] = rndVec2D(1),
					["size"] = 1, -- Small Disruptor Size
					["speed"] = 0,
					["age"] = 0
				}
			end

			TDMP_ServerStartEvent('disruptor_shoot_basic',{
				Reciever = TDMP.Enums.Reciever.ClientsOnly,
				Reliable=true,
				DontPack = true,
				Data=orgData
			})
	end)

	--TDMP_RegisterTool("disruptor","Disruptor","MOD/vox/Disruptor.vox")
end

function VecDist(vec1, vec2)
	return VecLength(VecSub(vec1, vec2))
end

function VecDist2D(vec1, vec2)
	vec1H = VecCopy(vec1)
	vec1H[2] = 0
	vec2H = VecCopy(vec2)
	vec2H[2] = 0
	return VecDist(vec1H, vec2H)
end

function getDisruptorPullVelocity(thisBodyTransform, disruptor, fullHeight, isPlayer)
	strength = math.random(15, 16) -- Strength/Speed of small Disruption	
	if InputDown("rmb") then
		strength = math.random(30, 31) -- Strength/Speed of large Disruption
	end
		
	local comparingPos = VecCopy(thisBodyTransform.pos)
	comparingPos[2] = 0
	local comparingDisruptorLoc = VecCopy(disruptor["location"])
	comparingDisruptorLoc[2] = 0
	local distanceToDisruptor = VecDist(comparingPos, comparingDisruptorLoc)

	if strength <= 0 then
		return nil
	end

	local ourTargetVelDir = TransformToParentVec(Transform(comparingPos, QuatLookAt(comparingPos, comparingDisruptorLoc)), Vec(1, 0, 0))
	ourTargetVelDir[2] = math.max((disruptor["location"][2] + (fullHeight * 0.05)) - thisBodyTransform.pos[2], -0.5) -- Rotation Height
	ourTargetVelDir[2] = math.min(ourTargetVelDir[2], 0.5)                     
	ourTargetVelDir = VecNormalize(ourTargetVelDir)
	
	local ourTargetVelocity = VecScale(ourTargetVelDir, strength)
	local drawTowardsEdgeVel = VecScale(VecNormalize(VecSub(comparingDisruptorLoc, comparingPos)), strength)
	
	if distanceToDisruptor < (disruptor["size"] * .6) then -- Distance to edge draw
		drawTowardsEdgeVel = Vec(0, 0, 0)
	end
	
	local finalVelocity = VecAdd(ourTargetVelocity, drawTowardsEdgeVel)
	return finalVelocity
end

function coneCircleCoordinates(pos, size)
	local coords = {}
	local rDiff = 3
	local heightDiff = 6
	local particleDiff = 3
	
	local r = rDiff
	local height = heightDiff
	coords[1] = pos
	while r < size do
		local angularDiff = math.floor(math.deg(2 * math.asin(particleDiff / (2 * r))))
		for ang = 0, 360, angularDiff do
			local thisAng = math.rad(ang)
			local nextCoord = VecAdd(pos, VecAdd(Vec(0, height, 0), VecScale(Vec(math.cos(thisAng), 0, math.sin(thisAng)), r)))
			coords[#coords + 1] = nextCoord
		end
		r = r + rDiff
		height = height + heightDiff
	end

	return coords, height
end

function rndVec2D(length)
	local ang = math.random() * 2 * math.pi
	return VecScale(Vec(math.cos(ang), 0, math.sin(ang)), length)
end


-- Updates once per frame
cooldownTimer = 0
recoil = 0

function tick(dt)
	if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") then
		-- Recoil
		if GetToolBody() ~= 0 then
			local t = Transform()
			t.pos = Vec(0, 0, 0)
			t.rot = QuatEuler(recoil, 0, 0)
			SetToolTransform(t)
		end

			if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") and InputDown("rmb") then
				SetCameraFov(65) -- Zoom Ammount
			end

			-- Firing of Large Zoomed Disruptor
			if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") and InputDown("rmb") and InputPressed("lmb") and cooldownTimer <= 0 then		
				TDMP_ClientStartEvent('disruptor_shoot_aiming',{
					Reliable=true,
					Data={
						TDMP_LocalSteamId(),
						GetCameraTransform()
					}
				})
			end		
		
		-- Firing of Small Disruptor "Press LMB"
		if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") and cooldownTimer <= 0 and InputPressed("lmb") and not InputDown("rmb") then								
			TDMP_ClientStartEvent('disruptor_shoot_basic',{
				Reliable=true,
				Data = {
					TDMP_LocalSteamId(),
					GetCameraTransform()
				}
			})
		end
		-- Firing of Small Disruptor "Release LMB"
		if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") and cooldownTimer <= 0 and InputReleased("lmb") and not InputDown("rmb") then								
			TDMP_ClientStartEvent('disruptor_shoot_unpressed',{
				Reliable=true,
				Data = {
					TDMP_LocalSteamId(),
					GetCameraTransform()
				}
			})
		end		
	end
end

function draw()
	if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") and InputPressed("lmb") and not InputDown("rmb") then
		UiPush()
			UiTranslate(UiCenter(), UiMiddle())
			UiAlign("center middle") 
			UiImage("img/bang1.png")
		UiPop()
	end
	if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") and InputReleased("lmb") and not InputDown("rmb") then
		UiPush()
			UiTranslate(UiCenter(), UiMiddle())
			UiAlign("center middle")
			UiImage("img/bang2.png")
		UiPop()
	end
	if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") and InputDown("rmb") and InputPressed("lmb") then
		UiPush()
			UiTranslate(UiCenter(), UiMiddle())
			UiAlign("center middle")
			UiImage("img/bang3.png")
		UiPop()
	end
end

-- Updates always 60 times per second
function update(dt)
	maxMass = 200 -- Maximum Mass of Objects affected by Small Disruption

	if GetString("game.player.tool") == "disruptor" and GetBool("game.player.canusetool") and InputDown("rmb") then
		maxMass = 5000 -- Maximum Mass of Objects affected by Large Disruption
		SetTimeScale(.1) -- SlowMo Effect
	end

	if cooldownTimer > 0 then
		cooldownTimer = cooldownTimer - dt
	end

	if recoil > 0 then
		recoil = recoil - (10 * dt)
	end

	deletingDisruptors = {}
	for i = 1, #disruptors do
		local disruptor = disruptors[i]

		disruptor["location"] = VecAdd(disruptor["location"], VecScale(disruptor["direction"], disruptor["speed"]))
		disruptor["age"] = disruptor["age"] + dt

		local allCoords, fullHeight = coneCircleCoordinates(disruptor["location"], disruptor["size"])
		for j = 1, #allCoords do
		-- Deleted Particle Effects	
		end

		local attackRange = disruptor["size"] + 1 -- Small Disruption Area Size

		if InputDown("rmb") then
			local attackRange = disruptor["size"] + 8 -- Large Disruption Area Size
		end

		-- Pull in nearby bodies
		local allNearbyBodies = QueryAabbBodies(VecSub(disruptor["location"], Vec(attackRange, attackRange, attackRange)), VecAdd(disruptor["location"], Vec(attackRange, attackRange, attackRange)))
		for i = 1, #allNearbyBodies do
			local thisBody = allNearbyBodies[i]
			local mass = GetBodyMass(thisBody)
			if IsBodyDynamic(thisBody) and mass < maxMass then
				local newVel = getDisruptorPullVelocity(GetBodyTransform(thisBody), disruptor, fullHeight, false)
				if newVel ~= nil then
					SetBodyVelocity(thisBody, newVel)
				end
			end
		end

		if disruptor["age"] >= 3 and InputDown("rmb") then -- Time Length of Large Disruption
			deletingDisruptors[#deletingDisruptors + 1] = i
		end

		if disruptor["age"] >= .1 and not InputDown("rmb") then -- Time Length of Small Disruption
			deletingDisruptors[#deletingDisruptors + 1] = i
		end
	end

	for i = 1, #deletingDisruptors do
		table.remove(disruptors, deletingDisruptors[i])
	end
end
