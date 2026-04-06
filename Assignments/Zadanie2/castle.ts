player.onChat("castle", function() {
    const CORRIDOR_WIDTH = 5
    const CASTLE_SIZE = 5
    const CASTLE_HEIGHT = 5
    makeFloor(CASTLE_SIZE + CORRIDOR_WIDTH)
    makeCeiling(CASTLE_SIZE, CORRIDOR_WIDTH, CASTLE_HEIGHT)
    makeWalls(CASTLE_SIZE, CASTLE_HEIGHT, false)
    makeWalls(CASTLE_SIZE + CORRIDOR_WIDTH, CASTLE_HEIGHT, true)
    makeStairs(CASTLE_SIZE, CASTLE_HEIGHT)
})

function makeWallsRules(castleSize: number) {
    let rules = [
        [[-castleSize, -castleSize], [-castleSize, castleSize]],
        [[-castleSize, castleSize], [castleSize, castleSize]],
        [[castleSize, castleSize], [castleSize, -castleSize]],
        [[castleSize, -castleSize], [-castleSize, -castleSize]],
    ];

    return rules
}

function makeWalls(castleSize: number, castleHeight: number, putCobble: boolean) {
    let rules = makeWallsRules(castleSize)
    for (let rule of rules) {
        let [startPosition, endPosition, step] = rule
        let [a, b] = startPosition
        let [c, d] = endPosition

        let startBlock
        if (putCobble) {
            startBlock = Block.Cobblestone
        } else {
            startBlock = Block.StoneBricks
        }
        blocks.fill(startBlock, pos(a, 0, b), pos(c, 0, d))
        blocks.fill(Block.StoneBricks, pos(a, 1, b), pos(c, castleHeight-1, d))
        blocks.fill(Block.CobblestoneWall, pos(a, castleHeight, b), pos(c, castleHeight, d))
    }
}

function makeFloor(floorSize: number) {
    blocks.fill(Block.Stone, 
                pos(-floorSize, -1, -floorSize),
                pos(floorSize, -1, floorSize))
}

function makeCeiling(floorSize: number, corridorWidth:number, castleHeight: number) {
    floorSize += corridorWidth
    blocks.fill(Block.PolishedAndesite,
        pos(-floorSize, castleHeight-1, -floorSize),
        pos(floorSize, castleHeight-1, floorSize))

    floorSize -= (corridorWidth+1)
    blocks.fill(Block.Air,
        pos(-floorSize, castleHeight - 1, -floorSize),
        pos(floorSize, castleHeight - 1, floorSize))
}

function makeStairs(castleSize: number, castleHeight: number) {
    let x = castleSize - 1, y = castleSize - 1, h = castleHeight - 1
    let stair = blocks.blockWithData(Block.StoneBrickStairs, 2)

    blocks.place(Block.Air, pos(x, h+1, y+1))
    while(h >= 0) {
        blocks.place(stair, pos(x, h, y))
        y = y-1
        h = h-1
    }
}