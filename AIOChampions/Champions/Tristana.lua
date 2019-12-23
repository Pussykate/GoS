function GetEnemyHeroes()
    local _EnemyHeroes = {}
    for i = 1, Game.HeroCount() do
        local unit = Game.Hero(i)
        if unit.isEnemy then
            table.insert(_EnemyHeroes, unit)
        end
    end
    return _EnemyHeroes
end 

function GotBuff(unit, buffname)
  for i = 0, unit.buffCount do
    local buff = unit:GetBuff(i)
    if buff.name == buffname and buff.count > 0 then 
      return buff.count
    end
  end
  return 0
end

function CountEnemiesNear(pos, range)
    local pos = pos.pos
	local count = 0
	for i = 1, Game.HeroCount() do 
	local hero = Game.Hero(i)
	local Range = range * range
		if hero.team ~= TEAM_ALLY and GetDistanceSqr(pos, hero.pos) < Range and IsValid(hero) then
		count = count + 1
		end
	end
	return count
end

function LoadScript()

	Menu = MenuElement({type = MENU, id = myHero.networkID, name = myHero.charName})
	Menu:MenuElement({name = " ", drop = {"Version 0.03"}})	
	
	Menu:MenuElement({type = MENU, id = "Combo", name = "Combo"})
	Menu.Combo:MenuElement({id = "UseQ", name = "AutoQ when Explosive Charge", value = true})
	Menu.Combo:MenuElement({id = "UseE", name = "E", value = true})
	Menu.Combo:MenuElement({id = "UseR", name = "(R)Finisher", tooltip = "is(R)Dmg+(E)Dmg+(E)StackDmg > TargetHP than Ult", value = true})
	Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
	
	Menu:MenuElement({type = MENU, id = "Harass", name = "Harass"})
	Menu.Harass:MenuElement({id = "UseQ", name = "AutoQ when Explosive Charge", value = true})
	Menu.Harass:MenuElement({id = "UseE", name = "E", value = true})
	Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("C")})	
	
	Menu:MenuElement({type = MENU, id = "Clear", name = "LaneClear"})	
	Menu.Clear:MenuElement({id = "UseQ", name = "[Q]", value = true})		
	Menu.Clear:MenuElement({id = "UseE", name = "[E] Cannon Minions", value = true}) 		
	Menu.Clear:MenuElement({id = "Mana", name = "Min Mana to LaneClear", value = 40, min = 0, max = 100, identifier = "%"})	
	Menu.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("V")})	
	
	Menu:MenuElement({type = MENU, id = "gap", name = "Gapclose"})
	Menu.gap:MenuElement({name = " ", drop = {"Use AutoW if KillableTarget > UltiRange"}})		
	Menu.gap:MenuElement({id = "UseR", name = "Ultimate Gapclose", value = true})
	Menu.gap:MenuElement({id = "UseW", name = "UseW Back after Gapclose", value = true})
	Menu.gap:MenuElement({id = "Count", name = "(W Back) (Min Enemys near)", value = 1, min = 1, max = 5, step = 1})
	Menu.gap:MenuElement({id = "HP", name = "(W Back) Tristana HP lower than", value = 40, min = 0, max = 100, identifier = "%"})	
	
	Menu:MenuElement({type = MENU, id = "Blitz", name = "Escape"})
	Menu.Blitz:MenuElement({id = "UseW", name = "AutoW ( Blitzcrank Grab )", value = true})

	Menu:MenuElement({type = MENU, id = "Drawings", name = "Drawings"})
	
	--W
	Menu.Drawings:MenuElement({type = MENU, id = "W", name = "Draw W range"})
    Menu.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    Menu.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Menu.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--E
	Menu.Drawings:MenuElement({type = MENU, id = "E", name = "Draw E range"})
    Menu.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = false})       
    Menu.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Menu.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})	
	--R
	Menu.Drawings:MenuElement({type = MENU, id = "R", name = "Draw R range"})
    Menu.Drawings.R:MenuElement({id = "Enabled", name = "Enabled", value = false})
    Menu.Drawings.R:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    Menu.Drawings.R:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	
	
	W = {Range = 900}
	E = {Range = 517 + (8 * myHero.levelData.lvl)}
	R = {Range = 517 + (8 * myHero.levelData.lvl)}	
     	                                           
	if _G.EOWLoaded then
		Orb = 1
	elseif _G.SDK and _G.SDK.Orbwalker then
		Orb = 2
	elseif _G.GOS then
		Orb = 3
	elseif _G.gsoSDK then
		Orb = 4
	end	
	Callback.Add("Tick", function() Tick() end)	

	Callback.Add("Draw", function()
		if myHero.dead then return end
		if Ready(_W) and Menu.Drawings.W.Enabled:Value() then Draw.Circle(myHero, W.Range, Menu.Drawings.W.Width:Value(), Menu.Drawings.W.Color:Value()) end
		if Ready(_E) and Menu.Drawings.E.Enabled:Value() then Draw.Circle(myHero, E.Range, Menu.Drawings.E.Width:Value(), Menu.Drawings.E.Color:Value()) end
		if Ready(_R) and Menu.Drawings.R.Enabled:Value() then Draw.Circle(myHero, R.Range, Menu.Drawings.R.Width:Value(), Menu.Drawings.R.Color:Value()) end

	end)	
