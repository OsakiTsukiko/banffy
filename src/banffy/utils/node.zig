pub const std = @import("std");

pub const Draw = @import("./draw.zig").Draw;

pub const Node = struct {
    ptr: *anyopaque,

    x: *i32, // this is set by the parent
    y: *i32, // this is set by the parent
    behavW: *Draw.Behav,
    behavH: *Draw.Behav,
    width: *u32,
    height: *u32,

    parent: ?*Node = null,
    children: ?*std.ArrayList(Node) = null,

    _preLogicW: *const fn (ptr: *anyopaque) void,
    _preLogicH: *const fn (ptr: *anyopaque) void,
    _logic: *const fn (ptr: *anyopaque) void,
    _draw: *const fn (ptr: *anyopaque) void,

    pub fn preLogicW(self: Node) void { self._preLogicW(self.ptr); }
    pub fn preLogicH(self: Node) void { self._preLogicH(self.ptr); }
    pub fn logic(self: Node) void { self._logic(self.ptr); }
    pub fn draw(self: Node) void { self._draw(self.ptr); }

    pub fn debugDraw(self: Node) void {
        Draw.Debug.drawRect(self.x.*, self.y.*, self.width.*, self.height.*, .{.r = 0, .g = 0, .b = 0, .a = 255});
        if (self.children) |children| {
            for (children.items) |child| {
                child.debugDraw();
            }
        }
    }
};