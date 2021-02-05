---
--- Generated by Luanalysis
--- Created by Lyr.
--- DateTime: 1/8/2021 5:30 PM
---

require "/scripts/companions/util.lua"
require "/scripts/vec2.lua"

--[[
  CFG:    pool        MonsterType[]
          poolRepeat  boolean             false
          count       integer
          params      MonsterParameters
          friendly    boolean             false
          useDataPos  boolean             false     use data as damageRequest type to get pos/entity pos from targetEntityId
  INPUT:  position or targetEntityId    if useDataPos
--]]


if not Modsys then error("This script isn't supposed to be require'd yourself lol.") end
---@type Modsys, Action
local Modsys, Action = Modsys, Action

---@class SpawnMonsters : Action
local SpawnMonsters = Action.new()

function SpawnMonsters:init()
  self.cfg.friendly = self.cfg.friendly == nil or self.cfg.friendly   -- default true
  local defaultParams = {
    aggressive = true,
    damageTeam = self.cfg.friendly and entity.damageTeam().team,
    damageTeamType = self.cfg.friendly and entity.damageTeam().type
  }
  self.params = sb.jsonMerge(defaultParams, self.cfg.params)
end

function SpawnMonsters:update(dt)
  -- persistence etc
end

function SpawnMonsters:uninit()
  -- normal uninit
end


local function randomChoices(options, count, cannotRepeat)
  if count > #options and cannotRepeat then cannotRepeat = false end
  local result = {}
  local opts = copy(options)
  while (#result < count) do
    local pos = math.random(#opts)
    table.insert(result, cannotRepeat and table.remove(opts, pos) or opts[pos])
  end
  return result
end

function SpawnMonsters:run(data)
  -- Ephemeral-specific anti-chaining
  if status.statusProperty("kf.isEphemeral", false) and status.resource("health") < 0.05 then return end    -- health sometimes tend to be 0.0166667 on death here

  if #self.cfg.pool > 0 then
    local spawnPos = self.cfg.useDataPos and (data.position or world.entityPosition(data.targetEntityId)) or mcontroller.position()

    for _,name in ipairs(randomChoices(self.cfg.pool, self.cfg.count, not self.cfg.poolRepeat)) do
      local monsterPoly = root.monsterMovementSettings(name).standingPoly
      local pos = findCompanionSpawnPosition(
          world.xwrap(vec2.add(spawnPos, {math.random(-2, 2), math.random(-1, 3)})),
          monsterPoly
      )
      world.spawnMonster(
          name,
          pos,
          self.params
      )
    end
  end
end
