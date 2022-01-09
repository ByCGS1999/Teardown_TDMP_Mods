--[[
    CGS TDMP CUSTOM TOOL REPLICATION SCRIPT.

    THIS FILE CONTAINS THE REPLCIATION SYSTEM FOR THE RIFLE AND A APPROXIMATION OF HOW HAMMER REPLICATION MIGHT WORK. (Works kinda badly. ACTUALLY IS A PISTOL WITH ANOTHER MODE AND A REALLY SLOW BULLET (DOESNT DEAL DAMAGE)).
    THANKS FOR TDMP TEAM FOR THE FRAMEWORK

    Replication Made by CGS1999
--]]

#include "tdmp/networking.lua"
#include "tdmp/hooks.lua"

#include "ballistics.lua"

Bullets_FlyBy = {}
Bullets_FlyBy_Sub = {}
Bullets_PlayerDamage = {}

LocalSteamID = TDMP_LocalSteamId()

function init()

    for i=1, 23 do
		Bullets_FlyBy[i] = LoadSound("MOD/snd/bullets/flyby/" .. i .. ".ogg")
	end

	for i=1, 11 do
		Bullets_FlyBy_Sub[i] = LoadSound("MOD/snd/bullets/flyby/sub_" .. i .. ".ogg")
	end

	for i=1, 6 do
		Bullets_PlayerDamage[i] = LoadSound("MOD/snd/bullets/damage/" .. i .. ".ogg")
	end

    local rifleSounds = {}
    for i = 0, 6 do
        rifleSounds[#rifleSounds + 1] = LoadSound("tools/rifle" .. i .. ".ogg")
    end

    local sledgeSounds = {}
    for i = 0, 7 do
        sledgeSounds[#sledgeSounds + 1] = LoadSound("tools/sledge" .. i .. ".ogg")
    end

    TDMP_RegisterEvent(
        "sledgeTrigger",
        function(jsonData)
            local data = json.decode(jsonData)
            if data.pos == nil then return end
            MakeHole(data.pos, 1.2, 1.0, 0)

            TDMP_ServerStartEvent(
                "sledgeTrigger",
                {
                    Receiver = TDMP.Enums.Receiver.ClientsOnly, -- We've received that event already so we need to broadcast it only to clients, not again to ourself
                    Reliable = true,
                    DontPack = true,
                    Data = jsonData
                }
            )

        end
    )

    TDMP_RegisterEvent("FETrigger", function(jsonData)
        data = json.decode(jsonData)
        if data.pos == nil then return end
        if data.dir == nil then return end
        if data.id == localtdmpsteam then return end
        ParticleReset()
        ParticleFlags(256)
        ParticleGravity(-1, -30)
        ParticleColor(0.7,0.7,0.7)
        ParticleCollide(1, 1, "constant", 0.05)
        SpawnParticle(data.pos,data.dir,10)

        TDMP_ServerStartEvent(
                "FETrigger",
                {
                    Receiver = TDMP.Enums.Receiver.ClientsOnly, -- We've received that event already so we need to broadcast it only to clients, not again to ourself
                    Reliable = true,
                    DontPack = true,
                    Data = jsonData
                }
            )
    end)

    TDMP_RegisterEvent(
        "nitroglycerin_place",
        function(jsonData)
            local data = json.decode(jsonData)
            
            local t = GetAimDirection()
		    local transform = TransformToParentVec(t, Vec(0, 0, -1))
		    local hit, dist, normal, shape = QueryRaycast(t.pos, transform, 500)
	        local hitPoint = VecAdd(t.pos, VecScale(transform, dist))
	        local pos = VecAdd(hitPoint, VecScale(normal, 0.01))

            quatangle = QuatLookAt(Vec(), normal)
            if VecLength(VecCross(normal, Vec(0, 1, 0))) == 0 then
                quatangle = QuatRotateQuat(QuatEuler(0, math.deg(math.atan2(transform[1], transform[3])) + 180, 0), quatangle)
            end

            if hit then
				exttransform = Transform(pos, quatangle)
				exttransform = TransformToLocalTransform(GetShapeWorldTransform(shape), exttransform)
			end

            if GetToolBody() ~= 0 then
                local t = Transform()
                t.pos = Vec(0.3, -0.4, -0.7)
                t.rot = QuatEuler(20, 0, 0)
                SetToolTransform(t)
            end

            if not TDMP_IsServer() then
                return
            end

            TDMP_ServerStartEvent(
                "nitroglycerin_place",
                {
                    Receiver = TDMP.Enums.Receiver.ClientsOnly, -- We've received that event already so we need to broadcast it only to clients, not again to ourself
                    Reliable = true,
                    DontPack = true,
                    Data = jsonData
                }
            )
        end
    )


    TDMP_RegisterEvent(
        "RifleShot",
        function(jsonData)
            local data = json.decode(jsonData)

            local mediumDamage = math.min(math.max((data[2] - 3) * .5, 0), 1)
            mediumDamage = ((mediumDamage + mediumDamage) + 3) * .2

            local isMe = data[1] == LocalSteamID
            Ballistics:Shoot {
                Type = Ballistics.Type.Bullet,
                Owner = data[1],
                Pos = data[4],
                Dir = data[3],
                Vel = VecScale(data[3], 450),
                Soft = mediumDamage + .3,
                Medium = mediumDamage,
                Hard = 0,
                Damage = .55,
                NoHole = isMe,
                HitPlayerAndContinue = true,
                Life = 2
            }

            if not isMe then
                PlaySound(shotgunSounds[math.random(1, #shotgunSounds)], data[4], 1)
            end

            if not TDMP_IsServer() then
                return
            end

            TDMP_ServerStartEvent(
                "RifleShot",
                {
                    Receiver = TDMP.Enums.Receiver.ClientsOnly, -- We've received that event already so we need to broadcast it only to clients, not again to ourself
                    Reliable = true,
                    DontPack = true,
                    Data = jsonData
                }
            )
        end
    )
end

function GetAimDirection()
	local cam = GetPlayerCameraTransform()
	local forward = TransformToParentPoint(cam, Vec(0, 0, -1))
	local dir = VecSub(forward, cam.pos)

	return VecNormalize(dir), VecLength(dir)
end

TDMP_RegisterEvent("GrabPhys", function(jsonData)
    data = json.decode(jsonData)
    for _, localdata in ipairs (data) do  
        if localdata.id == localtdmpsteam then return end
        SetBodyTransform(localdata.b ,localdata.t)
    end
end)


function grabsync()
    local grabbody = GetPlayerGrabBody(); 
    if grabbody ~= 0 then TDMP_ClientStartEvent("GrabPhys", {Receiver = 1, Reliable = false, DontPack = false , Data = { {b = grabbody, t = GetBodyTransform(grabbody),  id = localtdmpsteam} } } ) end
end

local nextSledgeShoot
local nextRifleShoot

function tick(dt)
    TDMP_Hook_Queue() -- Run this every tick in your script, if you're using Hook_AddListener in your script. This *seem* to be preventing from crashes, when calling hook from different thread(mod)
    Ballistics:Tick()
    
    if not TDMP_IsServer() then 
        grabsync()
    end

    local cpos = GetCameraTransform()
    local t = GetTime()
    local curTool = GetString("game.player.tool")
    if InputPressed("lmb") and GetPlayerVehicle() == 0 then
        if curTool == "sledge" then
            local fwd =  TransformToParentVec(cpos, Vec(0, 0, -1) )
            local hit, dist, normal = QueryRaycast(cpos.pos,fwd,3.5)
            if hit then
            local pos = normal
            TDMP_ClientStartEvent("sledgeTrigger", {Receiver = 1, Reliable = true, DontPack = false , Data = {pos = pos,  id = localtdmpsteam } } )
        elseif curTool == "explosive" then
            TDMP_ClientStartEvent(
                "nitroglycerin_place",
                {
                    Reliable = true,
                    Data = {
                        LocalSteamID,
                        GetInt("game.tool.explosive.damage"),
                        GetAimDirection(),
                        GetPlayerCameraTransform().pos
                    }
                }
            )
        elseif curTool == "extinguisher" then
            local pos =  VecAdd( GetBodyTransform(GetToolBody()).pos, Vec(0,0.4,0) )
            local fwd =  TransformToParentVec(t, Vec(0, 0, -10) )
            TDMP_ClientStartEvent("FESync", {Receiver = 1, Reliable = false, DontPack = false , Data = {pos = pos, dir = fwd, id = localtdmpsteam } } )
        elseif curTool == "rifle" then
            if nextRifleShoot and nextRifleShoot > t then
                return
            end
            nextRifleShoot = t + .8

            TDMP_ClientStartEvent(
                "RifleShot",
                {
                    Reliable = true,
                    Data = {
                        LocalSteamID,
                        GetInt("game.tool.rifle.damage"),
                        GetAimDirection(),
                        GetPlayerCameraTransform().pos
                    }
                }
            )
        end
    end
end
end