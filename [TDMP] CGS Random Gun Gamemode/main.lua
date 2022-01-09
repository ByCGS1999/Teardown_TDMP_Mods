#include "tdmp/networking.lua"
#include "tdmp/hooks.lua"
#include "tdmp/player.lua"

#include "ballistics.lua"

Bullets_FlyBy = {}
Bullets_FlyBy_Sub = {}
Bullets_PlayerDamage = {}

LocalSteamID = TDMP_LocalSteamId()

local weapons = {"shotgun","gun","rifle","rocket"} -- ADD EXTRA WEAPONS IF YOU WANT

local initWeapon = weapons[1]; -- 1 HUH. C# ON TOP

local nextGun = weapons[1]

local _Players = {}

local PlayerKills = {}

local lp

local _1st = nil;

local generatedRandomEquipment = false



function disable_guns()
    SetBool('game.tool.sledge.enabled',false)
    SetBool('game.tool.spraycan.enabled',false)
    SetBool('game.tool.leafblower.enabled',false)
    SetBool('game.tool.blowtorch.enabled',false)
    SetBool('game.tool.plank.enabled',false)
    SetBool('game.tool.wire.enabled',false)
    SetBool('game.tool.extinguisher.enabled',false)
    SetBool('game.tool.turbo.enabled',false)
    SetBool('game.tool.explosive.enabled',false)
    SetBool('game.tool.bomb.enabled',false)
    SetBool('game.tool.pipebomb.enabled',false)
    SetBool('game.tool.steroid.enabled',false)
    SetBool('game.tool.booster.enabled',false)
    SetBool('game.tool.gun.enabled',false)
    SetBool('game.tool.shotgun.enabled',false)
    SetBool('game.tool.rifle.enabled',false)
    SetBool('game.tool.rocket.enabled',false)
    --GUNS
    

    if(nextGun == "shotgun") then
        SetBool('game.tool.shotgun.enabled',true)
    elseif(nextGun == "rifle" and GetBool('savegame.mod.useRifle') == true) then
        SetBool('game.tool.rifle.enabled',true)
    elseif(nextGun == "gun") then
        SetBool('game.tool.gun.enabled',true)
    elseif(nextGun == "rocket") then
        SetBool('game.tool.rocket.enabled',true)
    end

end


function init()
    getRandomEquipment()
end


function getPlayerFromId(player)
    if player then 
        for _, ply in ipairs (TDMP_GetPlayers()) do 
            if ply.steamId == player then return ply end 
        end
    else 
        return nil 
    end
end


function tick(dt)
    disable_guns()
    --registerPlayers(); -- REGISTERS PLAYERS ON A LOOP
    TDMP_Hook_Queue() -- Run this every tick in your script, if you're using Hook_AddListener in your script. This *seem* to be preventing from crashes, when calling hook from different thread(mod)
	Ballistics:Tick()

    lp = getPlayerFromId(TDMP_LocalSteamId())

    if(lp["hp"] <= 0 and generatedRandomEquipment == false) then
        generatedRandomEquipment = true
        getRandomEquipment()
    else
        generatedRandomEquipment = false
    end

end

function getRandomEquipment()
    local nextWep = weapons[math.random(1,#weapons)]
    if(nextGun == "rifle" and GetBool('savegame.mod.useRifle') == false) then
        generatedRandomEquipment();
    end
    if(nextWep == nextGun) then
        getRandomEquipment()
    else
        nextGun = nextWep
    end
end

function getHighestKillRate_Player()
    for i,v in pairs(PlayerKills) do
        highestKills = math.max(unpack(PlayerKills))
        --GET INDEX
        if(v == highestKills) then
            --GET INDEX
            index = i;
            return _Players[1] or _Players[index].nick;
        end
    end
end

function getHighestKillRate()
    for i,v in pairs(PlayerKills) do
        highestKills = math.max(unpack(PlayerKills))
        --GET INDEX
        return highestKills;
    end
end



function draw()
    UiAlign("top")
	UiTranslate(1, 1)
	UiFont("bold.ttf", 24)
	UiColor(1, 1, 1, 1)


    if(lp["hp"] <= 0) then
	    UiText("Next weapon: " .. nextGun)
    else
	    UiText("Your next gun will be shown when you die.")
    end
end