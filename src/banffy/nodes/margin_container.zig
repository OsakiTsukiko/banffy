const std = @import("std");

const Node = @import("../utils/node.zig").Node;
const Draw = @import("../utils/draw.zig").Draw;
const Color = @import("../utils/color.zig").Color;

pub const MarginContainer = struct {    
    x: i32,
    y: i32,
    behavW: Draw.Behav,
    behavH: Draw.Behav,
    width: u32,
    height: u32,
    margin: Margin,

    background: ?Color = null,
    parent: Node,
    children: std.ArrayList(Node),

    pub const Margin = struct {
        left: u32,
        right: u32,
        top: u32,
        bottom: u32,
    };

    pub fn init(
        allocator: std.mem.Allocator,
        x: i32,
        y: i32,
        behavW: Draw.Behav,
        behavH: Draw.Behav,
        width: u32,
        height: u32,
        margin: Margin,
        parent: Node,
    ) MarginContainer {
        return MarginContainer {
            .x = x,
            .y = y,
            .behavW = behavW,
            .behavH = behavH,
            .width = width,
            .height = height,
            .margin = margin,
            .parent = parent,
            .children = std.ArrayList(Node).init(allocator),
        };
    }

    pub fn deinit(self: *MarginContainer) void {
        self.children.deinit();
    }

    pub fn preLogicW(ptr: *anyopaque) void {
        const self = @as(*MarginContainer, @ptrCast(@alignCast(ptr)));

        // calculate width
        var width: u32 = self.margin.left + self.margin.right;
        if (self.behavW == .FIT_CONTENT) {
            for (self.children.items) |child| {
                child.preLogicW();
                if (child.behavW.* != .FILL) {
                    // maybe add one for minimum for fill?
                    width += child.width.*;
                }
            }
        }
        self.width = width;
    }

    pub fn preLogicH(ptr: *anyopaque) void {
        const self = @as(*MarginContainer, @ptrCast(@alignCast(ptr)));

        // calculate height
        var height: u32 = self.margin.top + self.margin.bottom;
        if (self.behavH == .FIT_CONTENT) {
            for (self.children.items) |child| {
                child.preLogicH();
                if (child.behavH.* != .FILL) {
                    // maybe add one for minimum for fill?
                    height += child.height.*;
                }
            }
        }
        self.height = height;
    }
    
    pub fn logic(ptr: *anyopaque) void {
        const self = @as(*MarginContainer, @ptrCast(@alignCast(ptr)));

        for (self.children.items) |child| {
            child.x.* = self.x + @as(i32, @intCast(self.margin.left));
            child.y.* = self.y + @as(i32, @intCast(self.margin.top));
            if (child.behavW.* == .FILL) child.width.* = self.width - self.margin.left - self.margin.right;
            if (child.behavH.* == .FILL) child.height.* = self.height - self.margin.top - self.margin.bottom;
            child.logic();
        }
    }

    pub fn draw(ptr: *anyopaque) void {
        const self = @as(*MarginContainer, @ptrCast(@alignCast(ptr)));
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

    pub fn addChild(self: *MarginContainer, child: Node) void {
        self.children.append(child) catch unreachable;
    }
    
    pub fn node(self: *MarginContainer) Node {
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