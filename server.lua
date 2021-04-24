local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPvip = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_vipmenu")
BMclient = Tunnel.getInterface("vRP_vipmenu","vRP_vipmenu")
Tunnel.bindInterface("vRP_vipmenu",vRPvip)
Proxy.addInterface("vRP_vipmenu",vRPvip)

vipUtils = {}
vipCars = {}
vipTags = {}

local function vip_fixCar(player, choice)
	user_id = vRP.getUserId({player})
	if(vipUtils[user_id] ~= true)then
		vipUtils[user_id] = true
		TriggerClientEvent('vlad:fix', player)
		vRPclient.notify(player, {"~w~[~y~V.I.P - MENU~w~] ~g~Ti-ai reparat Vehiculul !"})
	else
		vRPclient.notify(player, {"~w~[~y~V.I.P - MENU~w~] ~r~Poti folosii aceasta Facilitate peste 5 minute !"})
		return
	end
end

local function vip_revive(player, choice)
	user_id = vRP.getUserId({player})
	if(vipUtils[user_id] ~= true)then
		vipUtils[user_id] = true
		vRPclient.varyHealth(player,{200})
		vRP.varyThirst({user_id, -100})
		vRP.varyHunger({user_id, -100})
		SetTimeout(500, function()
			vRPclient.varyHealth(player,{200})
			vRP.varyThirst({user_id, -100})
			vRP.varyHunger({user_id, -100})
		end)
		vRPclient.notify(player, {"~w~[~y~V.I.P - MENU~w~] ~g~Ti-ai refacut Viata si ti-ai potolit Setea cu Foamea !"})
	else
		vRPclient.notify(player, {"~w~[~y~V.I.P - MENU~w~] ~r~Poti folosii aceasta Facilitate peste 5 minute !"})
		return
	end
end

local function vip_weapons(player, choice)
	user_id = vRP.getUserId({player})
	if(vipUtils[user_id] ~= true)then
		vipUtils[user_id] = true
		vRPclient.giveWeapons(player,{{
			["WEAPON_COMBATPISTOL"] = {ammo=200},
			["WEAPON_ASSAULTRIFLE"] = {ammo=85},
			["WEAPON_PUMPSHOTGUN"] = {ammo=130}
		}})
		vRPclient.notify(player, {"~w~[~y~V.I.P - MENU~w~] ~g~Ai primit Pachetul de Arme !"})
	else
		vRPclient.notify(player, {"~w~[~y~V.I.P - MENU~w~] ~r~Poti folosii aceasta Facilitate peste 5 minute !"})
		return
	end
end

local function vip_spawnCar(player, choice)
	BMclient.spawnVIPCar(player, {})
end

vRP.registerMenuBuilder({"main", function(add, data)
	local user_id = vRP.getUserId({data.player})
	if user_id ~= nil then
		local choices = {}
		if vRP.hasGroup({user_id, "viptoxic"}) then
			choices["Meniu V.I.P⚜️"] = {function(player,choice)
				vRP.buildMenu({"⚜️Meniu V.I.P⚜️", {player = player}, function(menu)
					menu.name = "⚜️Meniu V.I.P⚜️"
					menu.css={top="75px",header_color="rgba(230, 201, 14,0.75)"}
					menu.onclose = function(player) vRP.openMainMenu({player}) end -- nest menu
					menu["🔧 Repară Mașina 🔧"] = {vip_fixCar,"🔧 > Repara-ti vehiculul."}
					menu["💊 Refă Viața 💉"] = {vip_revive,"🏥 > Refati viata."}
					menu["🔪 Pachet de Arme 🔪"] = {vip_weapons,"🔪 > Da-ti un pachet de arme."}
					menu["🏎️ Masină V.I.P 🏎️"] = {vip_spawnCar,"🏎️ > Spawneaza o Masina V.I.P."}
					vRP.openMenu({player,menu})
				end})
			end, "⚜️Facilitati V.I.P⚜️"}
		end
		add(choices)
	end
end})

function vRPvip.denyVIPCarDriving()
	user_id = vRP.getUserId({source})
	if not(vRP.hasGroup({user_id, "viptoxic"}))then
		BMclient.denyVIPCarDriving(source, {})
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(300000)
		users = vRP.getUsers({})
		for i, v in pairs(users) do
			if(vRP.hasGroup({i, "viptoxic"})) and (vipUtils[i] == true)then
				vipUtils[i] = nil
				vRPclient.notify(v, {"~w~[~y~V.I.P - MENU~w~] Acum iti poti folosii Facilitatiile de ~y~V.I.P ~w~ !"})
			end
		end
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id, source)
	if(vipCars[user_id] ~= nil)then
		BMclient.deleteVIPCar(-1, {vipCars[user_id]})
		vipCars[user_id] = nil
	end
	if(vipTags[user_id] ~= nil)then
		vipTags[user_id] = nil
	end
end)

RegisterNetEvent("baseevents:enteringVehicle")
AddEventHandler("baseevents:enteringVehicle", function(theVehicle, theSeat, vehicleName)
	thePlayer = source
	user_id = vRP.getUserId({thePlayer})
	if(theSeat == -1) and (vehicleName == "x6m")then
		if not(vRP.hasGroup({user_id, "viptoxic"}))then
			BMclient.teleportOutOfCar(thePlayer, {theVehicle})
			vRPclient.notify(thePlayer, {"~w~[~y~V.I.P - MENU~w~] ~r~Nu poti conduce Masina de ~y~V.I.P ~r~!"})
		end
	end
end)

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(theVehicle, theSeat, vehicleName)
	thePlayer = source
	user_id = vRP.getUserId({thePlayer})
	if(theSeat == -1) and (vehicleName == "x6m")then
		if not(vRP.hasGroup({user_id, "viptoxic"}))then
			BMclient.teleportOutOfCar(thePlayer, {theVehicle})
			vRPclient.notify(thePlayer, {"~w~[~y~V.I.P - MENU~w~] ~r~Nu poti conduce Masina de ~y~V.I.P ~r~!"})
		end
	end
end)