const std = @import("std");

const Node = @import("../utils/node.zig").Node;
const Draw = @import("../utils/draw.zig").Draw;
const Color = @import("../utils/color.zig").Color;

pub const Container = struct {
    x: i32,
    y: i32,
    behavW: Draw.Behav,
    behavH: Draw.Behav,
    width: u32,
    height: u32,
    content_width: u32 = 0,
    content_height: u32 = 0,

    background: ?Color = null,
    parent: Node,
    children: std.ArrayList(Node),

    pub fn init(
        allocator: std.mem.Allocator,
        x: i32,
        y: i32,
        behavW: Draw.Behav,
        behavH: Draw.Behav,
        width: u32,
        height: u32,
        parent: Node,
    ) Container {
        return Container {
            .x = x,
            .y = y,
            .behavW = behavW,
            .behavH = behavH,
            .width = width,
            .height = height,
            .parent = parent,
            .children = std.ArrayList(Node).init(allocator),
        };
    }

    pub fn deinit(self: *Container) void {
        self.children.deinit();
    }

    pub fn preLogicW(ptr: *anyopaque) void {
        const self = @as(*Container, @ptrCast(@alignCast(ptr)));
        for (self.children.items) |child| child.preLogicW();

        // calculate width
        self.content_width = 0;
        for (self.children.items) |child| {
            self.content_width += child.width.*;
        }
        if (self.behavW == .FILL) self.width = 0;
        if (self.behavW == .FIT_CONTENT) self.width = self.content_width;
    }

    pub fn preLogicH(ptr: *anyopaque) void {
        const self = @as(*Container, @ptrCast(@alignCast(ptr)));
        for (self.children.items) |child| child.preLogicH();

        // calculate height
        self.content_height = 0;
        for (self.children.items) |child| {
            self.content_height += child.height.*;
        }
        if (self.behavH == .FILL) self.height = 0;
        if (self.behavH == .FIT_CONTENT) self.height = self.height;
    }
    
    pub fn logic(ptr: *anyopaque) void {
        const self = @as(*Container, @ptrCast(@alignCast(ptr)));

        for (self.children.items) |child| {
            child.x.* = self.x;
            child.y.* = self.y;
            if (child.behavW.* == .FILL) child.width.* = self.width;
            if (child.behavH.* == .FILL) child.height.* = self.height;
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
            .behavW = &self.behavW,
            .behavH = &self.behavH,
            .width = &self.width,
            .height = &self.height,
            .children = &self.children,

            ._preLogicW = preLogicW,
            ._preLogicH = preLogicH,
            ._logic = logic,
            ._draw = draw,
        };
    }
};