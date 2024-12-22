const std = @import("std");
const rl = @import("raylib");
const Obj = @import("objects.zig").Object;

pub const Viewport = struct {
    offset: rl.Vector2,
    scale: f32,
};

pub const Stellar = struct {
    width: i32 = 1600,
    height: i32 = 900,
    color: rl.Color = rl.Color.white,
    viewport: Viewport = .{
        .offset = .{ .x = 0.0, .y = 0.0 },
        .scale = 1.0,
    },
    allocator: std.mem.Allocator,
    objects: std.ArrayList(Obj),

    pub fn init(allocator: std.mem.Allocator) Stellar {
        const objects = std.ArrayList(Obj).init(allocator);
        return Stellar{ .allocator = allocator, .objects = objects };
    }

    pub fn deinit(self: Stellar) void {
        self.objects.deinit();
    }

    pub fn addObj(self: *Stellar, obj: Obj) !void {
        try self.objects.append(obj);
    }

    pub fn updateObjects(self: Stellar) void {
        for (self.objects.items) |*obj| {
            obj.update();
        }
    }

    pub fn drawObjects(self: Stellar) void {
        for (self.objects.items) |obj| {
            obj.draw(self.viewport);
        }
    }

    pub fn calcForces(self: Stellar) !void {
        var obj_forces = std.ArrayList(rl.Vector2).init(self.allocator);
        defer obj_forces.deinit();

        for (self.objects.items, 0..) |obj_1, i| {
            var all_forces: rl.Vector2 = .{ .x = obj_1.dir.x, .y = obj_1.dir.y };

            for (self.objects.items, 0..) |obj_2, j| {
                if (i != j) {
                    const move = obj_1.vectorTo(obj_2);
                    all_forces.x += move.x;
                    all_forces.y += move.y;
                }
            }
            try obj_forces.append(all_forces);
        }
        for (self.objects.items, obj_forces.items) |*obj, force| {
            obj.dir = force;
        }
    }

    pub fn checkColl(self: Stellar) !void {
        const max = self.objects.items.len;
        var pairs = std.ArrayList([2]usize).init(self.allocator);
        defer pairs.deinit();

        var i: usize = 0;
        while (i < max) : (i += 1) {
            var j: usize = i + 1;
            while (j < max) : (j += 1) {
                const obj_1 = self.objects.items[i];
                const obj_2 = self.objects.items[j];

                if (obj_1.checkCollission(obj_2)) {
                    try pairs.append([2]usize{ i, j });
                }
            }
        }

        if (pairs.items.len > 0) {
            std.debug.print("Total Collisions: {d}\n", .{pairs.items.len});
            for (pairs.items) |pair| {
                std.debug.print("Collision pair: {d}-{d}\n", .{ pair[0], pair[1] });
            }
        }
    }

    fn handlePanning(self: *Stellar) void {
        const move_speed: f32 = 10.0;

        if (rl.isMouseButtonDown(rl.MouseButton.mouse_button_left)) {
            const mouse_delta = rl.getMouseDelta();
            self.viewport.offset.x -= mouse_delta.x / self.viewport.scale;
            self.viewport.offset.y -= mouse_delta.y / self.viewport.scale;
        } else {
            if (rl.isKeyDown(rl.KeyboardKey.key_right)) {
                self.viewport.offset.x += move_speed / self.viewport.scale;
            }
            if (rl.isKeyDown(rl.KeyboardKey.key_left)) {
                self.viewport.offset.x -= move_speed / self.viewport.scale;
            }
            if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
                self.viewport.offset.y += move_speed / self.viewport.scale;
            }
            if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
                self.viewport.offset.y -= move_speed / self.viewport.scale;
            }
        }
    }

    fn handleZoom(self: *Stellar) void {
        const zoom_speed: f32 = 0.1;

        const mouse_position = rl.getMousePosition();
        const pre_zoom_world_mouse_x = (mouse_position.x / self.viewport.scale) + self.viewport.offset.x;
        const pre_zoom_world_mouse_y = (mouse_position.y / self.viewport.scale) + self.viewport.offset.y;

        const wheel_move = rl.getMouseWheelMove();
        if (wheel_move > 0) {
            self.viewport.scale *= 1.0 + zoom_speed;
        } else if (wheel_move < 0) {
            self.viewport.scale /= 1.0 + zoom_speed;
        }

        const post_zoom_world_mouse_x = (mouse_position.x / self.viewport.scale) + self.viewport.offset.x;
        const post_zoom_world_mouse_y = (mouse_position.y / self.viewport.scale) + self.viewport.offset.y;

        self.viewport.offset.x += pre_zoom_world_mouse_x - post_zoom_world_mouse_x;
        self.viewport.offset.y += pre_zoom_world_mouse_y - post_zoom_world_mouse_y;

        // Keep scale in reasonable bounds
        if (self.viewport.scale < 0.1) {
            self.viewport.scale = 0.1;
        }
        if (self.viewport.scale > 10.0) {
            self.viewport.scale = 10.0;
        }
    }

    pub fn updateViewport(self: *Stellar) void {
        self.handlePanning();
        self.handleZoom();
    }
};

test "Test something" {
    try std.testing.expectEqual(2, 1 + 1);
}
