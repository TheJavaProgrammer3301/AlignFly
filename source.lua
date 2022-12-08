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

--Keybinds
local Options = {

};

local Focused = {}

function IsKeyDown(KeyCode)
	return UserInputService:IsKeyDown(KeyCode) and #Focused == 0;
end

RunService.RenderStepped:Connect(function()
	if (LocalPlayer.Character and LocalPlayer.Character.PrimaryPart and LocalPlayer.Character:FindFirstChild("Humanoid")) then
		Attachment0.Parent = LocalPlayer.Character.PrimaryPart;

		TeleportationPart.CFrame = CFrame.new(TeleportationPart.CFrame.Position) * (Camera.CFrame - Camera.CFrame.Position) * CFrame.new(MoveDirection);
	end

	MoveDirection = Vector3.new(
		(IsKeyDown(Enum.KeyCode.A)) and -1 or (IsKeyDown(Enum.KeyCode.D)) and 1 or 0,
		(IsKeyDown(Options.Down)) and -1 or (IsKeyDown(Options.Up)) and 1 or 0,
		(IsKeyDown(Enum.KeyCode.W)) and -1 or (IsKeyDown(Enum.KeyCode.S)) and 1 or 0
	);

	TeleportationPart.Parent = workspace;
end);

function RegisterFocuser(Object: TextBox)
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

return function(NewOptions)
	Options = NewOptions;
end;
