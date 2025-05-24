GM.Name = "Pill Pack Hide and Seek"
GM.Author = "Gentoi, Zoom, Dylansonfire, Setnour6, Future, Springzp, Arkierelly"
GM.Email = ""
GM.Website = ""
function GM:Initialize()

    self.BaseClass.Initialize(self)
    SetGlobalInt("Roundsleft", 6)
	SetGlobalBool("FirstRound", true)
end

local meta = FindMetaTable( "Entity" )

function meta:CollisionRulesChanged()
	if not self.m_OldCollisionGroup then self.m_OldCollisionGroup = self:GetCollisionGroup() end
	self:SetCollisionGroup( self.m_OldCollisionGroup == COLLISION_GROUP_DEBRIS and COLLISION_GROUP_WORLD or COLLISION_GROUP_DEBRIS )
	self:SetCollisionGroup( self.m_OldCollisionGroup )
	self.m_OldCollisionGroup = nil
end