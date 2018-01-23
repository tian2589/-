-- Generated from template
require('playerinit')



if Snake == nil then
	Snake = class({})
end

temp_flag=0 --旗帜变量，用来标记用户是否初始化

function PrecacheEveryThingFromKV( context )
	local kv_files = {"scripts/npc/npc_units_custom.txt","scripts/npc/npc_abilities_custom.txt","scripts/npc/npc_heroes_custom.txt","scripts/npc/npc_abilities_override.txt","npc_items_custom.txt"}
	for _, kv in pairs(kv_files) do
		local kvs = LoadKeyValues(kv)
		if kvs then
			print("BEGIN TO PRECACHE RESOURCE FROM: ", kv)
			PrecacheEverythingFromTable( context, kvs)
		end
	end
    print("done loading shiping")
end

function PrecacheEverythingFromTable( context, kvtable)
	for key, value in pairs(kvtable) do
		if type(value) == "table" then
			PrecacheEverythingFromTable( context, value )
		else
			if string.find(value, "vpcf") then
				PrecacheResource( "particle",  value, context)
				print("PRECACHE PARTICLE RESOURCE", value)
			end
			if string.find(value, "vmdl") then 	
				PrecacheResource( "model",  value, context)
				print("PRECACHE MODEL RESOURCE", value)
			end
			if string.find(value, "vsndevts") then
				PrecacheResource( "soundfile",  value, context)
				print("PRECACHE SOUND RESOURCE", value)
			end
		end
	end
end

function Precache( context )
	print("BEGIN TO PRECACHE RESOURCE")
	local time = GameRules:GetGameTime()
	PrecacheEveryThingFromKV( context )
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
	time = time - GameRules:GetGameTime()
	print("DONE PRECACHEING IN:"..tostring(time).."Seconds")
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = Snake()
	GameRules.AddonTemplate:InitGameMode()
end

function Snake:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	--ListenToGameEvent('entity_killed', Dynamic_Wrap（Snake,'OnEntityKilled'）,self)--监听事件-小怪被击杀
	ListenToGameEvent('entity_killed', Dynamic_Wrap (Snake, 'OnEntityKilled'), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(Snake, "OnNPCSpawned"), self)--监听事件-npc被出生

	--玩家初始化
    if temp_flag == 0 then
       initplayerstats()
       temp_flag = 1
    end
end

-- Evaluate the state of the game
function Snake:OnThink()

	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

--被击杀事件
function Snake:OnEntityKilled ( keys )

    local unit = EntIndexToHScript(keys.entindex_killed)
    local label=unit:GetContext("name")
    
	--判断是什么，羊，牛，小火人
	--如果是，重新刷新一只本体
	--或者增加一个指数，计时，刷新怪物后，自我循环。 

    if label then

       if label == "yang" then
    	createunit("yang")
       end

       if label == "niu" then
    	createunit("niu")
       end

       if label == "huoren" then
    	createunit("huoren")
       end
    end
end

function Snake:OnNPCSpawned(keys)
    local unit = EntIndexToHScript(keys.entindex)
    
    --判断是否是英雄
    if unit:IsHero() then
       --[[local playerid=unit:GetPlayerOwnerID()
             PlayerStats[playerid]['group']={}
             PlayerStats[playerid]['group_pointer']=1
             PlayerStats[playerid]['group'][PlayerStats[playerid]['group_pointer']=unit]]

       GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("1"), 
        function()
         	local chaoxiang=unit:GetForwardVector()
         	print(chaoxiang)
         	local position=unit:GetAbsOrigin()            
         	unit:MoveToPosition(position+chaoxiang*500)--按照朝向移动
         	
            local aroundit=FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil,
                      	                     100,
                                  		     DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                              			     DOTA_UNIT_TARGET_ALL,
                              			     DOTA_UNIT_TARGET_FLAG_NONE,
                              			     FIND_ANY_ORDER,
                              			     false)
            for k,v in pairs(aroundit) do
            	local label=v:GetContext("name")
            	if label then
            		if label == "yang" then
            			v:ForceKill(true)
            			--createbaby(playerid)
            		end
                    if label == "niu" then
            			v:ForceKill(true)
            			--createbaby(playerid)
            			--createbaby(playerid)
            		end
            	end
            end
         	return 0.5
        end,0)
    end
end