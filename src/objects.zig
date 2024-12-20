const std = @import("std");
const math = std.math;
const rl = @import("raylib");

pub const Object = struct {
    x: f32 = 400,
    y: f32 = 100,
    radius: f32 = 30.0,
    color: rl.Color = rl.Color.gold,
    dir: rl.Vector2 = .{ .x = 1.0, .y = 1.0 },
    density: f32 = 1.0,

    pub fn init(x: f32, y: f32, r: f32, dx: f32, dy: f32, density: f32) Object {
        return .{ .x = x, .y = y, .radius = r, .dir = .{ .x = dx, .y = dy }, .density = density };
    }

    pub fn update(self: *Object) void {
        self.x = self.x + self.dir.x;
        self.y = self.y + self.dir.y;
    }

    pub fn draw(self: Object) void {
        const x = @as(i32, @intFromFloat(self.x));
        const y = @as(i32, @intFromFloat(self.y));

        rl.drawCircle(x, y, self.radius, self.color);
    }

    pub fn distanceTo(self: Object, other: Object) f32 {
        const dx = other.x - self.x;
        const dy = other.y - self.y;
        return math.sqrt(dx * dx + dy * dy);
    }

    pub fn vectorTo(self: Object, other: Object) rl.Vector2 {
        const grav_pull = self.gravPull(other);
        const dx = (other.x - self.x) * grav_pull;
        const dy = (other.y - self.y) * grav_pull;

        return .{ .x = dx, .y = dy };
    }

    fn gravPull(self: Object, other: Object) f32 {
        // const G = = 6.674e-11;
        const G = 6.674e-6;
        // mass is redius^2 * density
        const mass_A = self.density * self.radius * self.radius;
        const mass_B = other.density * other.radius * other.radius;
        const dx = other.x - self.x;
        const dy = other.y - self.y;
        const distance = math.sqrt(dx * dx + dy * dy);
        const pull = G * (mass_A * mass_B) / (distance * distance);

        // std.debug.print("GravPull: {d}\n", .{pull / mass_A});
        return pull / mass_A;
    }

    fn normalize(input: f32) f32 {
        const multiplier = 10.0;
        const result: f32 = @floor(input * multiplier);
        return result;
    }

    pub fn checkCollission(self: Object, other: Object) bool {
        return normalize(self.x) == normalize(other.x) and normalize(self.y) == normalize(other.y);
    }
};

pub fn createPlanet(x: f32, y: f32) Object {
    var obj = Object.init(x, y, 8, -1, -0.1, 10);
    obj.color = rl.Color.green;

    return obj;
}

// test "Test something" {
//     const obj_1 = Object.init(1, 2, 1, 0, 0);
//     const obj_2 = Object.init(1, 2, 1, 0, 0);
//
//     const distance = obj_1.distanceTo(obj_2);
//     try std.testing.expectEqual(0, distance);
//     try std.testing.expectEqual(0, 1 - 1);
// }
