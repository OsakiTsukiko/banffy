const rl = @import("raylib");

const Color = @import("./color.zig").Color;

pub const Draw = struct {
    pub fn drawRect(x: i32, y: i32, width: u32, height: u32, color: Color) void {
        rl.drawRectangle(x, y, @as(i32, @intCast(width)), @as(i32, @intCast(height)), color.toRL());
    }

    pub const Debug = struct {
        pub fn drawRect(x: i32, y: i32, width: u32, height: u32, color: Color) void {
            // rl.drawRectangleLines(x, y, @as(i32, @intCast(width)), @as(i32, @intCast(height)), color.toRL());
            rl.drawRectangleLinesEx(
                rl.Rectangle{
                    .x = @as(f32, @floatFromInt(x)),
                    .y = @as(f32, @floatFromInt(y)),
                    .width = @as(f32, @floatFromInt(width)),
                    .height = @as(f32, @floatFromInt(height)),
                }, 2.0, color.toRL()
            );
        }
    };

    pub const Behav = enum {
        FIXED,
        FIT_CONTENT,
        FILL,
    };
};