pub const Draw = @import("./draw.zig").Draw;

pub const Node = struct {
    ptr: *anyopaque,

    x: *i32, // this is set by the parent
    y: *i32, // this is set by the parent
    behavX: *Draw.Behav,
    behavY: *Draw.Behav,
    width: *u32,
    height: *u32,

    parent: ?*Node = null,

    _logic: *const fn (ptr: *anyopaque) void,
    _draw: *const fn (ptr: *anyopaque) void,

    pub fn logic(self: Node) void { self._logic(self.ptr); }
    pub fn draw(self: Node) void { self._draw(self.ptr); }
};