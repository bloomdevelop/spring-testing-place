import React, { useState, useEffect } from '@rbxts/react';
import { createRoot } from '@rbxts/react-roblox';

function InputListComponent() {
    const InputListProperty = {
        Size: new UDim2(0, 250, 0, 0),
        AutomaticSize: Enum.AutomaticSize.Y,
        Position: new UDim2(1, -20, 1, -20),
        AnchorPoint: new Vector2(1, 1),
        BackgroundColor3: new Color3(0, 0, 0),
        BackgroundTransparency: 0.5,
        BorderSizePixel: 0,
    } as Frame;

    const UIListLayoutProperty = {
        FillDirection: Enum.FillDirection.Vertical,
        SortOrder: Enum.SortOrder.LayoutOrder,
        Padding: new UDim(0, 5),
    } as UIListLayout;

    const keyBinds = [
        { key: "TAB", description: "Show Player List" },
        { key: "M", description: "Open Main Menu" },
    ];

    return (
        <frame {...InputListProperty}>
            <uilistlayout {...UIListLayoutProperty} />
            {keyBinds.map((bind, i) => (
                <frame
                    Size={new UDim2(1, 0, 0, 40)}
                    BackgroundTransparency={1}
                    LayoutOrder={i + 1}
                    key={bind.key}
                >
                    <frame
                        Size={new UDim2(0, 50, 0, 32)}
                        Position={new UDim2(0, 0, 0.5, -16)}
                        AnchorPoint={new Vector2(0, 0.5)}
                        BackgroundColor3={new Color3(1, 1, 1)}
                        BorderColor3={new Color3(0, 0, 0)}
                        BorderSizePixel={2}
                    >
                        <textlabel
                            Text={bind.key}
                            Size={new UDim2(1, 0, 1, 0)}
                            BackgroundTransparency={1}
                            TextColor3={new Color3(0, 0, 0)}
                            Font={Enum.Font.SourceSans}
                            TextSize={18}
                        />
                    </frame>
                    <textlabel
                        Text={bind.description}
                        Size={new UDim2(0, 180, 1, 0)}
                        Position={new UDim2(0, 60, 0, 0)}
                        BackgroundTransparency={1}
                        TextColor3={new Color3(0, 0, 0)}
                        Font={Enum.Font.SourceSans}
                        TextSize={16}
                        TextXAlignment={Enum.TextXAlignment.Left}
                    />
                </frame>
            ))}
        </frame>
    );
}

const Players = game.GetService("Players");
const localPlayer = Players.LocalPlayer;
const playerGui = localPlayer?.FindFirstChildOfClass("PlayerGui");

const handle = new Instance("ScreenGui");
handle.Name = "InputList";
handle.ResetOnSpawn = false;

if (playerGui) {
    handle.Parent = playerGui;
    const root = createRoot(handle);
    root.render(<InputListComponent />);
}