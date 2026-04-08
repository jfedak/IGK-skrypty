const CORRIDOR_WIDTH = 5
const CASTLE_SIZE = 10
const CASTLE_HEIGHT = 8

player.onChat("castle", function() {
    makeFloor(CASTLE_SIZE + CORRIDOR_WIDTH)
    makeCeiling(CASTLE_SIZE, CORRIDOR_WIDTH, CASTLE_HEIGHT)
    makeWalls(CASTLE_SIZE, CASTLE_HEIGHT, false)
    makeWalls(CASTLE_SIZE + CORRIDOR_WIDTH, CASTLE_HEIGHT, true)
    makeWindows()
    makeYard()
    makeMoat()
    makeBridge()
    makeGate()
    makeAllTowers()
    makeRailing()
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
    }
}

function makeRailing() {
    builder.teleportTo(pos(-10, 8, 9))
    builder.face(NORTH)
    for (let i = 0; i < 4; i++) {
        builder.setOrigin()
        for (let j = 0; j < 2; j++) {
            builder.mark()
            builder.move(FORWARD, 18)
            builder.fill(Block.CobblestoneWall)
            builder.teleportToOrigin()
            builder.shift(0, 0, 5)
        }
        builder.teleportToOrigin()
        builder.shift(19, 0, -1)
        builder.turn(RIGHT_TURN)
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

function makeGate() {
    blocks.fill(Block.Air, pos(-2, 0, 15), pos(2, 2, 15))
    blocks.fill(Block.OakFence, pos(-2, 3, 15), pos(2, 5, 15))
    blocks.fill(Block.OakWoodSlab, pos(-2, 0, 15), pos(2, 0, 15))
    blocks.place(Block.StoneBricks, pos(-2, 5, 15))
    blocks.place(Block.StoneBricks, pos(2, 5, 15))

    for (let i = 2; i >= 0; i -= 2) {
        blocks.fill(Block.Cobblestone, pos(-2, 1, 16-i), pos(2, 6, 16-i))
        blocks.fill(Block.Air, pos(-1, 1, 16-i), pos(1, 4, 16-i))
        blocks.place(Block.Air, pos(-2, 6, 16 - i))
        blocks.place(Block.Air, pos(2, 6, 16 - i))
        blocks.place(blocks.blockWithData(Block.CobblestoneStairs, 0), pos(-2, 5, 16 - i))
        blocks.place(blocks.blockWithData(Block.CobblestoneStairs, 0), pos(-1, 6, 16-i))
        blocks.place(blocks.blockWithData(Block.CobblestoneStairs, 1), pos(2, 5, 16 - i))
        blocks.place(blocks.blockWithData(Block.CobblestoneStairs, 1), pos(1, 6, 16 - i))
        blocks.place(blocks.blockWithData(Block.CobblestoneStairs, 5), pos(-1, 4, 16 - i))
        blocks.place(blocks.blockWithData(Block.CobblestoneStairs, 4), pos(1, 4, 16 - i))
    }

    blocks.place(Block.Cobblestone, pos(-2, 0, 14))
    blocks.place(Block.Cobblestone, pos(2, 0, 14))

    player.say("gate created")
}

function makeTower() {
    function makeDoors(a: number, b: number) {
        builder.mark()
        builder.shift(1, 1, 0)
        builder.fill(AIR)
        builder.shift(-1, 1, 0)
        builder.place(blocks.blockWithData(STONE_BRICK_STAIRS, a))
        builder.shift(1, 0, 0)
        builder.place(blocks.blockWithData(STONE_BRICK_STAIRS, b))
        builder.shift(-1, -2, 0)
    }

    builder.startStructure()
    for(let i = 0; i < 4; i++) {
        builder.mark()
        builder.move(FORWARD, 5)
        builder.setOrigin()
        builder.move(UP, 10)
        builder.fill(Block.StoneBricks)
        builder.teleportToOrigin()
        builder.turn(LEFT_TURN)
    }

    builder.setOrigin()
    builder.turn(LEFT_TURN)
    builder.move(FORWARD, 2)
    makeDoors(4, 5)
    builder.shift(3, 0, -2)
    builder.turn(RIGHT_TURN)
    makeDoors(6, 7)

    builder.teleportToOrigin()
    builder.face(NORTH)
    builder.shift(1, 0, 1)
    builder.setOrigin()
    builder.place(Block.StoneBricksSlab)

    let up = 1
    for (let x = 0; x < 7; x++) {
        for(let y = 0; y < 3; y++) {
            builder.move(FORWARD, 1)
            builder.place(blocks.blockWithData(Block.StoneBricksSlab, up * 8))
            up += 1
            if (up == 2) {
                builder.move(UP, 1)
                up = 0
            }
        }
        builder.turn(LEFT_TURN)
    }

    builder.teleportToOrigin()
    builder.face(NORTH)

    builder.move(UP, 10)
    builder.setOrigin()
    builder.mark()
    builder.shift(3, 0, 2)
    builder.fill(blocks.blockWithData(Block.StoneBricksSlab, 8))
    builder.mark()
    builder.move(RIGHT, 1)
    builder.fill(Block.Air)

    builder.teleportToOrigin()
    let innerWallRules = [
        [1, 0], [0 , -2], [2, 0], [0, 4], [-3, 0]
    ]

    builder.shift(1, 1, 2)
    for (let dir of innerWallRules) {
        let [forward, left] = dir
        builder.mark()
        builder.shift(forward, 0, left)
        builder.fill(blocks.blockWithData(Block.CobblestoneWall, 7))
    }

    builder.teleportToOrigin()
    let originPosition = builder.position()
    builder.shift(-3, 0, -3)

    for (let i = 0; i < 4; i++) {
        builder.mark()
        builder.move(SixDirection.Forward, 9)
        builder.setOrigin()
        builder.move(SixDirection.Left, 2)
        builder.fill(Block.StoneBricks)
        builder.teleportToOrigin()
        builder.turn(TurnDirection.Left)
    }

    builder.move(SixDirection.Up, 1)
    for (let i = 0; i < 4; i++) {
        builder.mark()
        builder.move(SixDirection.Forward, 9)
        builder.fill(blocks.blockWithData(Block.CobblestoneWall, 7))
        builder.turn(TurnDirection.Left)
    }

    builder.teleportTo(originPosition)
    builder.shift(-3, -1, -3)

    let stairsOrientation = [ 5, 6, 4, 7 ]
    for (let i = 0; i < 4; i++) {
        builder.mark()
        builder.setOrigin()
        builder.move(SixDirection.Forward, 9)
        builder.fill(blocks.blockWithData(STONE_BRICK_STAIRS, stairsOrientation[i]))
        builder.teleportToOrigin()
        builder.shift(1, -1, 1)
        builder.mark()
        builder.move(SixDirection.Forward, 7)
        builder.fill(blocks.blockWithData(STONE_BRICK_STAIRS, stairsOrientation[i]))
        builder.teleportToOrigin()
        builder.move(SixDirection.Forward, 9)
        builder.turn(LEFT_TURN)
    }

    builder.saveStructure("tower")
}

function makeAllTowers() {
    builder.teleportTo(pos(-10, 8, 15))
    builder.face(NORTH)
    builder.pushState()
    makeTower()
    builder.popState()
    builder.shift(7, 0, 7)

    for (let i = 0; i < 4; i++) {
        builder.loadStructure("tower", (i + 2) % 4);
        builder.move(FORWARD, 25);
        builder.turn(RIGHT_TURN);
    }

    player.say("towers created")
}
