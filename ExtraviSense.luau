if not game:IsLoaded() then game.Loaded:Wait() end
  local TweenService = game:GetService("TweenService")
  local UserInputService = game:GetService("UserInputService")
  local CoreGui = game:GetService("CoreGui")
  local HttpService = game:GetService("HttpService")
  local RunService = game:GetService("RunService")
  local Players = game:GetService("Players")
  local Lighting = game:GetService("Lighting")
  local SoundService = game:GetService("SoundService")
  local VirtualInputManager = game:GetService("VirtualInputManager")
  local LocalPlayer = Players.LocalPlayer
  local Camera = workspace.CurrentCamera
  local Mouse = LocalPlayer:GetMouse()
  local function rgbToHex(colorInput)
    return string.format("%02X%02X%02X", math.floor(colorInput.R * 255), math.floor(colorInput.G * 255), math.floor(colorInput.B * 255))
  end
  local function roundNumber(n, mult)
    mult = mult or 1
    return math.floor((n / mult) + 0.5) * mult
  end
  local Library = { Flags = {}, Elements = {} }
  local Theme = {
  MainBG = Color3.fromRGB(20, 20, 20),
  SidebarBG = Color3.fromRGB(9, 9, 9),
  SectionBG = Color3.fromRGB(21, 21, 21),
  Border = Color3.fromRGB(2, 2, 2),
  Text = Color3.fromRGB(220, 220, 220),
  TextDark = Color3.fromRGB(150, 150, 150),
  TextWarn = Color3.fromRGB(146, 146, 43),
  Accent1 = Color3.fromRGB(119, 156, 39),
  Accent2 = Color3.fromRGB(180, 180, 180),
  InputBg = Color3.fromRGB(23, 23, 23),
  DropdownBg = Color3.fromRGB(20, 20, 20),
  }
  function Library:CreateIndicator(id, text, colorValue, layoutOrder, icon)
    local indicatorState = false
    local indicatorColor = colorValue or Theme.Accent1
    local indicatorText = text
    local indicatorIcon = icon
    return {
    Toggle = function(self, isEnabled)
      indicatorState = isEnabled
      if indicatorState then
        Indicators.Set(id, indicatorText, indicatorColor, layoutOrder, indicatorIcon)
      else
        Indicators.Remove(id)
      end
    end,
    SetText = function(self, newText)
      indicatorText = newText
      if indicatorState then
        Indicators.Set(id, indicatorText, indicatorColor, layoutOrder, indicatorIcon)
      end
    end,
    SetColor = function(self, newColor)
      indicatorColor = newColor
      if indicatorState then
        Indicators.Set(id, indicatorText, indicatorColor, layoutOrder, indicatorIcon)
      end
    end,
    SetIcon = function(self, newIcon)
      indicatorIcon = newIcon
      if indicatorState then
        Indicators.Set(id, indicatorText, indicatorColor, layoutOrder, indicatorIcon)
      end
    end,
    GetState = function(self)
      return indicatorState
    end
    }
  end
  local function colorToHSV(colorValue)
    local hue, sat, v = colorValue:ToHSV()
    return hue * 360, sat, v
  end
  local function createGradient(r, g, b, upsideDown)
    local stepOffset = 8
    local darkColor = Color3.fromRGB(math.clamp(r - stepOffset, 0, 255), math.clamp(g - stepOffset, 0, 255), math.clamp(b - stepOffset, 0, 255))
    local midColor = Color3.fromRGB(r, g, b)
    local lightColor = Color3.fromRGB(math.clamp(r + stepOffset, 0, 255), math.clamp(g + stepOffset, 0, 255), math.clamp(b + stepOffset, 0, 255))
    if upsideDown then
      return ColorSequence.new{
      ColorSequenceKeypoint.new(0, lightColor),
      ColorSequenceKeypoint.new(0.25, midColor),
      ColorSequenceKeypoint.new(0.5, darkColor),
      ColorSequenceKeypoint.new(0.75, midColor),
      ColorSequenceKeypoint.new(1, lightColor)
      }
    else
      return ColorSequence.new{
      ColorSequenceKeypoint.new(0, darkColor),
      ColorSequenceKeypoint.new(0.25, midColor),
      ColorSequenceKeypoint.new(0.5, lightColor),
      ColorSequenceKeypoint.new(0.75, midColor),
      ColorSequenceKeypoint.new(1, darkColor)
      }
    end
  end
  local function makeDraggable(topbarobject, object)
    local isDragging, dragInputObj, dragStartPosition, dragStartFramePos = nil, nil, nil, nil
    topbarobject.InputBegan:Connect(function(input)
      if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStartPosition = input.Position
        dragStartFramePos = object.Position
        input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then isDragging = false end
        end)
      end
    end)
    topbarobject.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInputObj = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
      if input == dragInputObj and isDragging then
        local dragDelta = input.Position - dragStartPosition
        object.Position = UDim2.new(dragStartFramePos.X.Scale, dragStartFramePos.X.Offset + dragDelta.X, dragStartFramePos.Y.Scale, dragStartFramePos.Y.Offset + dragDelta.Y)
      end
    end)
  end
  function Library:CreateWindow(title)
    local Window = { Tabs = {}, CurrentTabIndex = 0, CurrentTab = nil }
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ExtraviSense"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
  pcall(function() screenGui.Parent = (gethui and gethui()) or CoreGui end)
    if not screenGui.Parent then
      local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
    if playerGui then screenGui.Parent = playerGui end
    end
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Theme.MainBG
    mainFrame.BorderMode = Enum.BorderMode.Inset
    mainFrame.BorderColor3 = Color3.fromRGB(12, 12, 12)
    mainFrame.BorderSizePixel = 1
    mainFrame.Position = UDim2.new(0.5, -330, 0.5, -280)
    mainFrame.Size = UDim2.new(0, 660, 0, 560)
    local outerBorder = Instance.new("Frame")
    outerBorder.Parent = mainFrame
    outerBorder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    outerBorder.BorderSizePixel = 0
    outerBorder.Position = UDim2.new(0, 1, 0, 1)
    outerBorder.Size = UDim2.new(1, -2, 1, -2)
    local innerBorder = Instance.new("Frame")
    innerBorder.Parent = mainFrame
    innerBorder.BackgroundColor3 = Theme.MainBG
    innerBorder.BorderMode = Enum.BorderMode.Inset
    innerBorder.BorderColor3 = Color3.fromRGB(60, 60, 60)
    innerBorder.BorderSizePixel = 1
    innerBorder.Position = UDim2.new(0, 3, 0, 3)
    innerBorder.Size = UDim2.new(1, -6, 1, -6)
    local topLineGradient = Instance.new("ImageLabel")
    topLineGradient.Name = "TopLine"
    topLineGradient.Parent = innerBorder
    topLineGradient.BackgroundTransparency = 1
    topLineGradient.BorderSizePixel = 0
    topLineGradient.Size = UDim2.new(1, 0, 0, 2)
    topLineGradient.Image = "rbxassetid://8508019876"
    topLineGradient.ImageColor3 = Color3.fromRGB(255, 255, 255)
    topLineGradient.ScaleType = Enum.ScaleType.Stretch
    makeDraggable(mainFrame, mainFrame)
    local sidebar = Instance.new("Frame")
    sidebar.Parent = innerBorder
    sidebar.BackgroundColor3 = Theme.SidebarBG
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0, 0, 0, 4)
    sidebar.Size = UDim2.new(0, 73, 1, -4)
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Parent = innerBorder
    sidebarDivider.BackgroundColor3 = Theme.Border
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.Position = UDim2.new(0, 73, 0, 4)
    sidebarDivider.Size = UDim2.new(0, 1, 1, -4)
    sidebarDivider.ZIndex = 2
    local sidebarList = Instance.new("UIListLayout")
    sidebarList.Parent = sidebar
    sidebarList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Padding = UDim.new(0, 4)
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.Parent = sidebar
    sidebarPadding.PaddingTop = UDim.new(0, 9)
    local tabContainer = Instance.new("Frame")
    tabContainer.Parent = innerBorder
    tabContainer.BackgroundColor3 = Theme.MainBG
    tabContainer.BorderSizePixel = 0
    tabContainer.Position = UDim2.new(0, 74, 0, 4)
    tabContainer.Size = UDim2.new(1, -75, 1, -4)
    tabContainer.ClipsDescendants = true
    local gridPattern = Instance.new("ImageLabel")
    gridPattern.Parent = tabContainer
    gridPattern.BackgroundTransparency = 1
    gridPattern.Size = UDim2.new(1, 0, 1, 0)
    gridPattern.Image = "rbxassetid://8547666218"
    gridPattern.ImageColor3 = Color3.fromRGB(12, 12, 12)
    gridPattern.ScaleType = Enum.ScaleType.Tile
    gridPattern.TileSize = UDim2.new(0, 8, 0, 8)
    gridPattern.ZIndex = 1
    UserInputService.InputBegan:Connect(function(input, processed)
      if input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
      end
    end)
    function Window:CreateTab(iconId)
      local Tab = {}
      local tabButton = Instance.new("TextButton")
      tabButton.Parent = sidebar
      tabButton.BackgroundTransparency = 1
      tabButton.Size = UDim2.new(1, 0, 0, 72)
      tabButton.Text = ""
      local tabIcon = Instance.new("ImageLabel")
      tabIcon.Parent = tabButton
      tabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
      tabIcon.BackgroundTransparency = 1
      tabIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
      tabIcon.Size = UDim2.new(0, 45, 0, 45)
      tabIcon.Image = iconId
      tabIcon.ImageColor3 = Color3.fromRGB(90, 90, 90)
      tabIcon.ZIndex = 10
      local activeTabFrame = Instance.new("Frame")
      activeTabFrame.Parent = tabButton
      activeTabFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
      activeTabFrame.BorderSizePixel = 0
      activeTabFrame.Size = UDim2.new(1, 1, 1, 0)
      activeTabFrame.Visible = false
      activeTabFrame.ZIndex = 3
      local tabInnerBorder = Instance.new("Frame")
      tabInnerBorder.Parent = activeTabFrame
      tabInnerBorder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
      tabInnerBorder.BorderSizePixel = 0
      tabInnerBorder.Position = UDim2.new(0, 0, 0, 1)
      tabInnerBorder.Size = UDim2.new(1, 0, 1, -2)
      tabInnerBorder.ZIndex = 4
      local tabBackground = Instance.new("Frame")
      tabBackground.Parent = tabInnerBorder
      tabBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
      tabBackground.BorderSizePixel = 0
      tabBackground.Position = UDim2.new(0, 0, 0, 1)
      tabBackground.Size = UDim2.new(1, 1, 1, -2)
      tabBackground.ZIndex = 5
      local tabGrid = gridPattern:Clone()
      tabGrid.Parent = tabBackground
      tabGrid.ZIndex = 5
      local tabCanvas = Instance.new("CanvasGroup")
      tabCanvas.Parent = tabContainer
      tabCanvas.BackgroundTransparency = 1
      tabCanvas.BorderSizePixel = 0
      tabCanvas.Position = UDim2.new(0, 20, 0, 20)
      tabCanvas.Size = UDim2.new(1, -40, 1, -40)
      tabCanvas.Visible = false
      tabCanvas.GroupTransparency = 1
      tabCanvas.ZIndex = 3
      local tabScroll = Instance.new("ScrollingFrame")
      tabScroll.Parent = tabCanvas
      tabScroll.BackgroundTransparency = 1
      tabScroll.BorderSizePixel = 0
      tabScroll.Position = UDim2.new(0, 0, 0, 0)
      tabScroll.Size = UDim2.new(1, 0, 1, 0)
      tabScroll.ScrollBarThickness = 0
      tabScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
      tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
      tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
      tabScroll.ZIndex = 3
      tabScroll.VerticalScrollBarInset = Enum.ScrollBarInset.None
      tabScroll.ScrollingDirection = Enum.ScrollingDirection.XY
      local leftColumn = Instance.new("Frame")
      leftColumn.Parent = tabScroll
      leftColumn.BackgroundTransparency = 1
      leftColumn.Size = UDim2.new(0.5, -10, 0, 0)
      leftColumn.AutomaticSize = Enum.AutomaticSize.Y
      local leftList = Instance.new("UIListLayout", leftColumn)
      leftList.SortOrder = Enum.SortOrder.LayoutOrder
      leftList.Padding = UDim.new(0, 18)
      local rightColumn = Instance.new("Frame")
      rightColumn.Parent = tabScroll
      rightColumn.BackgroundTransparency = 1
      rightColumn.Position = UDim2.new(0.5, 10, 0, 0)
      rightColumn.Size = UDim2.new(0.5, -10, 0, 0)
      rightColumn.AutomaticSize = Enum.AutomaticSize.Y
      local rightList = Instance.new("UIListLayout", rightColumn)
      rightList.SortOrder = Enum.SortOrder.LayoutOrder
      rightList.Padding = UDim.new(0, 18)
      tabButton.MouseButton1Click:Connect(function()
        local tabIndex = table.find(Window.Tabs, Tab)
      if Window.CurrentTabIndex == tabIndex then return end
        local directionSign = Window.CurrentTabIndex < tabIndex and 1 or -1
        local slideOffset = 40 * directionSign
        for i, otherTab in pairs(Window.Tabs) do
          if otherTab ~= Tab and otherTab.Canvas.Visible then
            local otherCanvas = otherTab.Canvas
            TweenService:Create(otherCanvas, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            GroupTransparency = 1,
            Position = UDim2.new(0, 20, 0, 20 - slideOffset)
            }):Play()
            task.delay(0.25, function()
              if Window.CurrentTabIndex ~= i then
                otherCanvas.Visible = false
              end
            end)
            otherTab.Border.Visible = false
            TweenService:Create(otherTab.Icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(90, 90, 90)}):Play()
          end
        end
        tabCanvas.Position = UDim2.new(0, 20, 0, 20 + slideOffset)
        tabCanvas.GroupTransparency = 1
        tabCanvas.Visible = true
        TweenService:Create(tabCanvas, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        Position = UDim2.new(0, 20, 0, 20)
        }):Play()
        activeTabFrame.Visible = true
        TweenService:Create(tabIcon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(167, 167, 167)}):Play()
        Window.CurrentTabIndex = tabIndex
        Window.CurrentTab = Tab
      end)
      Tab.Canvas = tabCanvas
      Tab.Page = tabScroll
      Tab.Icon = tabIcon
      Tab.Border = activeTabFrame
      table.insert(Window.Tabs, Tab)
      if #Window.Tabs == 1 then
        tabCanvas.Visible = true
        tabCanvas.GroupTransparency = 0
        activeTabFrame.Visible = true
        tabIcon.ImageColor3 = Color3.fromRGB(167, 167, 167)
        Window.CurrentTabIndex = 1
        Window.CurrentTab = Tab
      end
      function Tab:CreateSection(titleText, side)
        local Section = {}
        local targetColumn = side == "Right" and rightColumn or leftColumn
        local sectionBorder = Instance.new("Frame")
        sectionBorder.Parent = targetColumn
        sectionBorder.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        sectionBorder.BorderMode = Enum.BorderMode.Inset
        sectionBorder.BorderColor3 = Color3.fromRGB(12, 12, 12)
        sectionBorder.BorderSizePixel = 1
        sectionBorder.Size = UDim2.new(1, 0, 0, 20)
        local sectionFrame = Instance.new("Frame")
        sectionFrame.Parent = sectionBorder
        sectionFrame.BackgroundColor3 = Theme.SectionBG
        sectionFrame.BorderSizePixel = 0
        sectionFrame.Position = UDim2.new(0, 1, 0, 1)
        sectionFrame.Size = UDim2.new(1, -2, 1, -2)
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Parent = sectionBorder
        sectionTitle.BackgroundColor3 = Theme.SectionBG
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.BorderSizePixel = 0
        sectionTitle.Position = UDim2.new(0, 12, 0, 0)
        sectionTitle.Size = UDim2.new(1, -26, 0, 15)
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.Text = titleText
        sectionTitle.TextColor3 = Theme.Text
        sectionTitle.TextSize = 10
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.ZIndex = 5
        local titleLine = Instance.new("Frame")
        titleLine.Parent = sectionBorder
        titleLine.BackgroundColor3 = Theme.SectionBG
        titleLine.BackgroundTransparency = 1
        titleLine.BorderSizePixel = 0
        titleLine.Position = UDim2.new(0, 9, 0, -1)
        titleLine.Size = UDim2.new(0, sectionTitle.TextBounds.X + 6, 0, 2)
        titleLine.ZIndex = 5
        task.spawn(function()
          task.wait(0.1)
          titleLine.Size = UDim2.new(0, sectionTitle.TextBounds.X + 6, 0, 2)
        end)
        local contentContainer = Instance.new("Frame")
        contentContainer.Parent = sectionFrame
        contentContainer.BackgroundTransparency = 1
        contentContainer.Position = UDim2.new(0, 0, 0, 15)
        contentContainer.Size = UDim2.new(1, 0, 1, -15)
        local contentList = Instance.new("UIListLayout", contentContainer)
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        contentList.Padding = UDim.new(0, 6)
        local contentPadding = Instance.new("UIPadding", contentContainer)
        contentPadding.PaddingLeft = UDim.new(0, 15)
        contentPadding.PaddingRight = UDim.new(0, 15)
        contentPadding.PaddingTop = UDim.new(0, 5)
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
          sectionBorder.Size = UDim2.new(1, 0, 0, contentList.AbsoluteContentSize.Y + 28)
        end)
        function Section:CreateButton(name, callback)
          local buttonContainer = Instance.new("Frame")
          buttonContainer.Parent = contentContainer
          buttonContainer.BackgroundTransparency = 1
          buttonContainer.Size = UDim2.new(1, 0, 0, 24)
          local buttonBorder = Instance.new("Frame")
          buttonBorder.Parent = buttonContainer
          buttonBorder.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
          buttonBorder.BorderSizePixel = 0
          buttonBorder.Position = UDim2.new(0, 0, 0, 0)
          buttonBorder.Size = UDim2.new(1, 0, 1, 0)
          local buttonInner = Instance.new("Frame")
          buttonInner.Parent = buttonBorder
          buttonInner.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
          buttonInner.BorderSizePixel = 0
          buttonInner.Position = UDim2.new(0, 1, 0, 1)
          buttonInner.Size = UDim2.new(1, -2, 1, -2)
          local buttonElement = Instance.new("TextButton")
          buttonElement.Parent = buttonInner
          buttonElement.BackgroundColor3 = Color3.fromRGB(85, 85, 85)
          buttonElement.BorderSizePixel = 0
          buttonElement.Position = UDim2.new(0, 1, 0, 1)
          buttonElement.Size = UDim2.new(1, -2, 1, -2)
          buttonElement.FontFace = Font.fromEnum(Enum.Font.Arial)
          buttonElement.Text = name
          buttonElement.TextColor3 = Color3.fromRGB(255, 255, 255)
          buttonElement.TextSize = 13
          buttonElement.AutoButtonColor = false
          buttonElement.TextXAlignment = Enum.TextXAlignment.Center
          buttonElement.TextYAlignment = Enum.TextYAlignment.Center
          local buttonGradient = Instance.new("UIGradient", buttonElement)
          buttonGradient.Rotation = 90
          buttonGradient.Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 90)),
          ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
          })
          buttonElement.MouseEnter:Connect(function()
            buttonGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 115, 115)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 100))
            })
          end)
          buttonElement.MouseLeave:Connect(function()
            buttonGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 90)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 80))
            })
          end)
          buttonElement.MouseButton1Click:Connect(function()
            pcall(callback)
          end)
        end
        function Section:CreateInput(flagId, name, placeholder, callback)
          local val = ""
          Library.Flags[flagId] = val
          local inputContainer = Instance.new("Frame")
          inputContainer.Parent = contentContainer
          inputContainer.BackgroundTransparency = 1
          inputContainer.Size = UDim2.new(1, 0, 0, 34)
          local inputBorder = Instance.new("Frame")
          inputBorder.Parent = inputContainer
          inputBorder.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
          inputBorder.BorderSizePixel = 0
          inputBorder.Position = UDim2.new(0, 0, 0, 1)
          inputBorder.Size = UDim2.new(1, 0, 0, 18)
          local inputInner = Instance.new("Frame")
          inputInner.Parent = inputBorder
          inputInner.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
          inputInner.BorderSizePixel = 0
          inputInner.Position = UDim2.new(0, 1, 0, 1)
          inputInner.Size = UDim2.new(1, -2, 1, -2)
          inputInner.ClipsDescendants = true
          local inputBox = Instance.new("TextBox")
          inputBox.Parent = inputInner
          inputBox.BackgroundColor3 = Theme.InputBg
          inputBox.BorderSizePixel = 0
          inputBox.Position = UDim2.new(0, 1, 0, 1)
          inputBox.Size = UDim2.new(1, -2, 1, -2)
          inputBox.FontFace = Font.fromEnum(Enum.Font.Arial)
          inputBox.Text = ""
          inputBox.PlaceholderText = placeholder or ""
          inputBox.TextColor3 = Theme.Text
          inputBox.PlaceholderColor3 = Theme.TextDark
          inputBox.TextSize = 12
          inputBox.TextXAlignment = Enum.TextXAlignment.Left
          inputBox.ClipsDescendants = true
          local Padding = Instance.new("UIPadding")
          Padding.Parent = inputBox
          Padding.PaddingLeft = UDim.new(0, 6)
          Padding.PaddingRight = UDim.new(0, 6)
          inputBox.FocusLost:Connect(function()
            val = inputBox.Text
            Library.Flags[flagId] = val
            pcall(callback, val)
          end)
          Library.Elements[flagId] = function(val)
            val = tostring(val)
            inputBox.Text = val
            Library.Flags[flagId] = val
            pcall(callback, val)
          end
          return {
          SetValue = function(self, val)
            val = tostring(val)
            inputBox.Text = val
            Library.Flags[flagId] = val
            pcall(callback, val)
          end,
        GetValue = function(self) return val end
          }
        end
        function Section:CreateToggle(flagId, name, default, callback)
          local toggleState = default or false
          Library.Flags[flagId] = toggleState
          local toggleButton = Instance.new("TextButton")
          toggleButton.Parent = contentContainer
          toggleButton.BackgroundTransparency = 1
          toggleButton.Size = UDim2.new(1, 0, 0, 14)
          toggleButton.Text = ""
          local boxFrame = Instance.new("Frame")
          boxFrame.Parent = toggleButton
          boxFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
          boxFrame.BorderSizePixel = 0
          boxFrame.Position = UDim2.new(0, 0, 0.5, -4)
          boxFrame.Size = UDim2.new(0, 8, 0, 8)
          local toggleIndicator = Instance.new("Frame")
          toggleIndicator.Parent = boxFrame
          toggleIndicator.BackgroundColor3 = toggleState and Theme.Accent1 or Color3.fromRGB(77, 77, 77)
          toggleIndicator.BorderSizePixel = 0
          toggleIndicator.Position = UDim2.new(0, 1, 0, 1)
          toggleIndicator.Size = UDim2.new(1, -2, 1, -2)
          local toggleGradient = Instance.new("UIGradient", toggleIndicator)
          toggleGradient.Color = ColorSequence.new{
          ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
          ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 140, 140))
          }
          toggleGradient.Rotation = 90
          local elementLabel = Instance.new("TextLabel")
          elementLabel.Parent = toggleButton
          elementLabel.BackgroundTransparency = 1
          elementLabel.Position = UDim2.new(0, 16, -0.1, 0)
          elementLabel.Size = UDim2.new(1, -18, 1, 0)
          elementLabel.FontFace = Font.fromEnum(Enum.Font.Arial)
          elementLabel.Text = name
          elementLabel.TextColor3 = toggleState and Theme.Text or Theme.TextDark
          elementLabel.TextSize = 12
          elementLabel.TextXAlignment = Enum.TextXAlignment.Left
          local function SetState(indicatorState)
            toggleState = indicatorState
            Library.Flags[flagId] = indicatorState
            toggleIndicator.BackgroundColor3 = indicatorState and Theme.Accent1 or Color3.fromRGB(77, 77, 77)
            elementLabel.TextColor3 = indicatorState and Theme.Text or Theme.TextDark
            pcall(callback, indicatorState)
          end
        toggleButton.MouseButton1Click:Connect(function() SetState(not toggleState) end)
          Library.Elements[flagId] = SetState
          pcall(callback, toggleState)
          return {
          SetState = SetState,
        GetState = function() return toggleState end,
          Frame = toggleButton
          }
        end
        function Section:CreateKeybind(flagId, name, defaultSettings, callback)
          local keybindData = defaultSettings
          local bindingKey = false
          local keybindModes = {"Toggle", "Hold", "Always", "Off"}
          Library.Flags[flagId] = keybindData
          local keybindContainer = Instance.new("Frame")
          keybindContainer.Parent = contentContainer
          keybindContainer.BackgroundTransparency = 1
          keybindContainer.Size = UDim2.new(1, 0, 0, 18)
          local elementLabel = Instance.new("TextLabel")
          elementLabel.Parent = keybindContainer
          elementLabel.BackgroundTransparency = 1
          elementLabel.Size = UDim2.new(1, -60, 1, 0)
          elementLabel.FontFace = Font.fromEnum(Enum.Font.Arial)
          elementLabel.Text = name
          elementLabel.TextColor3 = Theme.TextDark
          elementLabel.TextSize = 13
          elementLabel.TextXAlignment = Enum.TextXAlignment.Left
          local keybindBtn = Instance.new("TextButton")
          keybindBtn.Parent = keybindContainer
          keybindBtn.BackgroundTransparency = 1
          keybindBtn.Position = UDim2.new(1, -80, 0, 0)
          keybindBtn.Size = UDim2.new(0, 80, 1, 0)
          keybindBtn.FontFace = Font.fromEnum(Enum.Font.Arial)
          keybindBtn.TextColor3 = Color3.fromRGB(141, 141, 141)
          keybindBtn.TextSize = 13
          keybindBtn.TextXAlignment = Enum.TextXAlignment.Right
          local function updateKeybindText()
            local keyDisplayName = keybindData.Key == "None" and "-" or (typeof(keybindData.Key) == "EnumItem" and keybindData.Key.Name or tostring(keybindData.Key))
            keybindBtn.Text = string.format("[%s] %s", keyDisplayName, keybindData.Mode)
          end
          local function setKeybindMode(newMode)
            keybindData.Mode = newMode
            updateKeybindText()
            if newMode == "Always" then
              keybindData.Active = true
              pcall(callback, keybindData)
            elseif newMode == "Off" then
                keybindData.Active = false
                pcall(callback, keybindData)
              else
                keybindData.Active = false
                pcall(callback, keybindData)
              end
            end
            local modeDropdown = nil
            local modeCloseConn = nil
            local function closeModeDropdown()
              if modeDropdown then
                modeDropdown:Destroy()
                modeDropdown = nil
              end
              if modeCloseConn then
                modeCloseConn:Disconnect()
                modeCloseConn = nil
              end
            end
            local function openModeDropdown()
              closeModeDropdown()
              local modeDropdownFrame = Instance.new("Frame")
              modeDropdownFrame.Name = "ModeDropdown"
              modeDropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
              modeDropdownFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
              modeDropdownFrame.BorderSizePixel = 0
              modeDropdownFrame.Size = UDim2.new(0, 55, 0, #keybindModes * 18)
              modeDropdownFrame.Position = UDim2.new(1, -55, 1, 2)
              modeDropdownFrame.Parent = keybindContainer
              modeDropdownFrame.ZIndex = 15
              modeDropdownFrame.BorderSizePixel = 1
              modeDropdownFrame.BorderColor3 = Color3.fromRGB(15,15,15)
              local activeModeColor = Color3.fromRGB(119, 156, 39)
              for i, modeName in ipairs(keybindModes) do
                local isSelectedMode = (modeName == keybindData.Mode)
                local modeBtn = Instance.new("TextButton")
                modeBtn.Parent = modeDropdownFrame
                modeBtn.Size = UDim2.new(1, 0, 0, 18)
                modeBtn.Position = UDim2.new(0, 0, 0, (i - 1) * 18)
                modeBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
                modeBtn.BorderSizePixel = 0
                modeBtn.FontFace = Font.fromEnum(Enum.Font.Arial)
                modeBtn.Text = modeName
                modeBtn.TextColor3 = isSelectedMode and activeModeColor or Theme.TextDark
                modeBtn.TextSize = 14
                modeBtn.TextXAlignment = Enum.TextXAlignment.Left
                modeBtn.ZIndex = 16
                local modeBtnPadding = Instance.new("UIPadding", modeBtn)
                modeBtnPadding.PaddingLeft = UDim.new(0, 4)
                modeBtnPadding.PaddingRight = UDim.new(0, 4)
                modeBtn.MouseEnter:Connect(function()
                  modeBtn.TextSize = 14
                  modeBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
                  if isSelectedMode then
                    modeBtn.TextColor3 = activeModeColor:Lerp(Color3.new(1,1,1), 0.2)
                  else
                    modeBtn.TextColor3 = Theme.Text
                  end
                end)
                modeBtn.MouseLeave:Connect(function()
                  modeBtn.TextSize = 12
                  modeBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
                  if isSelectedMode then
                    modeBtn.TextColor3 = activeModeColor
                  else
                    modeBtn.TextColor3 = Theme.TextDark
                  end
                end)
                modeBtn.MouseButton1Click:Connect(function()
                  setKeybindMode(modeName)
                  closeModeDropdown()
                end)
              end
              modeDropdown = modeDropdownFrame
              task.wait(0.1)
              modeCloseConn = UserInputService.InputBegan:Connect(function(input, gpe)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                  if modeDropdown then
                    local mouseScreenPos = UserInputService:GetMouseLocation()
                    local guiInsetOffset = game:GetService("GuiService"):GetGuiInset()
                    local dropdownAbsPos = modeDropdown.AbsolutePosition
                    local dropdownAbsSize = modeDropdown.AbsoluteSize
                    local insetMouseLocation = Vector2.new(mouseScreenPos.X, mouseScreenPos.Y - guiInsetOffset.Y)
                    if insetMouseLocation.X < dropdownAbsPos.X or insetMouseLocation.X > dropdownAbsPos.X + dropdownAbsSize.X
                    or insetMouseLocation.Y < dropdownAbsPos.Y or insetMouseLocation.Y > dropdownAbsPos.Y + dropdownAbsSize.Y then
                      closeModeDropdown()
                    end
                  else
                    closeModeDropdown()
                  end
                end
              end)
            end
            keybindBtn.MouseButton2Click:Connect(function()
          if modeDropdown then closeModeDropdown() else openModeDropdown() end
            end)
            keybindBtn.MouseButton1Click:Connect(function()
              bindingKey = true
              keybindBtn.Text = "[-]"
              keybindBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
            end)
            local function onInputBegan(input, gpe)
              if bindingKey then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                  if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                    keybindData.Key = "None"
                  else
                    keybindData.Key = input.KeyCode
                  end
                  bindingKey = false
                  updateKeybindText()
                  keybindBtn.TextColor3 = Color3.fromRGB(141, 141, 141)
                  pcall(callback, keybindData)
                end
                return
              end
              if not gpe and keybindData.Key ~= "None" and (input.KeyCode == keybindData.Key or input.UserInputType == keybindData.Key) then
                if keybindData.Mode == "Toggle" then
                  keybindData.Active = not keybindData.Active
                  pcall(callback, keybindData)
                elseif keybindData.Mode == "Hold" then
                    keybindData.Active = true
                    pcall(callback, keybindData)
                  end
                end
              end
              local function onInputEnded(input, gpe)
                if not bindingKey and not gpe and keybindData.Key ~= "None" and (input.KeyCode == keybindData.Key or input.UserInputType == keybindData.Key) then
                  if keybindData.Mode == "Hold" then
                    keybindData.Active = false
                    pcall(callback, keybindData)
                  end
                end
              end
              UserInputService.InputBegan:Connect(onInputBegan)
              UserInputService.InputEnded:Connect(onInputEnded)
              updateKeybindText()
              if keybindData.Mode == "Always" then keybindData.Active = true
              pcall(callback, keybindData) end
              Library.Elements[flagId] = function(val)
                if type(val) == "table" then
                  keybindData.Key = val.Key or keybindData.Key
                  keybindData.Mode = val.Mode or keybindData.Mode
                  updateKeybindText()
                  pcall(callback, keybindData)
                end
              end
              pcall(callback, keybindData)
            end
            function Section:CreateSlider(flagId, name, min, max, default, callback, stepSize)
              local val = default or min
              Library.Flags[flagId] = val
              local stepSize = stepSize or 0.01
              local sliderContainer = Instance.new("Frame")
              sliderContainer.Parent = contentContainer
              sliderContainer.BackgroundTransparency = 1
              sliderContainer.Size = UDim2.new(1, 0, 0, 24)
              local elementLabel = Instance.new("TextLabel")
              elementLabel.Parent = sliderContainer
              elementLabel.BackgroundTransparency = 1
              elementLabel.Size = UDim2.new(1, 0, 0, 14)
              elementLabel.FontFace = Font.fromEnum(Enum.Font.Arial)
              elementLabel.Text = name
              elementLabel.TextColor3 = Theme.Text
              elementLabel.TextSize = 12
              elementLabel.TextXAlignment = Enum.TextXAlignment.Left
              local boxFrame = Instance.new("Frame")
              boxFrame.Parent = sliderContainer
              boxFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
              boxFrame.BorderSizePixel = 0
              boxFrame.Position = UDim2.new(0, 0, 0, 15)
              boxFrame.Size = UDim2.new(1, 0, 0, 7)
              local sliderTrack = Instance.new("Frame")
              sliderTrack.Parent = boxFrame
              sliderTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
              sliderTrack.BorderSizePixel = 0
              sliderTrack.Position = UDim2.new(0, 1, 0, 1)
              sliderTrack.Size = UDim2.new(1, -2, 1, -2)
              local sliderTrackGradient = Instance.new("UIGradient", sliderTrack)
              sliderTrackGradient.Rotation = 90
              sliderTrackGradient.Color = createGradient(53, 53, 53, true)
              local toggleIndicator = Instance.new("Frame")
              toggleIndicator.Parent = sliderTrack
              toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
              toggleIndicator.BorderSizePixel = 0
              toggleIndicator.Size = UDim2.new(math.clamp((val - min) / (max - min), 0, 1), 0, 1, 0)
              local sliderFillGradient = Instance.new("UIGradient", toggleIndicator)
              sliderFillGradient.Rotation = 90
              sliderFillGradient.Color = createGradient(119, 156, 39, false)
              local sliderValueLabel = Instance.new("TextLabel")
              sliderValueLabel.Parent = toggleIndicator
              sliderValueLabel.BackgroundTransparency = 1
              sliderValueLabel.Position = UDim2.new(1, 0, 0.5, 1)
              sliderValueLabel.Size = UDim2.new(0, 2, 1, 0)
              sliderValueLabel.Font = Enum.Font.GothamBold
              sliderValueLabel.Text = tostring(val)
              sliderValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
              sliderValueLabel.TextSize = 12
              sliderValueLabel.TextStrokeTransparency = 0.3
              sliderValueLabel.TextXAlignment = Enum.TextXAlignment.Center
              local sliderHitbox = Instance.new("TextButton")
              sliderHitbox.Parent = boxFrame
              sliderHitbox.BackgroundTransparency = 1
              sliderHitbox.Size = UDim2.new(1, 0, 1, 0)
              sliderHitbox.Text = ""
              local sliderDragging = false
              local sliderHovered = false
              sliderHitbox.MouseEnter:Connect(function()
                sliderHovered = true
                sliderTrackGradient.Color = createGradient(78, 78, 78, false)
              end)
              sliderHitbox.MouseLeave:Connect(function()
                sliderHovered = false
              if not sliderDragging then sliderTrackGradient.Color = createGradient(53, 53, 53, true) end
              end)
              local function SetValue(v)
                val = math.clamp(roundNumber(v, stepSize), min, max)
                Library.Flags[flagId] = val
                toggleIndicator.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                sliderValueLabel.Text = tostring(val)
                pcall(callback, val)
              end
              local function updateSliderFromInput(input)
                local sliderPercent = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                local sliderCalculatedValue = min + (max - min) * sliderPercent
                SetValue(sliderCalculatedValue)
              end
              sliderHitbox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                  if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                    local sliderPopupFrame = Instance.new("Frame")
                    sliderPopupFrame.Parent = sliderContainer
                    sliderPopupFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    sliderPopupFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
                    sliderPopupFrame.BorderSizePixel = 1
                    sliderPopupFrame.Position = UDim2.new(0.5, -50, 0.5, -10)
                    sliderPopupFrame.Size = UDim2.new(0, 100, 0, 20)
                    sliderPopupFrame.ZIndex = 20
                    local sliderPopupBox = Instance.new("TextBox")
                    sliderPopupBox.Parent = sliderPopupFrame
                    sliderPopupBox.BackgroundTransparency = 1
                    sliderPopupBox.Size = UDim2.new(1, -10, 1, 0)
                    sliderPopupBox.Position = UDim2.new(0, 5, 0, 0)
                    sliderPopupBox.Font = Enum.Font.ArialBold
                    sliderPopupBox.TextSize = 12
                    sliderPopupBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                    sliderPopupBox.Text = tostring(val)
                    sliderPopupBox.ZIndex = 21
                    sliderPopupBox.FocusLost:Connect(function()
                      local parsedSliderVal = tonumber(sliderPopupBox.Text)
                    if parsedSliderVal then SetValue(parsedSliderVal) end
                      sliderPopupFrame:Destroy()
                    end)
                  sliderPopupBox.Focused:Connect(function() sliderPopupBox.Text = "" end)
                    task.wait(0.05)
                    sliderPopupBox:CaptureFocus()
                  else
                    sliderDragging = true
                    updateSliderFromInput(input)
                  end
                end
              end)
              UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                  if sliderDragging then
                    sliderDragging = false
                  if not sliderHovered then sliderTrackGradient.Color = createGradient(53, 53, 53, true) end
                  end
                end
              end)
              UserInputService.InputChanged:Connect(function(input)
              if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSliderFromInput(input) end
              end)
              Library.Elements[flagId] = SetValue
              pcall(callback, val)
            end
            function Section:CreateDropdown(flagId, name, list, default, callback)
              local selectedOption = default or list[1]
              Library.Flags[flagId] = selectedOption
              local dropdownOpen = false
              local dropdownContainer = Instance.new("Frame")
              dropdownContainer.Parent = contentContainer
              dropdownContainer.BackgroundTransparency = 1
              dropdownContainer.Size = UDim2.new(1, 0, 0, 36)
              local elementLabel = Instance.new("TextLabel")
              elementLabel.Parent = dropdownContainer
              elementLabel.BackgroundTransparency = 1
              elementLabel.Size = UDim2.new(1, 0, 0, 14)
              elementLabel.FontFace = Font.fromEnum(Enum.Font.Arial)
              elementLabel.Text = name
              elementLabel.TextColor3 = Theme.Text
              elementLabel.TextSize = 12
              elementLabel.TextXAlignment = Enum.TextXAlignment.Left
              local boxFrame = Instance.new("Frame")
              boxFrame.Parent = dropdownContainer
              boxFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
              boxFrame.BorderSizePixel = 0
              boxFrame.Position = UDim2.new(0, 0, 0, 16)
              boxFrame.Size = UDim2.new(1, 0, 0, 18)
              local dropdownButton = Instance.new("TextButton")
              dropdownButton.Parent = boxFrame
              dropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
              dropdownButton.BorderSizePixel = 0
              dropdownButton.Position = UDim2.new(0, 1, 0, 1)
              dropdownButton.Size = UDim2.new(1, -2, 1, -2)
              dropdownButton.FontFace = Font.fromEnum(Enum.Font.Arial)
              dropdownButton.Text = " " .. tostring(selectedOption)
              dropdownButton.TextColor3 = Theme.Text
              dropdownButton.TextSize = 13
              dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
              dropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
              local dropdownBtnGradient = Instance.new("UIGradient", dropdownButton)
              dropdownBtnGradient.Rotation = 90
              dropdownBtnGradient.Color = ColorSequence.new{
              ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
              ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
              }
              local dropdownArrow = Instance.new("TextLabel")
              dropdownArrow.Parent = dropdownButton
              dropdownArrow.BackgroundTransparency = 1
              dropdownArrow.Position = UDim2.new(1, -12, 0, 0)
              dropdownArrow.Size = UDim2.new(0, 12, 1, 0)
              dropdownArrow.Font = Enum.Font.Code
              dropdownArrow.Text = "▼"
              dropdownArrow.TextColor3 = Color3.fromRGB(156, 156, 156)
              dropdownArrow.TextSize = 7
              local dropdownList = Instance.new("ScrollingFrame")
              dropdownList.Parent = dropdownContainer
              dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
              dropdownList.BorderColor3 = Color3.fromRGB(12, 12, 12)
              dropdownList.BorderSizePixel = 1
              dropdownList.Position = UDim2.new(0, 0, 0, 35)
              dropdownList.Size = UDim2.new(1, 0, 0, math.min(#list * 18, 90))
              dropdownList.Visible = false
              dropdownList.ZIndex = 100
              dropdownList.ScrollBarThickness = 0
              dropdownList.CanvasSize = UDim2.new(0, 0, 0, #list * 18)
              Instance.new("UIListLayout", dropdownList)
              local function SetValue(val)
                selectedOption = val
                Library.Flags[flagId] = val
                dropdownButton.Text = " " .. tostring(val)
                dropdownOpen = false
                dropdownList.Visible = false
                dropdownArrow.Text = "▼"
                pcall(callback, val)
              end
              local dropdownObject = {}
              function dropdownObject:Refresh(newList)
                list = newList
                for _, child in ipairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
                end
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, #list * 18)
                if dropdownOpen then
                  dropdownList.Size = UDim2.new(1, 0, 0, math.min(#list * 18, 90))
                end
                for _, v in ipairs(list) do
                  local optionBtn = Instance.new("TextButton")
                  optionBtn.Parent = dropdownList
                  optionBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                  optionBtn.BorderSizePixel = 0
                  optionBtn.Size = UDim2.new(1, 0, 0, 18)
                  optionBtn.FontFace = Font.fromEnum(Enum.Font.Arial)
                  optionBtn.Text = " " .. v
                  optionBtn.TextColor3 = Theme.TextDark
                  optionBtn.TextSize = 13
                  optionBtn.TextXAlignment = Enum.TextXAlignment.Left
                  optionBtn.ZIndex = 101
                  optionBtn.MouseEnter:Connect(function()
                    optionBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
                  end)
                  optionBtn.MouseLeave:Connect(function()
                    optionBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                  end)
                optionBtn.MouseButton1Click:Connect(function() SetValue(v) end)
                end
            if not table.find(list, selectedOption) and #list > 0 then SetValue(list[1]) elseif #list == 0 then SetValue("None") end
                end
                dropdownObject:Refresh(list)
                dropdownButton.MouseButton1Click:Connect(function()
                  dropdownOpen = not dropdownOpen
                  dropdownList.Visible = dropdownOpen
                  dropdownArrow.Text = dropdownOpen and "▲" or "▼"
                end)
                Library.Elements[flagId] = SetValue
                pcall(callback, selectedOption)
                return dropdownObject
              end
              function Section:CreateMultiDropdown(flagId, name, list, defaultSelected, callback)
                local multiSelected = {}
                for _, v in ipairs(defaultSelected or {}) do
                  multiSelected[v] = true
                end
                Library.Flags[flagId] = multiSelected
                local dropdownOpen = false
                local dropdownContainer = Instance.new("Frame")
                dropdownContainer.Parent = contentContainer
                dropdownContainer.BackgroundTransparency = 1
                dropdownContainer.Size = UDim2.new(1, 0, 0, 36)
                local elementLabel = Instance.new("TextLabel")
                elementLabel.Parent = dropdownContainer
                elementLabel.BackgroundTransparency = 1
                elementLabel.Size = UDim2.new(1, 0, 0, 14)
                elementLabel.FontFace = Font.fromEnum(Enum.Font.Arial)
                elementLabel.Text = name
                elementLabel.TextColor3 = Theme.Text
                elementLabel.TextSize = 10
                elementLabel.TextXAlignment = Enum.TextXAlignment.Left
                local boxFrame = Instance.new("Frame")
                boxFrame.Parent = dropdownContainer
                boxFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                boxFrame.BorderSizePixel = 0
                boxFrame.Position = UDim2.new(0, 0, 0, 16)
                boxFrame.Size = UDim2.new(1, 0, 0, 18)
                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Parent = boxFrame
                dropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                dropdownButton.BorderSizePixel = 0
                dropdownButton.Position = UDim2.new(0, 1, 0, 1)
                dropdownButton.Size = UDim2.new(1, -2, 1, -2)
                dropdownButton.FontFace = Font.fromEnum(Enum.Font.Arial)
                dropdownButton.TextColor3 = Theme.Text
                dropdownButton.TextSize = 13
                dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
                dropdownButton.TextTruncate = Enum.TextTruncate.AtEnd
                local dropdownBtnGradient = Instance.new("UIGradient", dropdownButton)
                dropdownBtnGradient.Rotation = 90
                dropdownBtnGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                }
                local dropdownArrow = Instance.new("TextLabel")
                dropdownArrow.Parent = dropdownButton
                dropdownArrow.BackgroundTransparency = 1
                dropdownArrow.Position = UDim2.new(1, -12, 0, 0)
                dropdownArrow.Size = UDim2.new(0, 12, 1, 0)
                dropdownArrow.Font = Enum.Font.Code
                dropdownArrow.Text = "▼"
                dropdownArrow.TextColor3 = Color3.fromRGB(156, 156, 156)
                dropdownArrow.TextSize = 7
                local dropdownList = Instance.new("ScrollingFrame")
                dropdownList.Parent = dropdownContainer
                dropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                dropdownList.BorderColor3 = Color3.fromRGB(12, 12, 12)
                dropdownList.BorderSizePixel = 1
                dropdownList.Position = UDim2.new(0, 0, 0, 35)
                dropdownList.Size = UDim2.new(1, 0, 0, math.min(#list * 18, 90))
                dropdownList.Visible = false
                dropdownList.ZIndex = 100
                dropdownList.ScrollBarThickness = 0
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, #list * 18)
                Instance.new("UIListLayout", dropdownList)
                local function updateMultiDropdownText()
                  local multiSelectedList = {}
                  for _, option in ipairs(list) do
                    if multiSelected[option] then
                      table.insert(multiSelectedList, option)
                    end
                  end
                  if #multiSelectedList == 0 then
                    dropdownButton.Text = " None"
                  else
                    dropdownButton.Text = " " .. table.concat(multiSelectedList, ", ")
                  end
                end
                local function toggleMultiOption(option)
                  multiSelected[option] = not multiSelected[option]
                  Library.Flags[flagId] = multiSelected
                  updateMultiDropdownText()
                  pcall(callback, multiSelected)
                end
                local multiOptionButtons = {}
                for _, option in ipairs(list) do
                  local optionBtn = Instance.new("TextButton")
                  optionBtn.Parent = dropdownList
                  optionBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                  optionBtn.BorderSizePixel = 0
                  optionBtn.Size = UDim2.new(1, 0, 0, 18)
                  optionBtn.FontFace = Font.fromEnum(Enum.Font.Arial)
                  optionBtn.Text = " " .. option
                  optionBtn.TextColor3 = multiSelected[option] and Theme.Accent1 or Theme.TextDark
                  optionBtn.TextSize = 13
                  optionBtn.TextXAlignment = Enum.TextXAlignment.Left
                  optionBtn.ZIndex = 101
                  optionBtn.MouseEnter:Connect(function()
                    optionBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
                  end)
                  optionBtn.MouseLeave:Connect(function()
                    optionBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
                  end)
                  optionBtn.MouseButton1Click:Connect(function()
                    toggleMultiOption(option)
                    optionBtn.TextColor3 = multiSelected[option] and Theme.Accent1 or Theme.TextDark
                  end)
                  multiOptionButtons[option] = optionBtn
                end
                dropdownButton.MouseButton1Click:Connect(function()
                  dropdownOpen = not dropdownOpen
                  dropdownList.Visible = dropdownOpen
                  dropdownArrow.Text = dropdownOpen and "▲" or "▼"
                end)
                updateMultiDropdownText()
                pcall(callback, multiSelected)
                local multiDropdownObject = {}
                function multiDropdownObject:SetSelected(newSelected)
                  multiSelected = {}
                  for _, v in ipairs(newSelected) do
                    multiSelected[v] = true
                  end
                  Library.Flags[flagId] = multiSelected
                  for opt, modeBtn in pairs(multiOptionButtons) do
                    modeBtn.TextColor3 = multiSelected[opt] and Theme.Accent1 or Theme.TextDark
                  end
                  updateMultiDropdownText()
                  pcall(callback, multiSelected)
                end
                return multiDropdownObject
              end
              function Section:CreateColorPicker(flagId, name, defaultColor, callback)
                local colorValue = defaultColor or Color3.new(1, 1, 1)
                local alphaValue = 1
                Library.Flags[flagId] = {R = colorValue.R, G = colorValue.G, B = colorValue.B, A = alphaValue}
                local dropdownOpen = false
                local colorPickerContainer = Instance.new("Frame")
                colorPickerContainer.Parent = contentContainer
                colorPickerContainer.BackgroundTransparency = 1
                colorPickerContainer.Size = UDim2.new(1, 0, 0, 16)
                local elementLabel = Instance.new("TextLabel")
                elementLabel.Parent = colorPickerContainer
                elementLabel.BackgroundTransparency = 1
                elementLabel.Size = UDim2.new(1, -25, 1, 0)
                elementLabel.Font = Enum.Font.GothamBold
                elementLabel.Text = name
                elementLabel.TextColor3 = Theme.Text
                elementLabel.TextSize = 10
                elementLabel.TextXAlignment = Enum.TextXAlignment.Left
                local colorPreviewBorder = Instance.new("Frame")
                colorPreviewBorder.Parent = colorPickerContainer
                colorPreviewBorder.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                colorPreviewBorder.BorderSizePixel = 0
                colorPreviewBorder.Position = UDim2.new(1, -20, 0, 3)
                colorPreviewBorder.Size = UDim2.new(0, 16, 0, 10)
                local colorPreviewBtn = Instance.new("TextButton")
                colorPreviewBtn.Parent = colorPreviewBorder
                colorPreviewBtn.BackgroundColor3 = colorValue
                colorPreviewBtn.BorderSizePixel = 0
                colorPreviewBtn.Position = UDim2.new(0, 1, 0, 1)
                colorPreviewBtn.Size = UDim2.new(1, -2, 1, -2)
                colorPreviewBtn.Text = ""
                local colorPickerDropdown = Instance.new("Frame")
                colorPickerDropdown.Parent = colorPickerContainer
                colorPickerDropdown.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
                colorPickerDropdown.BorderColor3 = Color3.fromRGB(12, 12, 12)
                colorPickerDropdown.BorderSizePixel = 1
                colorPickerDropdown.Position = UDim2.new(0, 0, 0, 20)
                colorPickerDropdown.Size = UDim2.new(1, 0, 0, 150)
                colorPickerDropdown.Visible = false
                colorPickerDropdown.ZIndex = 100
                local svPickerBorder = Instance.new("Frame")
                svPickerBorder.Parent = colorPickerDropdown
                svPickerBorder.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                svPickerBorder.BorderSizePixel = 0
                svPickerBorder.Position = UDim2.new(0, 5, 0, 5)
                svPickerBorder.Size = UDim2.new(1, -30, 1, -25)
                svPickerBorder.ZIndex = 100
                local svPickerBtn = Instance.new("TextButton")
                svPickerBtn.Parent = svPickerBorder
                svPickerBtn.BackgroundColor3 = Color3.fromHSV(0, 1, 1)
                svPickerBtn.BorderSizePixel = 0
                svPickerBtn.Position = UDim2.new(0, 1, 0, 1)
                svPickerBtn.Size = UDim2.new(1, -2, 1, -2)
                svPickerBtn.Text = ""
                svPickerBtn.ZIndex = 100
                svPickerBtn.AutoButtonColor = false
                local svWhiteGradient = Instance.new("UIGradient", Instance.new("Frame", svPickerBtn))
                svWhiteGradient.Parent.Size = UDim2.new(1, 0, 1, 0)
                svWhiteGradient.Parent.BackgroundColor3 = Color3.new(1, 1, 1)
                svWhiteGradient.Parent.BorderSizePixel = 0
                svWhiteGradient.Parent.ZIndex = 101
                svWhiteGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                }
                svWhiteGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
                }
                local svBlackGradient = Instance.new("UIGradient", Instance.new("Frame", svPickerBtn))
                svBlackGradient.Parent.Size = UDim2.new(1, 0, 1, 0)
                svBlackGradient.Parent.BackgroundColor3 = Color3.new(0, 0, 0)
                svBlackGradient.Parent.BorderSizePixel = 0
                svBlackGradient.Parent.ZIndex = 102
                svBlackGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                }
                svBlackGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0)
                }
                svBlackGradient.Rotation = 90
                local hueSliderBorder = Instance.new("Frame")
                hueSliderBorder.Parent = colorPickerDropdown
                hueSliderBorder.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                hueSliderBorder.BorderSizePixel = 0
                hueSliderBorder.Position = UDim2.new(1, -20, 0, 5)
                hueSliderBorder.Size = UDim2.new(0, 15, 1, -25)
                hueSliderBorder.ZIndex = 100
                local hueSliderBtn = Instance.new("TextButton")
                hueSliderBtn.Parent = hueSliderBorder
                hueSliderBtn.BackgroundColor3 = Color3.new(1, 1, 1)
                hueSliderBtn.BorderSizePixel = 0
                hueSliderBtn.Position = UDim2.new(0, 1, 0, 1)
                hueSliderBtn.Size = UDim2.new(1, -2, 1, -2)
                hueSliderBtn.Text = ""
                hueSliderBtn.ZIndex = 101
                local hueColorGradient = Instance.new("UIGradient", hueSliderBtn)
                hueColorGradient.Rotation = 90
                hueColorGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
                ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
                ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
                ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
                ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                }
                local hueCursorFrame = Instance.new("Frame")
                hueCursorFrame.Parent = colorPickerDropdown
                hueCursorFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                hueCursorFrame.BorderSizePixel = 0
                hueCursorFrame.Position = UDim2.new(0, 5, 1, -15)
                hueCursorFrame.Size = UDim2.new(1, -10, 0, 10)
                hueCursorFrame.ZIndex = 100
                local optionPadding = Instance.new("TextButton")
                optionPadding.Parent = hueCursorFrame
                optionPadding.BackgroundColor3 = Color3.new(1, 1, 1)
                optionPadding.BorderSizePixel = 0
                optionPadding.Position = UDim2.new(0, 1, 0, 1)
                optionPadding.Size = UDim2.new(1, -2, 1, -2)
                optionPadding.Text = ""
                optionPadding.ZIndex = 101
                local optionHoverGradient = Instance.new("UIGradient", optionPadding)
                optionHoverGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                }
                local hue, sat, v = colorToHSV(colorValue)
                local function updateColorPicker()
                  local selectedHSVColor = Color3.fromHSV(hue / 360, sat, v)
                  svPickerBtn.BackgroundColor3 = Color3.fromHSV(hue / 360, 1, 1)
                  colorPreviewBtn.BackgroundColor3 = selectedHSVColor
                  optionHoverGradient.Color = ColorSequence.new{
                  ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                  ColorSequenceKeypoint.new(1, selectedHSVColor)
                  }
                  Library.Flags[flagId] = {R = selectedHSVColor.R, G = selectedHSVColor.G, B = selectedHSVColor.B, A = alphaValue}
                  pcall(callback, selectedHSVColor, alphaValue)
                end
                local isDraggingSV, isDraggingHue, isDraggingAlpha = false, false, false
                local function updateSV(input)
                  sat = math.clamp((input.Position.X - svPickerBtn.AbsolutePosition.X) / svPickerBtn.AbsoluteSize.X, 0, 1)
                  v = 1 - math.clamp((input.Position.Y - svPickerBtn.AbsolutePosition.Y) / svPickerBtn.AbsoluteSize.Y, 0, 1)
                  updateColorPicker()
                end
                local function updateHue(input)
                  hue = (math.clamp((input.Position.Y - hueSliderBtn.AbsolutePosition.Y) / hueSliderBtn.AbsoluteSize.Y, 0, 1)) * 360
                  updateColorPicker()
                end
                local function onColorPickerDrag(input)
                  alphaValue = math.clamp((input.Position.X - optionPadding.AbsolutePosition.X) / optionPadding.AbsoluteSize.X, 0, 1)
                  updateColorPicker()
                end
                svPickerBtn.InputBegan:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingSV = true
                  updateSV(input) end
                end)
                hueSliderBtn.InputBegan:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingHue = true
                  updateHue(input) end
                end)
                optionPadding.InputBegan:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 then isDraggingAlpha = true
                  onColorPickerDrag(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    isDraggingSV, isDraggingHue, isDraggingAlpha = false, false, false
                  end
                end)
                UserInputService.InputChanged:Connect(function(input)
                  if input.UserInputType == Enum.UserInputType.MouseMovement then
                  if isDraggingSV then updateSV(input) end
                  if isDraggingHue then updateHue(input) end
                  if isDraggingAlpha then onColorPickerDrag(input) end
                  end
                end)
                colorPreviewBtn.MouseButton1Click:Connect(function()
                  dropdownOpen = not dropdownOpen
                  colorPickerDropdown.Visible = dropdownOpen
                end)
                Library.Elements[flagId] = function(val)
                  if type(val) == "table" and val.R then
                    local colorInput = Color3.new(val.R, val.G, val.B)
                    hue, sat, v = colorToHSV(colorInput)
                    alphaValue = val.A or 1
                    updateColorPicker()
                  end
                end
                updateColorPicker()
              end
              return Section
            end
            return Tab
          end
          return Window
        end

return Library
