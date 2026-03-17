local ServerScriptService = game:GetService("ServerScriptService")

local ActionSession = require(ServerScriptService.Server.Utilities.Combat.ActionSession)

local Block = {}
Block.__index = Block

Block.Anims = 124706259758375
local BlockSessions = {}

function Block:Start(char)
    local session = ActionSession.new({
        attacker = char,
        actionName = "Block",
        actionType = "Misc",
        states = {
            attackerStates = {"Blocking"}
        }
    })

    session:Start()

    session:PlayAndAddAnimation(char, self.Anims, {Priority = 2})

    BlockSessions[char] = session
end

function Block:Stop(char)
    if BlockSessions[char] then
        BlockSessions[char]:Stop(true)
        BlockSessions[char] = nil
    end
end

return Block