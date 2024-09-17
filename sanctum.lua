print("Sanctum ED5 Prayer Flicker")

local API = require("api")
local UTILS = require("utils")


local obj = {7714, 7718}
local range = 25
local types = {5}
local sleep = 50
local prayerOn = false
local distPray = 2
local distPray2 = 1
local firstTime = true
local counter = 0
local projectile = nil
local tickOn = false




local function prayRange()
    if API.Buffbar_GetIDstatus(26044, false).found then
        return
    end
    API.DoAction_Ability("Deflect Ranged", 1, API.OFF_ACT_GeneralInterface_route)
    print("Praying Ranged")
end

local function prayMage()
    if API.Buffbar_GetIDstatus(26041, false).found then
        return
    end
    API.DoAction_Ability("Deflect Magic", 1, API.OFF_ACT_GeneralInterface_route)
    print("Praying Magic")
end

local function prayMelee()
    if API.Buffbar_GetIDstatus(26040, false).found then
        return
    end
    API.DoAction_Ability("Deflect Melee", 1, API.OFF_ACT_GeneralInterface_route)
    print("Praying Melee")
end

local function praySoulSplit()
    if API.Buffbar_GetIDstatus(26033, false).found then
        return
    end
    API.DoAction_Ability("Soul Split", 1, API.OFF_ACT_GeneralInterface_route)
    print("SoulSplit")
end




local vermyx = {
    RANGED = 8185,
    BOSS = 31098,
    BOSS2 = 31099,
}

local kezalam = {
    MAGIC = 8182,
    BOSS = 31100,
    ATTACK_ANIMATION = 36028,
    MAGIC_ANIMATION = 36031,
}

local nakatra = {
    MAGIC = 8182,
    RANGED = 8185,
    BOSS = 31103,
}

local vermyxProjectiles = {vermyx.RANGED}
local kezalamProjectiles = {kezalam.MAGIC}
local nakatraProjectiles = {nakatra.MAGIC, nakatra.RANGED}

local function getNakatraProjectiles()
    local objects = API.GetAllObjArray1(nakatraProjectiles, 30, {5})

    if objects[1] == nil then
        if prayerOn then
            prayerOn = false 
            distPray = 2 
            firstTime = true 
            praySoulSplit()
        end
        return
    end

    if prayerOn then return end

    local dist = math.floor(objects[1].Distance)

    

    if firstTime then
        firstTime = false
        if dist >= 9 then
            distPray = 5
            print("increased distance 3")
        elseif dist >= 8 then
            distPray = 4
            print("increased distance 2")
        elseif dist >= 7 then
            distPray = 3
            print("increased distance 1")
        elseif dist <= 2 then
            distPray = -1
        end
        firstTime = false
    end
    print(dist)

    if distPray == -1 then
        counter = counter + 1
        print("counter = " .. counter)
    end

    if dist > distPray and counter < 6 then 
        return
    end
    
    prayerOn = true
    counter = 0


    if objects[1].Id == nakatra.RANGED then
        prayRange()
    elseif objects[1].Id == nakatra.MAGIC then
        prayMage()
    end 
end

local function getKezalamProjectiles()
    local objects = API.GetAllObjArray1(kezalamProjectiles, 30, {5})
    local anim = API.GetAllObjArray1({kezalam.BOSS}, 20, {1})

    if anim[1] ~= nil then
        if anim[1].Anim == kezalam.ATTACK_ANIMATION then
            if not tickOn then
                prayerOn = true
                tickOn = true
                prayMelee()
                UTILS.countTicks(1)
            end
        end
    end

    if objects[1] == nil then
        if prayerOn then
            prayerOn = false 
            tickOn = false 
            distPray2 = 1 --3.2
            firstTime = true 
            praySoulSplit()
        end
        return
    end


    if prayerOn then return end

    local dist = math.floor(objects[1].Distance)
    
    prayerOn = true

    local moonstone = API.ReadLpInteracting().Name == "Moonstone Obelisk"


    if objects[1].Id == kezalam.MAGIC and not moonstone then
        prayMage()
    end    
end

local function getVermyxProjectiles()
    local objects = API.GetAllObjArray1(vermyxProjectiles, 30, {5})

    if objects[1] == nil then
        if prayerOn then
            prayerOn = false 
            distPray = 2 --3.2
            firstTime = true 
            praySoulSplit()
        end
        return
    end




    if prayerOn then return end

    local dist = math.floor(objects[1].Distance)

    

    if firstTime then
        firstTime = false
        if dist >= 9 then
            distPray = 5
            print("increased distance 3")
        elseif dist >= 8 then
            distPray = 4
            print("increased distance 2")
        elseif dist >= 7 then
            distPray = 3
            print("increased distance 1")
        elseif dist <= 2 then
            distPray = -1
        end
        --local projectile = API.GetProjectileDestination(objects[1])
        firstTime = false
    end
    print(dist)

    if distPray == -1 then
        counter = counter + 1
        print("counter = " .. counter)
    end

    if dist > distPray and counter < 6 then 
        return
    end
    
    prayerOn = true
    counter = 0


    if objects[1].Id == vermyx.RANGED then
        prayRange()
    end    
end


local function getSanctumProjectiles()

    local boss = API.GetAllObjArray1({vermyx.BOSS, vermyx.BOSS2, kezalam.BOSS, nakatra.BOSS}, 30, {1})

    if boss[1] == nil then
        return
    end



    if boss[1].Id == vermyx.BOSS or boss[1].Id == vermyx.BOSS2 then
        getVermyxProjectiles()
    elseif boss[1].Id == kezalam.BOSS then
        getKezalamProjectiles()
    elseif boss[1].Id == nakatra.BOSS then
        getNakatraProjectiles()
    end
end


API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------


    if API.PlayerLoggedIn() and API.GetPrayPrecent() > 0 then
        getSanctumProjectiles()
    end



    API.RandomSleep2(50, 0, 0)
end----------------------------------------------------------------------------------
