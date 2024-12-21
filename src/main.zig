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

    for (4..15) |ypos| {
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
        stellar.updateObjects();

        // draw
        stellar.drawObjects();

        // physics
        try stellar.calcForces();
        try stellar.checkColl();
        // update Viewport
        stellar.updateViewport();
    }
}
