import React, { useEffect, useState } from "@rbxts/react";
import { createRoot } from "@rbxts/react-roblox";
const Players = game.GetService("Players");

function HealthBarComponent() {
    const Player = Players.LocalPlayer;
    const [humanoid, setHumanoid] = useState<Humanoid | undefined>(undefined);
    const [size, setSize] = useState<UDim2>(new UDim2(1, 0, 1, 0));

    useEffect(() => {
        let healthChangeConnection: RBXScriptConnection | undefined;
        let maxHealthChangeConnection: RBXScriptConnection | undefined;

        const setupHumanoid = (character: Model) => {
            const newHumanoid = character.FindFirstChildOfClass("Humanoid") as Humanoid;
            if (newHumanoid) {
                setHumanoid(newHumanoid);
                const updateHealth = () => {
                    const health = math.clamp(newHumanoid.Health / newHumanoid.MaxHealth, 0, 1);
                    setSize(new UDim2(health, 0, 1, 0));
                };
                updateHealth();
                healthChangeConnection = newHumanoid.GetPropertyChangedSignal("Health").Connect(updateHealth);
                maxHealthChangeConnection = newHumanoid.GetPropertyChangedSignal("MaxHealth").Connect(updateHealth);
            }
        };

        // Initial setup
        if (Player.Character) {
            setupHumanoid(Player.Character);
        }

        // Listen for respawn
        const charAddedConn = Player.CharacterAdded.Connect(setupHumanoid);

        return () => {
            healthChangeConnection?.Disconnect();
            maxHealthChangeConnection?.Disconnect();
            charAddedConn.Disconnect();
        };
    }, []);

    const ContainerProperty = {
        Size: new UDim2(0, 320, 0, 60),
        Position: new UDim2(0, 20, 1, -20),
        AnchorPoint: new Vector2(0, 1),
        BackgroundColor3: new Color3(0, 0, 0),
        BackgroundTransparency: 0.3,
        BorderSizePixel: 0,
    } as Frame;

    const BarBackgroundProperty = {
        Size: new UDim2(0, 300, 0, 20),
        Position: new UDim2(0, 10, 0, 30),
        AnchorPoint: new Vector2(0, 0),
        BackgroundColor3: new Color3(0.15, 0.15, 0.15),
        BackgroundTransparency: 0.2,
        BorderSizePixel: 0,
    } as Frame;

    // Calculate health percent for color
    let healthPercent = 1;
    if (humanoid && humanoid.MaxHealth > 0) {
        healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1);
    }

    // Color: green (>60%), yellow (30-60%), red (<30%)
    let healthColor: Color3;
    if (healthPercent > 0.6) {
        healthColor = new Color3(0.2, 0.7, 0.2); // green
    } else if (healthPercent > 0.3) {
        healthColor = new Color3(0.9, 0.8, 0.2); // yellow
    } else {
        healthColor = new Color3(0.8, 0.2, 0.2); // red
    }

    const BarFillProperty = {
        Size: size,
        Position: new UDim2(0, 0, 0, 0),
        AnchorPoint: new Vector2(0, 0),
        BackgroundColor3: healthColor,
        BackgroundTransparency: 0,
        BorderSizePixel: 0,
    } as Frame;

    const UIPaddingProperty = {
        PaddingTop: new UDim(0, 5),
        PaddingBottom: new UDim(0, 5),
    } as UIPadding

    return (
        <frame {...ContainerProperty}>
            <uicorner CornerRadius={new UDim(0, 8)} />
            <uipadding {...UIPaddingProperty} />
            <textlabel
                Text={`Health: ${humanoid ? math.floor(humanoid.Health) : "-"}`}
                Size={new UDim2(1, 0, 0, 30)}
                Position={new UDim2(0, 0, 0, 0)}
                TextColor3={new Color3(1, 1, 1)}
                TextScaled={true}
                BackgroundTransparency={1}
                BorderSizePixel={0}
            />
            <frame {...BarBackgroundProperty}>
                <uicorner CornerRadius={new UDim(0, 5)} />
                <frame {...BarFillProperty}>
                    <uicorner CornerRadius={new UDim(0, 5)} />
                </frame>
            </frame>
        </frame>
    );
}

const handle = new Instance("ScreenGui");
handle.Name = "HealthHandle";
handle.ResetOnSpawn = false; // Checking if it does work
handle.Parent = Players.LocalPlayer.WaitForChild("PlayerGui");

const root = createRoot(handle);
root.render(<HealthBarComponent />);