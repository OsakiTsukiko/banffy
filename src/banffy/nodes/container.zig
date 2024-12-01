const std = @import("std");

const Node = @import("../utils/node.zig").Node;
const Draw = @import("../utils/draw.zig").Draw;
const Color = @import("../utils/color.zig").Color;

pub const Container = struct {
    x: i32,
    y: i32,
    behavX: Draw.Behav,
    behavY: Draw.Behav,
    width: u32,
    height: u32,

    background: ?Color = null,
    parent: Node,
    children: std.ArrayList(Node),

    pub fn init(
        allocator: std.mem.Allocator,
        x: i32,
        y: i32,
        behavX: Draw.Behav,
        behavY: Draw.Behav,
        width: u32,
        height: u32,
        parent: Node,
    ) Container {
        return Container {
            .x = x,
            .y = y,
            .behavX = behavX,
            .behavY = behavY,
            .width = width,
            .height = height,
            .parent = parent,
            .children = std.ArrayList(Node).init(allocator),
        };
    }

    pub fn deinit(self: *Container) void {
        self.children.deinit();
    }
    
    pub fn logic(ptr: *anyopaque) void {
        const self = @as(*Container, @ptrCast(@alignCast(ptr)));

        for (self.children.items) |child| {
            child.logic();
        }
    }

    pub fn draw(ptr: *anyopaque) void {
        const self = @as(*Container, @ptrCast(@alignCast(ptr)));
        if (self.background) |background| Draw.drawRect(
            self.x,
            self.y,
            self.width, 
            self.height, 
            background
        );

        for (self.children.items) |child| {
            child.draw();
        }
    }

    pub fn addChild(self: *Container, child: Node) void {
        self.children.append(child) catch unreachable;
    }
    
    pub fn node(self: *Container) Node {
        return Node {
            .ptr = self,
            .parent = &self.parent,

            .x = &self.x,
            .y = &self.y,
            .behavX = &self.behavX,
            .behavY = &self.behavY,
            .width = &self.width,
            .height = &self.height,

            ._logic = logic,
            ._draw = draw,
        };
    }
};