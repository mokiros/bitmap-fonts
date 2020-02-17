--------------------------------------------------------------------------------------
-- File name: Drawer.lua
-- Description: Creates Frame and returns an object with functions to render given font to that frame
--------------------------------------------------------------------------------------

-- Shared metatable for functions
local mt = {
	SetText = function(self,str,a)
		assert(type(str)=='string',('Invalid argument #1 (string expected, got %s)'):format(type(str)))
		self.ImageLabels = {}
		self.Frame:ClearAllChildren()
		local LineHeight = self.Data.common.lineHeight
		local base = self.Data.common.base
		local Cursor = Vector2.new(0,0)
		local chars = self.Data.char
		local prev
		for position,codepoint in utf8.codes(str) do
			if codepoint == 10 then
				Cursor = Vector2.new(0,Cursor.Y+LineHeight)
			else
				local char = chars[codepoint] or chars[-1] or error('Invalid character: '..utf8.char(codepoint))
				local il = Instance.new("ImageLabel")
				il.BackgroundTransparency = 1
				il.Size = UDim2.new(0,char.width,0,char.height)
				local kerning = self.Data.kerning[codepoint]
				kerning = (kerning and kerning.first == prev) and kerning.amount or 0
				il.Position = UDim2.new(0,Cursor.X+char.xoffset+kerning,0,Cursor.Y+char.yoffset)
				il.Image = self.Data.page[char.page].asset_url
				il.ImageColor3 = self.TextColor
				il.ImageRectOffset = Vector2.new(char.x,char.y)
				il.ImageRectSize = Vector2.new(char.width,char.height)
				il.Parent = self.Frame
				table.insert(self.ImageLabels,il)
				Cursor = Cursor + Vector2.new(char.xadvance,0)
			end
			prev = codepoint
		end
	end,
    SetFormattedText = function(self,t)
        assert(type(t)=='table',('Invalid argument #1 (table expected, got %s)'):format(type(t)))
		self.ImageLabels = {}
		self.Frame:ClearAllChildren()
	end,
	Update = function(self)
		
	end,
	SetColor = function(self,c3)
		for _,il in pairs(self.ImageLabels) do
			il.ImageColor3 = c3
		end
		self.TextColor = c3
	end
}
mt.__index = mt

return function(t)
	assert(type(t)=='table',('Invalid argument #1 (table expected, got %s)'):format(type(t)))
	assert(t.page and t.page[0] and t.page[0].asset_url,'Table is not a parsed .fnt file or has missing asset_url')
	local Frame = Instance.new("Frame")
	Frame.BackgroundTransparency = 1
	local obj = setmetatable({
		Data = t,
		Frame = Frame,
		ImageLabels = {},
		TextColor = Color3.new(0,0,0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = false,
		Text = {},
		RawText = ''
	},mt)
	obj.ChangedConnection = Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if obj.TextWrapped then
			obj:Update()
		end
	end)
	return obj
end