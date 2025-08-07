# Spring's Testing Place

> [!WARNING]
> This repository doesn't have any license yet, please be careful when using.

This is the codebase for my testing place.

## File structures

```bash
/out # Output folder

/src/luau # Luau Codebase (Client, Server and Shared/Modules)
/src/typescript # Typescript Codebase (Client, Server and Shared/Modules)
```

## Developing

> [!NOTE]
> I recommend using Visual Studio Code for working with the codebase. Since the codebase contains `.vscode` directory to allow extension recommendations to allow setting things up easily and quick.

### Requirements

- `just` (Optional, if you want to confgure it manually)
- `aftman`
- `pnpm`
- Visual Studio Code (recommended) or other editors like Zed, Vim, etc...

### Configuring

I use `just` to manage tasks easily, to use this please install in the following command if you don't have it installed:

```bash
# via NPM
npm install -g rust-just #

# via DNF (Fedora)
dnf install just
# Please check on readme at https://github.com/casey/just
# There's more distrubtion which I'm not going to list
```

> [!NOTE]
> You can skip both TypeScript and Luau since `just` does this thing.

### For Working with TypeScript (Required for roblox-ts to be able to sync Luau files to Studio)

`pnpm` is required to work with TypeScript files you can install on the [installation guide](https://pnpm.io/installation), then configure the enviroment for runtime (I recommend to use LTS version instead of latest)

```bash
pnpm env use lts # if you want it globally, use "-g" option.
```

Then start installing packages with this command:

```bash
pnpm i # or pnpm install
```

### For Working with Luau

Please install [`aftman`](https://github.com/LPGhatguy/aftman) (either via Github or via Rojo VSCode plugin), then run on the following command:

```bash
aftman add UpliftGames/wally # to install required tools
# Then run wally install to instal dependencies like jsdotlua/react and jsdotlua/react-roblox
```

### Starting the compiler and serve via Rojo

To start the compiler and sync to Studio, simply run this command:

```bash
just dev
```
