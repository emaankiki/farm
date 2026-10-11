local H = workspace.Map.Houses
local P = game:GetService("Players").LocalPlayer
local T = game:GetService("TeleportService")
local C = game:GetService("CoreGui")

local Stop = false

local function getBuyButton()
    local O = C:FindFirstChild("FoundationOverlay")
    local S = O and O:FindFirstChild("SafeAreaFrame")
    local A = S and S:FindFirstChild("OverlayPortal")
    local B = A and A:FindFirstChild("SheetContainer")
    local F = B and B:FindFirstChild("Frame")
    local D = F and F:FindFirstChild("Sheet")
    local E = D and D:FindFirstChild("Content")
    local R = E and E:FindFirstChild("Actions")
    local N = R and R:FindFirstChild("1")
    return N and N:FindFirstChild("BuyButton")
end

local function checkBuy()
    local B = getBuyButton()
    if B and B.Visible then
        Stop = true
        return true
    end
    return false
end

C.DescendantAdded:Connect(function(V)
    if V.Name == "BuyButton" then
        task.defer(checkBuy)
    end
end)

task.spawn(function()
    while not Stop do
        checkBuy()
        task.wait(0.1)
    end
end)

local function getPrompts()
    local A = {}

    for _, V in ipairs(H:GetChildren()) do
        local D = V:FindFirstChild("Door")
        local K = D and D:FindFirstChild("KnockPoint")
        local Q = K and K:FindFirstChild("KnockPrompt")

        if K and K:IsA("BasePart") and Q and Q:IsA("ProximityPrompt") then
            table.insert(A, {K, Q})
        end
    end

    return A
end

while not Stop do
    local A = getPrompts()

    for _, V in ipairs(A) do
        if Stop then break end
        if checkBuy() then break end

        local K, Q = V[1], V[2]

        if Q.Parent and Q.ActionText == "Knock" then
            local R = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
            if R then
                R.CFrame = K.CFrame
            end

            while not Stop and Q.Parent and Q.ActionText == "Knock" do
                if checkBuy() then break end
                fireproximityprompt(Q)
                task.wait(0.2)
            end
        end
    end

    if Stop or checkBuy() then
        break
    end

    A = getPrompts()

    if #A > 0 then
        local All = true

        for _, V in ipairs(A) do
            local Q = V[2]

            if not Q.Parent or not Q.ActionText:match("^Knock again in %d+s$") then
                All = false
                break
            end
        end

        if All and not Stop then
            T:TeleportToPlaceInstance(game.PlaceId, game.JobId, P)
            break
        end
    end

    task.wait(1)
end
