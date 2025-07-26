import React, { useEffect, useState } from "@rbxts/react";
import { createRoot } from "@rbxts/react-roblox";

const Players = game.GetService("Players");
const LocalPlayer = Players.LocalPlayer;

function PlayerContainer({ player }: { player: Player }) {
    const TextLabelProperty = {
        Text: `${player.DisplayName} (@${player.Name})`,
        Size: new UDim2(1, 0, 0, 30),
        TextColor3: new Color3(1, 1, 1),
        TextScaled: true,
        BackgroundColor3: new Color3(0.15, 0.15, 0.15),
        BackgroundTransparency: 0.5,
        BorderSizePixel: 0,
    } as TextLabel;

    const UIPaddingProperty = {
        PaddingLeft: new UDim(0, 2),
        PaddingRight: new UDim(0, 2),
        PaddingTop: new UDim(0, 5),
        PaddingBottom: new UDim(0, 5),
    } as UIPadding;

    return <textlabel {...TextLabelProperty}>
        <uipadding {...UIPaddingProperty} />
        <uicorner CornerRadius={new UDim(0, 5)} />
    </textlabel>
}

function PlayerListComponent() {
    const UserInputService = game.GetService("UserInputService");
    const [visible, setVisible] = useState(true);

    useEffect(() => {
        const inputConnection = UserInputService.InputBegan.Connect((input, processed) => {
            if (!processed && input.KeyCode === Enum.KeyCode.Tab) {
                setVisible((v) => !v);
            }
        });
        return () => {
            inputConnection.Disconnect();
        };
    }, []);
    const PlayerListProperty = {
        Size: new UDim2(0, 250, 0, 0),
        AutomaticSize: Enum.AutomaticSize.Y,
        Position: new UDim2(1, -20, 0, 5),
        AnchorPoint: new Vector2(1, 0),
        BackgroundColor3: new Color3(0, 0, 0),
        BackgroundTransparency: 0.5,
        BorderSizePixel: 0,
    } as Frame;

    const UIListLayoutProperty = {
        FillDirection: Enum.FillDirection.Vertical,
        SortOrder: Enum.SortOrder.LayoutOrder,
        Padding: new UDim(0, 5),
    } as UIListLayout;

    const UIPaddingProperty = {
        PaddingLeft: new UDim(0, 5),
        PaddingRight: new UDim(0, 5),
        PaddingTop: new UDim(0, 5),
        PaddingBottom: new UDim(0, 5),
    } as UIPadding;

    const [players, setPlayers] = useState<Player[]>(() => Players.GetPlayers());

    // Group players by team if teams exist
    const teams = new Map<Team | undefined, Player[]>();
    let hasTeams = false;
    for (const player of players) {
        const team = player.Team;
        if (team !== undefined && team !== undefined) hasTeams = true;
        if (!teams.has(team)) teams.set(team, []);
        teams.get(team)!.push(player);
    }

    useEffect(() => {
        const addedConnection = Players.PlayerAdded.Connect((player) => {
            setPlayers((current) => [...current, player]);
        });

        const removingConnection = Players.PlayerRemoving.Connect((player) => {
            setPlayers((current) => current.filter((p) => p !== player));
        });

        // Listen for team changes
        const teamConnections = new Map<Player, RBXScriptConnection>();
        function connectTeamChanged(player: Player) {
            const conn = player.GetPropertyChangedSignal("Team").Connect(() => {
                setPlayers((current) => [...current]); // Triggers re-render
            });
            teamConnections.set(player, conn);
        }
        // Connect for all current players
        players.forEach(connectTeamChanged);
        // Connect for new players
        const playerAddedConn = Players.PlayerAdded.Connect(connectTeamChanged);

        return () => {
            addedConnection.Disconnect();
            removingConnection.Disconnect();
            playerAddedConn.Disconnect();
            teamConnections.forEach((conn) => conn.Disconnect());
        };
    }, [players]);

    if (visible) {
        return <frame {...PlayerListProperty}>
            <uicorner CornerRadius={new UDim(0, 7)} />
            <uipadding {...UIPaddingProperty} />
            <uilistlayout {...UIListLayoutProperty} />
            {hasTeams
                ? (() => {
                    /*
                        I have no clue why I have to use this workaround when we have only array and not map or object.
                        This is getting quite limited due how roblox-ts compiles typescript to lua/luau.
                    */
                    const arr: [Team | undefined, Player[]][] = [];
                    teams.forEach((teamPlayers, team) => {
                        arr.push([team, teamPlayers]);
                    });
                    return arr.map(([team, teamPlayers]: [Team | undefined, Player[]]) => (
                        <frame
                            key={team ? team.Name : "NoTeam"}
                            Size={new UDim2(1, 0, 0, 0)}
                            BackgroundTransparency={0.4}
                            BackgroundColor3={team?.TeamColor.Color || new Color3(1, 1, 1)}
                            AutomaticSize={Enum.AutomaticSize.Y}
                            BorderSizePixel={0}
                        >
                            <uicorner CornerRadius={new UDim(0, 5)} />
                            <uilistlayout {...UIListLayoutProperty} />
                            <uipadding {...UIPaddingProperty} />
                            {team && <textlabel
                                Text={team.Name}
                                Size={new UDim2(1, 0, 0, 24)}
                                BackgroundTransparency={1}
                                TextColor3={new Color3(1, 1, 1)}
                                TextScaled={true}
                                Font={Enum.Font.BuilderSans}
                            >
                                <uistroke Color={new Color3(0, 0, 0)} ApplyStrokeMode={"Contextual"} Thickness={1} />
                            </textlabel>}
                            {teamPlayers.map((player) => (
                                <PlayerContainer key={player.UserId} player={player} />
                            ))}
                        </frame>
                    ));
                })()
                : players.map((player) => (
                    <PlayerContainer key={player.UserId} player={player} />
                ))
            }
        </frame>
    }
}

const handle = new Instance("ScreenGui");
handle.Name = "PlayerListHandle";
handle.ResetOnSpawn = false;
handle.Parent = LocalPlayer.FindFirstChildOfClass("PlayerGui");

const root = createRoot(handle);
root.render(<PlayerListComponent />);