end

function Tick()
if MyHeroNotReady() then return end

local Mode = GetMode()
	if Mode == "Combo" then
		if Menu.Combo.comboActive:Value() then
			ComboQ()
			ComboE()
			ComboRKS()
			Finisher()
			GapcloseR()			
		end	
	elseif Mode == "Harass" then
		if Menu.Harass.harassActive:Value() then
			HarassQ()
			HarassE()
		end
	elseif Mode == "Clear" then
		if Menu.Clear.clearActive:Value() then		
			Clear()
		end
	end

	if Menu.Blitz.UseW:Value() then
		AntiBlitz()
	end
	CastWBack()
end

function GetEstacks(unit)

	local stacks = 0
	if GotBuff(unit, "tristanaechargesound") > 0 then
		for i = 1, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and buff.count > 0 and buff.name:lower() == "tristanaecharge" then
				stacks = buff.count
			end
		end
	end
	return stacks
end

function GetStackDmg(unit)

	local total = 0
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 21, 24, 27, 30, 33 })[eLvl]
		local m = ({ 0.15, 0.21, 0.27, 0.33, 0.39 })[eLvl]
		local bonusDmg = (m * myHero.bonusDamage) + (0.15 * myHero.ap)
		total = (raw + bonusDmg) * GetEstacks(unit)
	end
	return total
end

function EDMG(unit)
	local total = 0
	local eLvl = myHero:GetSpellData(_E).level
	if eLvl > 0 then
		local raw = ({ 70, 80, 90, 100, 110 })[eLvl]
		local m = ({ 0.5, 0.7, 0.9, 1.1, 1.3 })[eLvl]
		local bonusDmg = (m * myHero.bonusDamage) + (0.5 * myHero.ap)
		Full = raw + bonusDmg
		total = Full + GetStackDmg(unit)  
	end
	return total
end

function CheckSpell(range)
	for i = 1,Game.HeroCount() do
		local hero = Game.Hero(i)
        if hero.team == TEAM_ENEMY and myHero.pos:DistanceTo(hero.pos) <= range and IsValid(hero) then
			if hero.activeSpell.name == "RocketGrab" then 
				casterPos = hero.pos
				grabTime = hero.activeSpell.startTime * 100
				return true
			end
        end
    end
    return false
end

local timer = {state = false, tick = GetTickCount(), mouse = mousePos, done = false, delayer = GetTickCount()}

function AntiBlitz()	
	if GetTickCount() - timer.tick > 300 and GetTickCount() - timer.tick < 700 then 
		timer.state = false
	end

	local ctc = Game.Timer() * 100
	
	local target = GetTarget(1200)
	if Menu.Blitz.UseW:Value() and CheckSpell(1200) and grabTime ~= nil and Ready(_W) then 
		if myHero.pos:DistanceTo(target.pos) > 350 then
			if ctc - grabTime >= 28 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		else
			if ctc - grabTime >= 12 then
				local jump = myHero.pos:Shortened(target.pos, 700)
				Control.SetCursorPos(jump)
				Control.KeyDown(HK_W)
				Control.KeyUp(HK_W)
			end
		end
	end
