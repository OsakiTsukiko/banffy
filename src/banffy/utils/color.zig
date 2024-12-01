const rl = @import("raylib");

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
    
    pub fn fromRL(color: rl.Color) Color {
        return Color {
            .r = color.r,
            .g = color.g,
            .b = color.b,
            .a = color.a,
        };
    }

    pub fn toRL(self: Color) rl.Color {
        return rl.Color {
            .r = self.r,
            .g = self.g,
            .b = self.b,
            .a = self.a,
        };
    }
};