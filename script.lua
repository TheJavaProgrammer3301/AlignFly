return function(Options)
	--Services
	local Players = game:GetService("Players");
	local RunService = game:GetService("RunService");
	local UserInputService = game:GetService("UserInputService");
	--Misc
	local LocalPlayer = Players.LocalPlayer;
	local Camera = workspace.CurrentCamera;
	local MoveDirection = Vector3.new(0, 0, 0);
	--Components
	local TeleportationPart = Instance.new("Part");
	TeleportationPart.CanCollide = false;
	TeleportationPart.Anchored = true;
	TeleportationPart.Transparency = 1;

	local Attachment0 = Instance.new("Attachment");
	Attachment0.Parent = TeleportationPart;

	local Attachment1 = Instance.new("Attachment");
	Attachment1.Parent = TeleportationPart;

	local AlignOrientation = Instance.new("AlignOrientation");
	AlignOrientation.Attachment0 = Attachment0;
	AlignOrientation.Attachment1 = Attachment1;
	AlignOrientation.RigidityEnabled = true;
	AlignOrientation.Parent = TeleportationPart;

	local AlignPosition = Instance.new("AlignPosition");
	AlignPosition.Attachment0 = Attachment0;
	AlignPosition.Attachment1 = Attachment1;
	AlignPosition.RigidityEnabled = true;
	AlignPosition.Parent = TeleportationPart;

	local Active = false;

	local Focused = {}

	local function IsKeyDown(KeyCode)
		return UserInputService:IsKeyDown(KeyCode) and #Focused == 0;
	end
	
	local function CreateElement(Parent, Type: string, Properties)
		local NewObject = Instance.new(Type);

		for Key, Value in pairs(Properties) do
			NewObject[Key] = Value;
		end

		NewObject.Parent = Parent;
		return NewObject;
	end

	RunService.RenderStepped:Connect(function()
		if (Active) then
			if (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character:FindFirstChild("Humanoid")) then
				Attachment0.Parent = LocalPlayer.Character.PrimaryPart;

				if (MoveDirection ~= Vector3.zero) then
					TeleportationPart.CFrame = CFrame.new(TeleportationPart.CFrame.Position) * (Camera.CFrame - Camera.CFrame.Position) * CFrame.new(MoveDirection);
				else
					TeleportationPart.CFrame = LocalPlayer.Character.PrimaryPart.CFrame;
				end
			end

			MoveDirection = Vector3.new(
				(IsKeyDown(Enum.KeyCode.A)) and -1 or (IsKeyDown(Enum.KeyCode.D)) and 1 or 0,
				(IsKeyDown(Options.Down)) and -1 or (IsKeyDown(Options.Up)) and 1 or 0,
				(IsKeyDown(Enum.KeyCode.W)) and -1 or (IsKeyDown(Enum.KeyCode.S)) and 1 or 0
			);

			TeleportationPart.Parent = workspace;
		end
	end);

	local function RegisterFocuser(Object: TextBox)
		if (Object:IsA("TextBox")) then
			Object.Focused:Connect(function()
				if (not table.find(Focused, Object)) then
					table.insert(Focused, Object);
				end
			end);

			Object.FocusLost:Connect(function()
				if (table.find(Focused, Object)) then
					table.remove(Focused, table.find(Focused, Object));
				end
			end);
		end
	end

	game.DescendantAdded:Connect(RegisterFocuser);

	for _, Child in pairs(game:GetDescendants()) do
		RegisterFocuser(Child);
	end

	local function RefreshActive(State)
		if (State) then
			if (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character:FindFirstChild("Humanoid")) then
				TeleportationPart.CFrame = LocalPlayer.Character.PrimaryPart.CFrame;
			end
		else

		end
		AlignOrientation.Enabled = State;
		AlignPosition.Enabled = State;
		Active = State;
	end

	UserInputService.InputBegan:Connect(function(Input: InputObject)
		if (#Focused == 0) then
			if (Input.KeyCode == Options.Toggle) then
				RefreshActive(not Active);
			end
		end
		
		if (Input.KeyCode == Enum.KeyCode.F4) then
			RootGUI.Enabled = not RootGUI.Enabled;
		end
	end);

	--UI
	local CurrentFocusedBinding = nil;

	RootGUI = CreateElement(LocalPlayer.PlayerGui, "ScreenGui", {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		Enabled = false,
		DisplayOrder = math.huge
	});

	local RootMenu = CreateElement(RootGUI, "Frame", {
		Name = "Main",
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0.5, -100, 1, -100)
	});

	local RootListLayout = CreateElement(RootMenu, "UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder
	});

	local RootUIStroke = CreateElement(RootMenu, "UIStroke", {
		Color = Color3.new(1, 1, 1),
		Thickness = 5
	});
	
	local function FilterKeyCodeName(Code: Enum.KeyCode)
		if (Code == Enum.KeyCode.Space) then
			return "Space";
		else
			local Success, Result = pcall(function() return string.upper(string.char(Code.Value)) end);
			
			return Success and Result or Code.Name;
		end
	end

	local function CreateTitle(Parent, Text, Size, PaddingSize)
		local Title = CreateElement(Parent, "TextLabel", {
			LayoutOrder = #RootMenu:GetChildren(),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			FontFace = Font.fromEnum(Enum.Font.Code),
			Text = Text,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = Size,
			TextXAlignment = Enum.TextXAlignment.Left
		});

		local Padding = CreateElement(Title, "UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, PaddingSize),
			PaddingRight = UDim.new(0, PaddingSize),
			PaddingTop = UDim.new(0, 10)
		});

		local Stroke = CreateElement(Title, "UIStroke", {
			Color = Color3.new(0, 0, 0)
		});

		return Title;
	end

	local function CreateBinding(Label, BindingName)
		local Binding = CreateElement(RootMenu, "Frame", {
			BackgroundTransparency = 1,
			LayoutOrder = #RootMenu:GetChildren(),
			Size = UDim2.new(1, 0, 0, 55),
		});

		local Title = CreateTitle(Binding, Label, 35, 50);

		local Button = CreateElement(Binding, "TextButton", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			TextTransparency = 1,
			Size = UDim2.new(0, 75, 0, 30)
		});

		local ButtonStroke = CreateElement(Button, "UIStroke", {
			Color = Color3.new(1, 1, 1),
			Thickness = 5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		});
		
		local ButtonPadding = CreateElement(Button, "UIPadding", {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
		});
		
		local ButtonLabel = CreateElement(Button, "TextLabel", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 65, 1, 0),
			--AnchorPoint = Vector2.new(0.5, 0),
			--Position = UDim2.new(0.5, 0, 0, 0),
			FontFace = Font.fromEnum(Enum.Font.Code),
			Text = FilterKeyCodeName(Options[BindingName]),
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 25,
		});

		local ButtonLabelStroke = CreateElement(ButtonLabel, "UIStroke", {

		});

		Button.MouseButton1Up:Connect(function()
			if (not CurrentFocusedBinding) then
				CurrentFocusedBinding = BindingName;
				ButtonLabel.Text = "";
			end
		end);

		UserInputService.InputEnded:Connect(function(Input: InputObject)
			if (CurrentFocusedBinding == BindingName and Input.UserInputType == Enum.UserInputType.Keyboard) then
				Options[BindingName] = Input.KeyCode;
				ButtonLabel.Text = FilterKeyCodeName(Options[BindingName]);
				CurrentFocusedBinding = nil;
			end
		end);

		return Binding;
	end

	local MainTitle = CreateTitle(RootMenu, "AlignFly", 50, 25);

	local KeybindsTitle = CreateTitle(RootMenu, "Keybinds", 35, 25);

	local BindingUp = CreateBinding("Fly up", "Up");
	
	local BindingDown = CreateBinding("Fly down", "Down");
	
	local BindingToggle = CreateBinding("Toggle flight", "Toggle");
end;
