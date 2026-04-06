const CORRIDOR_WIDTH = 5
const CASTLE_SIZE = 10
const CASTLE_HEIGHT = 8

player.onChat("castle", function() {
    makeFloor(CASTLE_SIZE + CORRIDOR_WIDTH)
    makeCeiling(CASTLE_SIZE, CORRIDOR_WIDTH, CASTLE_HEIGHT)
    makeWalls(CASTLE_SIZE, CASTLE_HEIGHT, false)
    makeWalls(CASTLE_SIZE + CORRIDOR_WIDTH, CASTLE_HEIGHT, true)
    makeStairs(CASTLE_SIZE, CASTLE_HEIGHT)
    makeWindows()
    makeYard()
    makeMoat()
    makeBridge()
    player.say("castle is finished")
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

function makeWindows() {
    let holes = [
        // front and back
        [pos(-7, 2, 15), pos(-5, 5, 15)],
        [pos(-1, 2, 15), pos(1, 5, 15)],
        [pos(5, 2, 15), pos(7, 5, 15)],
        [pos(-7, 2, -15), pos(-5, 5, -15)],
        [pos(-1, 2, -15), pos(1, 5, -15)],
        [pos(5, 2, -15), pos(7, 5, -15)],
        // sides
        [pos(15, 2, -7), pos(15, 5, -5)],
        [pos(15, 2, -1), pos(15, 5, 1)],
        [pos(15, 2, 5), pos(15, 5, 7)],
        [pos(-15, 2, -7), pos(-15, 5, -5)],
        [pos(-15, 2, -1), pos(-15, 5, 1)],
        [pos(-15, 2, 5), pos(-15, 5, 7)],
    ]

    let wall = blocks.blockWithData(Block.CobblestoneWall, 7)

    
    for (let hole of holes) {
        let [start, end] = hole
        let x = (start.getValue(0) + end.getValue(0)) / 2
        let z = (start.getValue(2) + end.getValue(2)) / 2


        blocks.fill(Block.Air, start, end)
        blocks.fill(wall, pos(x, 2, z), pos(x, 4, z))
        blocks.place(Block.StoneBricks, pos(x, 5, z))

        let side = (start.getValue(0) == end.getValue(0))
        let stairs

        if (side) {
            stairs = [
                blocks.blockWithData(Block.StoneBrickStairs, 7),
                blocks.blockWithData(Block.StoneBrickStairs, 6)
            ]
        } else {
            stairs = [
                blocks.blockWithData(Block.StoneBrickStairs, 5),
                blocks.blockWithData(Block.StoneBrickStairs, 4)
            ]
        }

        blocks.place(stairs[0], start.add(pos(0, 3, 0)))
        blocks.place(stairs[1], end)
    }
}

function makeYard() {
    let holes = [
        [pos(-10, 2, -8), pos(-10, 4, 8)],
        [pos(10, 2, -8), pos(10, 4, 8)],
        [pos(-8, 2, -10), pos(8, 4, -10)],
        [pos(-8, 2, 10), pos(8, 4, 10)],
    ];

    let pillarCoords = []
    for (let hole of holes) {
        let [start, end] = hole
        blocks.fill(Block.Air, start, end)

        let side = (start.getValue(0) == end.getValue(0))
        let coords

        if (side) {
            let x = start.getValue(0)
            pillarCoords.push([x, -6])
            pillarCoords.push([x, -3])
            pillarCoords.push([x, 3])
            pillarCoords.push([x, 6])
        } else {
            let z = start.getValue(2)
            pillarCoords.push([-6, z])
            pillarCoords.push([-3, z])
            pillarCoords.push([3, z])
            pillarCoords.push([6, z])
        }
    }

    blocks.fill(Block.Air, pos(-1, 0, 10), pos(1, 4, 10))
    blocks.fill(Block.Air, pos(-1, 0, -10), pos(1, 4, -10))
    blocks.fill(Block.Air, pos(10, 0, -1), pos(10, 4, 1))
    blocks.fill(Block.Air, pos(-10, 0, -1), pos(-10, 4, 1))

    let pillarBlock = blocks.blockWithData(Block.CobblestoneWall, 7)
    for (let pillar of pillarCoords) {
        let [x, z] = pillar
        blocks.fill(pillarBlock, pos(x, 2, z), pos(x, 4, z))
    }

    player.say("yard created")
}

function makeMoat() {
    builder.teleportTo(pos(-22, -1, 22))
    builder.face(CompassDirection.North)

    for (let i = 0; i < 4; i++) {
        builder.mark()
        builder.move(SixDirection.Forward, 44)
        builder.setOrigin()
        builder.move(SixDirection.Right, 6)
        builder.move(SixDirection.Down, 5)
        builder.fill(Block.Water)
        builder.teleportToOrigin()
        builder.turn(TurnDirection.Right)
    }

    player.say("moat created")
}

function makeBridge() {
    blocks.fill(Block.PlanksOak, pos(-2, 0, 16), pos(2, 0, 23))
    blocks.fill(Block.OakWoodSlab, pos(-2, 0, 24), pos(2, 0, 24))
    blocks.fill(Block.OakFence, pos(-2, 1, 16), pos(-2, 1, 25))
    blocks.fill(Block.OakFence, pos(2, 1, 16), pos(2, 1, 25))
    blocks.fill(Block.OakFence, pos(-2, 0, 25), pos(-2, 0, 26))
    blocks.fill(Block.OakFence, pos(2, 0, 25), pos(2, 0, 26))

    player.say("bridge created")
}