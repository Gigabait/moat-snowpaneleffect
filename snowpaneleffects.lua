
-- convar to enable/disable snow for users
if ( not ConVarExists( "enable_snoweffect" ) ) then
    CreateClientConVar( "enable_snoweffect", 1, true, true )
end

-- draw circle function from gmod wiki poly page
function draw.Circle( x, y, radius, seg )
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is need for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end

local function DrawSnow(pnl, w, h, amt)
    local snowtbl = pnl.snowtbl
    for i = 1, amt do
        snowtbl[i] = snowtbl[i] or {}
        if (not snowtbl[i][1]) then snowtbl[i][1] = math.random(-h*1.5, 0) end
        if (snowtbl[i][1] >= h) then
            snowtbl[i][5] = snowtbl[i][5] - (70 * FrameTime())
            snowtbl[i][3] = Lerp(1 * FrameTime(), snowtbl[i][3], 0)
            if (snowtbl[i][5] <= 0) then
                snowtbl[i][1] = math.random(-h*1.5, 0)
                snowtbl[i][2] = math.random(w)
                snowtbl[i][3] = math.random(2,5)
                snowtbl[i][4] = math.random(6,9)
                snowtbl[i][5] = 100
            end
        else
            snowtbl[i][1] = math.Approach(snowtbl[i][1], h, 80 * FrameTime())
            snowtbl[i][2] = snowtbl[i][2] or math.random(w)
            snowtbl[i][3] = snowtbl[i][3] or math.random(3,5)
            snowtbl[i][4] = snowtbl[i][4] or math.random(5,8)
            snowtbl[i][5] = snowtbl[i][5] or 100
        end
        surface.SetDrawColor(230, 230, 250, 200)
        draw.NoTexture()
        draw.Circle( snowtbl[i][2], snowtbl[i][1], snowtbl[i][3], snowtbl[i][4] )
    end
end

local function createFestive(pnl, x, y, w, h)
    pnl.festivepanel = vgui.Create("DPanel",pnl)
    pnl.festivepanel:SetSize(w,h)
    pnl.festivepanel:SetPos(x,y)
    pnl.festivepanel.snowtbl = {}
    pnl.festivepanel.Paint = function(s,w,h)
        if (tobool(GetConVar("enable_snoweffect"):GetInt())) then
            DrawSnow(s, w, h, 50)
        end
    end
end


local pmeta = FindMetaTable("Panel")

function pmeta:SetFestive(x, y, w, h)
    if (not IsValid(self.festivepanel) and tobool(GetConVar("enable_snoweffect"):GetInt())) then
        createFestive(self, x, y, w, h)
    end
end
