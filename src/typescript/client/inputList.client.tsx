import React, { useState, useEffect } from '@rbxts/react';
import { createRoot } from '@rbxts/react-roblox';

const Players = game.GetService("Players");
const LocalPlayer = Players.LocalPlayer;

function InputListComponent() {
    const InputListProperty = {
        Size: new UDim2(0, 200, 0, 0),
        AutomaticSize: Enum.AutomaticSize.Y,
        Position: new UDim2(1, -20, 1, -20),
        AnchorPoint: new Vector2(1, 1),
        BackgroundColor3: new Color3(0, 0, 0),
        BackgroundTransparency: 0.2,
        BorderSizePixel: 0,
    } as Frame;

    const UIListLayoutProperty = {
        FillDirection: Enum.FillDirection.Vertical,
        SortOrder: Enum.SortOrder.LayoutOrder,
        Padding: new UDim(0, 2),
    } as UIListLayout;

    const keyBinds = [
        { key: "TAB", description: "Show Player List" },
        { key: "M", description: "Open Main Menu" },
    ];

    const UIPaddingProperty = {
        PaddingLeft: new UDim(0, 10),
        PaddingRight: new UDim(0, 10),
        PaddingTop: new UDim(0, 8),
        PaddingBottom: new UDim(0, 8),
    } as UIPadding;

    return (
        <frame {...InputListProperty}>
            <uicorner CornerRadius={new UDim(0, 5)} />
            <uipadding {...UIPaddingProperty} />
            <uilistlayout {...UIListLayoutProperty} />
            {keyBinds.map((bind, i) => (
                <frame
                    Size={new UDim2(1, 0, 0, 32)}
                    BackgroundTransparency={1}
                    LayoutOrder={i + 1}
                    key={bind.key}
                >
                    <frame
                        Size={new UDim2(0, 40, 0, 24)}
                        Position={new UDim2(0, 0, 0.5, 0)}
                        AnchorPoint={new Vector2(0, 0.5)}
                        BackgroundColor3={new Color3(0.95, 0.95, 0.95)}
                        BorderColor3={new Color3(0, 0, 0)}
                        BorderSizePixel={1}
                    >
                        <uistroke Color={new Color3(0, 0, 0)} Thickness={1} />
                        <uicorner CornerRadius={new UDim(0, 2)} />
                        <textlabel
                            Text={bind.key}
                            Size={new UDim2(1, 0, 1, 0)}
                            BackgroundTransparency={1}
                            TextColor3={new Color3(0, 0, 0)}
                            Font={Enum.Font.GothamBold}
                            TextSize={14}
                        />
                    </frame>
                    <textlabel
                        Text={bind.description}
                        Size={new UDim2(1, -50, 1, 0)}
                        Position={new UDim2(0, 50, 0, 0)}
                        BackgroundTransparency={1}
                        TextColor3={new Color3(1, 1, 1)}
                        Font={Enum.Font.Gotham}
                        TextSize={14}
                        TextXAlignment={Enum.TextXAlignment.Left}
                    />
                </frame>
            ))}
        </frame>
    );
}


const handle = new Instance("ScreenGui");
handle.Name = "InputList";
handle.ResetOnSpawn = false;
handle.Parent = LocalPlayer.FindFirstChildOfClass("PlayerGui");

const root = createRoot(handle);
root.render(<InputListComponent />);