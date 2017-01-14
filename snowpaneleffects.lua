
-- convar to enable/disable snow for users
if ( not ConVarExists( "enable_snoweffect" ) ) then
    CreateClientConVar( "enable_snoweffect", 1, true, true )
end

local Enabled = GetConVar( "enable_snoweffect" )

local NEGPI2 = math.pi * -2
local snowmaxstartheight = -1.5
local snowflakeminsize = 0.1
local segmentslowerbound,segmentsupperbound = 6,9
local radiuslowerbound,radiusupperbound = 2,5
local snowflakefallspeed = 80
local snowflakeshrinkspeed = 1

local Segments = {}

-- Cache segments
local function GenerateSegments(seg)
  Segments[seg] = {}

  for i = 1, seg do
      local a = (i / seg) * NEGPI2
      Segments[seg][i] = {math.sin( a ),math.cos( a )}
  end

  return Segments[seg]
end

-- draw circle function from gmod wiki poly page
function draw.Circle( x, y, radius, seg )

  local cir = {}
  local segments = Segments[seg] or GenerateSegments(seg)

  for i = 1,seg do
    cir[i] = {x = x + segments[i][1] * radius, y = y + segments[i][2] * radius}
  end

  surface.DrawPoly( cir )
end

local function DrawSnow(pnl, w, h, amt)
    local snowtbl = pnl.snowtbl

    surface.SetDrawColor(230, 230, 250, 200)
    draw.NoTexture()

    for i = 1, amt do
        if (snowtbl[i][1] >= h) then
            -- Decrease size every frame while at bottom
            snowtbl[i][3] = Lerp(snowflakeshrinkspeed * FrameTime(), snowtbl[i][3], 0)

            -- Reset Snowflake
            if (snowtbl[i][3] <= snowflakeminsize) then
                snowtbl[i][1] = math.random(h * snowmaxstartheight,0)
                snowtbl[i][2] = math.random(w)
                snowtbl[i][3] = math.random(radiuslowerbound,radiusupperbound)
                snowtbl[i][4] = math.random(segmentslowerbound,segmentsupperbound)
            end
        else
            snowtbl[i][1] = math.Approach(snowtbl[i][1], h, snowflakefallspeed * FrameTime())
        end

        draw.Circle( snowtbl[i][2], snowtbl[i][1], snowtbl[i][3], snowtbl[i][4] )
    end
end

local function createFestive(pnl,amt , x, y, w, h)
    pnl.festivepanel = vgui.Create("DPanel",pnl)
    pnl.festivepanel:SetSize(w,h)
    pnl.festivepanel:SetPos(x,y)
    pnl.festivepanel.snowtbl = {}

    -- Setup Snowtbl
    for i = 1,amt do
      pnl.festivepanel.snowtbl[i] = {math.random(h * snowmaxstartheight, 0),math.random(w),math.random(radiuslowerbound,radiusupperbound),math.random(segmentslowerbound,segmentsupperbound)}
    end

    pnl.festivepanel.Paint = function(s,festivew,festiveh)
        if Enabled:GetBool() then
            DrawSnow(s, festivew, festiveh, amt)
        end
    end
end


local pmeta = FindMetaTable("Panel")

function pmeta:SetFestive(amt, x, y, w, h)

    amt = amt or 50
    x = x or 0
    y = y or 0
    w = w or self:GetWide()
    h = h or self:GetTall()

    if (not IsValid(self.festivepanel)) and Enabled:GetBool() then
        createFestive(self, amt, x, y, w, h)
    end
end
