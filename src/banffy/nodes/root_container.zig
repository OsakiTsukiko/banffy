const std = @import("std");

const Node = @import("../utils/node.zig").Node;
const Draw = @import("../utils/draw.zig").Draw;
const Color = @import("../utils/color.zig").Color;

pub const RootContainer = struct {
    x: i32,
    y: i32,
    width: u32,
    height: u32,
    background: ?Color = null,
    child: Node = undefined,
    behavWH: Draw.Behav = .FIXED,
    // here just so behav from node 
    // to not be ?*Draw.behav

    pub fn init(
        x: i32,
        y: i32,
        width: u32,
        height: u32
    ) RootContainer {
        return RootContainer {
            .x = x,
            .y = y,
            .width = width,
            .height = height,
        };
    }

    pub fn deinit(_: *RootContainer) void {
        // just for consistency
    }

    pub fn preLogicW(ptr: *anyopaque) void {
        const self = @as(*RootContainer, @ptrCast(@alignCast(ptr)));
        self.child.preLogicW();
    }

    pub fn preLogicH(ptr: *anyopaque) void {
        const self = @as(*RootContainer, @ptrCast(@alignCast(ptr)));
        self.child.preLogicH();
    }
    
    pub fn logic(ptr: *anyopaque) void {
        const self = @as(*RootContainer, @ptrCast(@alignCast(ptr)));
        self.child.x.* = self.x;
        self.child.y.* = self.y;
        if (self.child.behavW.* == .FILL) self.child.width.* = self.width;
        if (self.child.behavH.* == .FILL) self.child.height.* = self.height;
        self.child.logic();
    }

    pub fn draw(ptr: *anyopaque) void {
        const self = @as(*RootContainer, @ptrCast(@alignCast(ptr)));
        if (self.background) |background| Draw.drawRect(self.x, self.y, self.width, self.height, background);
        self.child.draw();
    }

    pub fn node(self: *RootContainer) Node {
        return Node {
            .ptr = self,

            .x = &self.x,
            .y = &self.y,
            .width = &self.width,
            .height = &self.height,
            .behavW = &self.behavWH,
            .behavH = &self.behavWH,

            ._preLogicW = preLogicW,
            ._preLogicH = preLogicH,
            ._logic = logic,
            ._draw = draw,
        };
    }
};