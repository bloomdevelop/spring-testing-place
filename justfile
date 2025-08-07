configure:
    pnpm env use lts
    aftman add UpliftGames/wally
    pnpm i
    wally install

dev:
    pnpm watch
    rojo serve