end	

function ComboQ()
local target = GetTarget(E.Range)
if target == nil then return end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < E.Range and Menu.Combo.UseQ:Value() and Ready(_Q) then
		if GotBuff(target, "tristanaechargesound") > 0 then	
			Control.CastSpell(HK_Q)
			
		end
	end	
end
	
function ComboE()
local target = GetTarget(E.Range)
if target == nil then return end
	
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < E.Range then	
		if Menu.Combo.UseE:Value() and Ready(_E) then
			Control.CastSpell(HK_E, target)
		end
	end
end
		
function ComboRKS()
local hero = GetTarget(R.Range)
if hero == nil then return end
 	
	if IsValid(hero) and myHero.pos:DistanceTo(hero.pos) < R.Range and Ready(_R) then
	local Rdamage = getdmg("R", hero, myHero)   
		if Rdamage > hero.health then
			Control.CastSpell(HK_R, hero)
		
        end
    end
end

function Finisher()
local target = GetTarget(R.Range)
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < R.Range then	
		if Menu.Combo.UseR:Value() and Ready(_R) and GotBuff(target, "tristanaechargesound") > 0 then
			Edmg = CalcPhysicalDamage(myHero, target, EDMG(target))  
			Rdmg = getdmg("R", target, myHero)	
			totalDMG = (Edmg + Rdmg)
			if totalDMG >= target.health then
				Control.CastSpell(HK_R, target)
			end
		end
	end
end	

function GapcloseR()
local target = GetTarget((R.Range+W.Range+200))
if target == nil then return end
		
	if IsValid(target) and Menu.gap.UseR:Value() and Ready(_R) and Ready(_W) then
		if myHero.pos:DistanceTo(target.pos) > R.Range and myHero.pos:DistanceTo(target.pos) < (R.Range+W.Range-100) then
			local Rdamage = getdmg("R", target, myHero)		
			if Rdamage >= target.health then
				Control.CastSpell(HK_W, target.pos) 
			end
		end
	end
end	

function CastWBack()
	for i, target in pairs(GetEnemyHeroes()) do
		if Ready(_W) and Menu.gap.UseW:Value() and CountEnemiesNear(myHero, 1000) >= Menu.gap.Count:Value() and myHero.health/myHero.maxHealth <= Menu.gap.HP:Value()/100 then
			local jump = myHero.pos:Shortened(target.pos, 700)
			Control.CastSpell(HK_W, jump)
		end
	end
end	
		
function HarassQ()
local target = GetTarget(E.Range)
if target == nil then return end
	if IsValid(target) and myHero.pos:DistanceTo(target.pos) < E.Range and Menu.Harass.UseQ:Value() and Ready(_Q) then
		if GotBuff(target, "tristanaechargesound") > 0 then	
			Control.CastSpell(HK_Q)
			
		end
	end			
end

function HarassE()
local target = GetTarget(E.Range)
if target == nil then return end
    if IsValid(target) and myHero.pos:DistanceTo(target.pos) < E.Range and Menu.Harass.UseE:Value() and Ready(_E) then
		Control.CastSpell(HK_E, target)
		   
	end
end

function Clear()
    for i = 1, Game.MinionCount() do
    local minion = Game.Minion(i)
        if myHero.pos:DistanceTo(minion.pos) < E.Range and minion.team == TEAM_ENEMY and IsValid(minion) then
            local mana_ok = myHero.mana/myHero.maxMana >= Menu.Clear.Mana:Value() / 100
            
            if Menu.Clear.UseE:Value() and mana_ok and Ready(_E) and minion.charName == "SRU_ChaosMinionSiege" then
				Control.CastSpell(HK_E, minion)
            end		

			if Menu.Clear.UseQ:Value() and mana_ok and Ready(_Q) then
				Control.CastSpell(HK_Q)
			end				
        end
    end
end
