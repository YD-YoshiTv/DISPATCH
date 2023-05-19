ESX = exports.es_extended:getSharedObject()

RegisterServerEvent('yd:dispatch:getpolice', function(code)
	local players = ESX.GetPlayers()
	for i=1, #players do
		local xPlayer = ESX.GetPlayerFromId(players[i])
		if xPlayer.job.name == Config.Jobname then
            TriggerClientEvent('yd:dispatch:send', xPlayer.source, code)
        end
	end
end)