const std = @import("std");
const rl = @import("raylib");

const ObjLib = @import("objects.zig");
const Obj = ObjLib.Object;
const Stellar = @import("stellar.zig").Stellar;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var stellar = Stellar.init(allocator);
    defer stellar.deinit();

    rl.initWindow(stellar.width, stellar.height, "Vgrav");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(30);
    //--------------------------------------------------------------------------------------

    // const obj_1 = Obj.init(512, 400, 40, 0.0, 0.0, 5000);
    // const obj_2 = Obj.init(700, 100, 20, -4.5, 0.2, 2000);
    // const obj_21 = Obj.init(100, 110, 5, 1.5, 0.2, 20);
    // const obj_22 = Obj.init(100, 120, 5, 1.5, 0.2, 20);
    // const obj_3 = Obj.init(600, 700, 5, 1.5, 0.2, 20);
    // const obj_3 = Obj.init(700, 50, 20, -5.0, 0.0);

    // try stellar.addObj(obj_1);
    // try stellar.addObj(obj_2);
    // try stellar.addObj(obj_21);
    // try stellar.addObj(obj_22);
    // try stellar.addObj(obj_3);

    // for (0..49) |pos| {
    //     const fpos = @as(f32, @floatFromInt(pos));
    //     const displacement = fpos * 2;
    //     const obj = Obj.init(100, 100 + displacement, 5, 1.5 + (fpos / 5), 0.1, 10);
    //     try stellar.addObj(obj);
    // }

    // for (0..49) |pos| {
    //     const fpos = @as(f32, @floatFromInt(pos));
    //     const displacement = fpos * 4;
    //     const planet = ObjLib.createPlanet(800, 100 + displacement);
    //     try stellar.addObj(planet);
    // }

    for (4..45) |ypos| {
        const fypos = @as(f32, @floatFromInt(ypos * 15));
        for (4..50) |xpos| {
            const fxpos = @as(f32, @floatFromInt(xpos * 20));
            const obj = Obj.init(fxpos, fypos, 2, 0, 0, 7000);
            try stellar.addObj(obj);
        }
    }

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);
        // update

        for (stellar.objects.items) |*obj| {
            obj.update();
        }

        // draw
        for (stellar.objects.items) |obj| {
            obj.draw();
        }
        try stellar.calcForces();
        try stellar.checkColl();
    }
}
