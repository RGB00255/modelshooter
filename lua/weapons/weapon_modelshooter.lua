/*******************************
*   This is my first SWEP :)   *
*        By: Gman1255          *
*******************************/

SWEP.PrintName = "Model Shooter"
SWEP.Author = "Gman1255"
SWEP.Instructions = "Shoot props without remorse"
SWEP.Spawnable = true
SWEP.HoldType = "pistol"
SWEP.AdminOnly = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom	= false
SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.FiresUnderwater = true
SWEP.Category = "Gman1255's Cache"

SWEP.Primary.Sound = "Weapon_Pistol.Single"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.05

SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

-- Default model (Explosive Barrel) --
local model = "models/props_c17/oildrum001_explosive.mdl"

function SWEP:Initialize() 
	util.PrecacheSound(self.Primary.Sound) 
    self:SetWeaponHoldType(self.HoldType)
	self:DefaultReload(376)
end 

-- This is what happens when the primary attack button is pressed (Default: leftmouse) --
function SWEP:PrimaryAttack()
	self:ShootModel(model, self.Primary.Sound)
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

-- This is what happens when the secondary attack button is pressed (Default: rightmouse) --
function SWEP:SecondaryAttack()
	local ent = self.Owner:GetEyeTrace().Entity
	if(ent:IsValid()) then 
		if(ent:GetModel() != model) then
			model = ent:GetModel()
			self.Owner:ChatPrint("Model Set: " .. model)
			ent:EmitSound("Weapon_PhysCannon.Pickup")
			self:EmitSound("Weapon_Pistol.Reload")
			self:SetNetworkedBool("reloading", true)
			self:SetVar("reloadtimer", CurTime() + 0.3)
			self:SendWeaponAnim(ACT_VM_RELOAD)
			if(SERVER) then ent:Remove() end
			local ed = EffectData()
				ed:SetOrigin(ent:GetPos())
				ed:SetEntity(ent)
			util.Effect("entity_remove", ed, true, true)
		end
	end
end

-- This function shoots the selected model --
function SWEP:ShootModel(Model, Sound)
	local tr = self.Owner:GetEyeTrace()
	self.Weapon:EmitSound(Sound)
	self.BaseClass.ShootEffects(self)
	if(!SERVER) then return end
	local ent = ents.Create("prop_physics")
	ent:SetModel(Model)
	ent:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 16))
	ent:SetAngles(self.Owner:EyeAngles())
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	local shotLength = tr.HitPos:Length()
	phys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * math.pow (shotLength, 7))
	cleanup.Add(self.Owner, "props", ent)
	undo.Create("Shot model")
		undo.AddEntity(ent)
		undo.SetPlayer(self.Owner)
	undo.Finish()
end
