import React, { useEffect, useState, useRef } from "@rbxts/react";
import { createRoot } from "@rbxts/react-roblox";
const Players = game.GetService("Players");
const TweenService = game.GetService("TweenService");

function HealthBarComponent() {
    const Player = Players.LocalPlayer;
    const [humanoid, setHumanoid] = useState<Humanoid | undefined>(undefined);
    const [currentHealth, setCurrentHealth] = useState(100);
    const currentTween = useRef<Tween>();

    const tweenSize = (newSize: UDim2) => {
        if (barRef.current) {
            if (currentTween.current) {
                currentTween.current.Cancel();
            }

            const tween = TweenService.Create(
                barRef.current,
                new TweenInfo(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Size: newSize }
            );

            currentTween.current = tween;
            tween.Play();

            tween.Completed.Once(() => {
                if (currentTween.current === tween) {
                    currentTween.current = undefined;
                }
            });
        }
    };

    const barRef = useRef<Frame>(); useEffect(() => {
        let healthChangeConnection: RBXScriptConnection | undefined;
        let maxHealthChangeConnection: RBXScriptConnection | undefined;

        const setupHumanoid = (character: Model) => {
            const newHumanoid = character.FindFirstChildOfClass("Humanoid") as Humanoid;
            if (newHumanoid) {
                setHumanoid(newHumanoid);
                const updateHealth = () => {
                    const healthPercent = math.clamp(newHumanoid.Health / newHumanoid.MaxHealth, 0, 1);
                    const newSize = new UDim2(healthPercent, 0, 1, 0);
                    setCurrentHealth(math.floor(newHumanoid.Health));
                    tweenSize(newSize);
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
        Size: new UDim2(0, 320, 0, 40),
        Position: new UDim2(1, -10, 0.5, 0),
        AnchorPoint: new Vector2(1, 0.5),
        BackgroundColor3: new Color3(0, 0, 0),
        BackgroundTransparency: 1,
        BorderSizePixel: 0,
    } as Frame;

    const BarBackgroundProperty = {
        Size: new UDim2(1, -20, 0, 20),
        Position: new UDim2(0.5, 0, 0.5, 0),
        AnchorPoint: new Vector2(0.5, 0.5),
        BackgroundColor3: new Color3(0, 0, 0),
        BackgroundTransparency: 0.5,
        BorderSizePixel: 0,
    } as Frame;

    const BarFillProperty = {
        Size: new UDim2(1, 0, 1, 0),
        Position: new UDim2(0, 0, 0, 0),
        AnchorPoint: new Vector2(0, 0),
        BackgroundColor3: new Color3(0.36, 1, 0.36),
        BackgroundTransparency: 0,
        BorderSizePixel: 0,
    } as Frame;

    const GradientProperty = {
        Color: new ColorSequence([
            new ColorSequenceKeypoint(0, new Color3(0, 0.5, 0)),
            new ColorSequenceKeypoint(1, new Color3(0, 0.8, 0)),
        ]),
        Transparency: new NumberSequence(0),
    } as UIGradient;

    return (
        <frame {...ContainerProperty}>
            <frame {...BarBackgroundProperty}>
                <uistroke Color={new Color3(0, 0, 0)} Thickness={1} />
                <uicorner CornerRadius={new UDim(0, 999)} />
                <frame {...BarFillProperty} ref={barRef}>
                    <uicorner CornerRadius={new UDim(0, 999)} />
                    <uigradient {...GradientProperty} />
                </frame>
                <textlabel
                    Text={`${currentHealth}`}
                    Size={new UDim2(1, 0, 1, 0)}
                    Position={new UDim2(0.5, 0, 0.5, 0)}
                    AnchorPoint={new Vector2(0.5, 0.5)}
                    TextColor3={new Color3(1, 1, 1)}
                    TextSize={14}
                    Font={Enum.Font.GothamBold}
                    BackgroundTransparency={1}
                    BorderSizePixel={0}
                    TextXAlignment={Enum.TextXAlignment.Right}
                    ZIndex={2}
                >
                    <uipadding PaddingRight={new UDim(0, 10)} />
                    <uistroke ApplyStrokeMode={"Contextual"} Color={new Color3(0, 0, 0)} Thickness={1} />
                </textlabel>
            </frame>
        </frame>
    );
}

const handle = new Instance("ScreenGui");
handle.Name = "HealthHandle";
handle.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets;
handle.ResetOnSpawn = false; // Checking if it does work
handle.Parent = Players.LocalPlayer.WaitForChild("PlayerGui");

const root = createRoot(handle);
root.render(<HealthBarComponent />);