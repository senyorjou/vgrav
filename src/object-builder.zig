const rl = @import("raylib");
const Object = @import("objects.zig").Object;

pub const ObjectSize = enum {
    xxs,
    xs,
    s,
    m,
    l,
    xl,
    xxl,
};

pub fn createStar(x: f32, y: f32, size: ObjectSize) Object {
    const base_radius = 50.0;
    const base_density = 1000.0;
    const speed = 0.0;

    const radius_multiplier: f32 = switch (size) {
        .xxs => 0.25,
        .xs => 0.5,
        .s => 0.75,
        .m => 1.0,
        .l => 1.5,
        .xl => 2.5,
        .xxl => 5.0,
    };

    return Object{
        .x = x,
        .y = y,
        .radius = base_radius * radius_multiplier,
        .color = rl.Color.gold,
        .dir = .{ .x = 0.0, .y = speed },
        .density = base_density,
    };
}
