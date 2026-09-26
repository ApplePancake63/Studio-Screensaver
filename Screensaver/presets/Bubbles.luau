local a = {}
a.__index = a
--\
local run_service=game:GetService("RunService")
local http_service=game:GetService("HttpService")
--|
local gui:ScreenGui=script.Parent.Parent.gui
local vw=gui.AbsoluteSize
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	vw=gui.AbsoluteSize
end)
--/

--\
local get_data:BindableFunction=script.Parent.Parent.GetData
local set_data:BindableFunction=script.Parent.Parent.SetData
local bubbles=Instance.new("Folder",gui)
bubbles.Name="bubbles_"..http_service:GenerateGUID(false)
bubbles:SetAttribute("MaxCount",get_data:Invoke("BubblesMaxCount")or 16)
bubbles:GetAttributeChangedSignal("MaxCount"):Connect(function()
	a.count=bubbles:GetAttribute("MaxCount")
	set_data:Invoke("BubblesMaxCount",a.count)
end)
--/

--\
type vector2_simplified={x:number,y:number}
type bubble={
	image:ImageLabel,
	velocity:vector2_simplified,
	position:vector2_simplified,
	size:number,
}
type p={
	g:vector2_simplified,
	smax:number,
	smin:number,
}
--|
a.count=16
a.tmin=1/30
a.stored={}::{bubble}
a.min_start_speed=160
a.max_start_speed=320
a.min_start_angle=285
a.max_start_angle=345
a.max_delay=0.5
a.spawn_delay=a.max_delay
a.p={
	--d=0.85,
	b=2,
	smax=320,
	smin=160,
	iter=2,
}::p
--|
local pi=math.pi
local cos=math.cos
local sin=math.sin
local rad=math.rad
local acos=math.acos
local sqrt=math.sqrt
local function magnitude(x,y)
	return sqrt(x^2+y^2)
end
local function abs(a)
	return sqrt(a*a)
end
local function dot(x1,y1,x2,y2)
	return x1*x2+y1*y2
end
local function clamp_speed(s:vector2_simplified)
	local m=magnitude(s.x,s.y)
	if m<a.p.smax then return s end
	local d=a.p.smax/m
	return {x=s.x*d,y=s.y*d}
end
local function create_bubble(size)
	local image=Instance.new("ImageLabel",bubbles)
	image.BackgroundTransparency=1
	image.Image="rbxassetid://1249690853"
	image.ImageTransparency=0
	image.AnchorPoint=Vector2.new(0.5,0.5)
	image.ImageTransparency=0.6
	local ratio=Instance.new("UIAspectRatioConstraint",image)
	local bubble:bubble={
		image=image,
		velocity={x=0,y=0},
		position={x=0,y=0},
		size=0,
	}
	return bubble
end
--/

--\
function a:add_bubble(s)
	local i=#self.stored
	local bubble:bubble?=nil
	bubble=i>0 and table.remove(a.stored,i)or create_bubble()
	if bubble.size~=s then bubble.size=s end
	local start_speed=math.random(self.min_start_speed,self.max_start_speed)
	local start_angle=rad(math.random(self.min_start_angle,self.max_start_angle))
	bubble.velocity={x=cos(start_angle)*start_speed,y=sin(start_angle)*start_speed}::vector2_simplified
	bubble.position={x=0,y=0}::vector2_simplified
	bubble.image.Visible=true
	bubble.image.ImageColor3=Color3.fromHSV(math.random(),1,1)
	self.used[#self.used+1]=bubble
	return bubble
end
function a:on(main_folder)
	local self = setmetatable({},a)

	self.size=vw.X>vw.Y and vw.Y*0.2 or vw.X*0.2
	self.used={}::{bubble}


	self.con=run_service.Heartbeat:Connect(function(d)
		d=d<=self.tmin and d or self.tmin
		if self.spawn_delay>0 and #self.used<self.count then self.spawn_delay-=d elseif #self.used<self.count then
			self.spawn_delay=self.max_delay
			local bubble:bubble=self:add_bubble(self.size)
		end
		for i, v in self.used do
			local vel=v.velocity
			--self.used[i].velocity={x=vel.x*self.p.d^d,y=vel.y*self.p.d^d}
			self.used[i].velocity=clamp_speed(v.velocity)
			self.used[i].position={x=v.position.x+v.velocity.x*d,y=v.position.y+v.velocity.y*d}
		end
		local hsize=self.size/2
		for _=1,self.p.iter do
			for i, v in self.used do
				local pos_x,pos_y=v.position.x,v.position.y
				local vel_x,vel_y=v.velocity.x,v.velocity.y
				self.used[i].velocity.x=(pos_x>vw.X-hsize or pos_x<hsize) and -vel_x or vel_x
				self.used[i].velocity.y=(pos_y>vw.Y-hsize or pos_y<hsize) and -vel_y or vel_y
				self.used[i].position.x=pos_x>vw.X-hsize and vw.X-hsize or pos_x<hsize and hsize or pos_x
				self.used[i].position.y=pos_y>vw.Y-hsize and vw.Y-hsize or pos_y<hsize and hsize or pos_y
			end
			for i, bubble in self.used do
				local px,py=bubble.position.x,bubble.position.y
				local vx,vy=bubble.velocity.x,bubble.velocity.y
				for j = i+1, #self.used do
					local second=self.used[j]
					local sx,sy=second.position.x,second.position.y
					local bx,by=second.velocity.x,second.velocity.y
					local diff={x=sx-px,y=sy-py}
					local dist=magnitude(diff.x,diff.y)
					if dist>self.size then continue end
					local n={x=diff.x/dist,y=diff.y/dist}
					local amul=(self.size-dist)*0.5
					local a={x=n.x*amul,y=n.y*amul}
					self.used[i].position={x=px-a.x,y=py-a.y}
					self.used[j].position={x=sx+a.x,y=sy+a.y}
					local vn=dot(bx-vx,by-vy,n.x,n.y)
					if vn>=0 then continue end
					local imp = -(1+self.p.b)*vn*0.5
					self.used[i].velocity = {x=vx-n.x*imp,y=vy-n.y*imp}
					self.used[j].velocity = {x=bx+n.x*imp,y=by+n.y*imp}
				end
			end
		end
		for _, v in self.used do
			v.image.Position=UDim2.fromOffset(v.position.x,vw.Y-v.position.y)
			if v.image.Size.X~=self.size then v.image.Size=UDim2.fromOffset(self.size,self.size) end
		end
	end)
	return self
end
--|
function a:off()
	for _, v in self.used do
		a.stored[#a.stored+1]=v
		v.image.Visible=false
	end
	self.con:Disconnect()
end
--|
return a
--/