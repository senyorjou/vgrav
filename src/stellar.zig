const std = @import("std");
const rl = @import("raylib");
const Obj = @import("objects.zig").Object;

pub const Stellar = struct {
    width: i32 = 1024,
    height: i32 = 800,
    color: rl.Color = rl.Color.white,
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
        // std.debug.print("All forces {any}\n", .{obj_forces.items});
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
};

test "Test something" {
    try std.testing.expectEqual(2, 1 + 1);
}
