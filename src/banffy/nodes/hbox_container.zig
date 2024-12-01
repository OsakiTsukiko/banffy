const std = @import("std");

const Node = @import("../utils/node.zig").Node;
const Draw = @import("../utils/draw.zig").Draw;
const Color = @import("../utils/color.zig").Color;

pub const HBoxContainer = struct {
    x: i32,
    y: i32,
    behavW: Draw.Behav,
    behavH: Draw.Behav,
    width: u32,
    height: u32,
    content_width: u32 = 0,
    content_height: u32 = 0,
    gap: u32 = 0,
    gap_error: bool = false,

    background: ?Color = null,
    parent: Node,
    children: std.ArrayList(Node),

    // state
    fill_children_count: u32 = 0,

    pub fn init(
        allocator: std.mem.Allocator,
        x: i32,
        y: i32,
        behavW: Draw.Behav,
        behavH: Draw.Behav,
        width: u32,
        height: u32,
        parent: Node,
    ) HBoxContainer {
        return HBoxContainer {
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

    pub fn deinit(self: *HBoxContainer) void {
        self.children.deinit();
    }

    pub fn preLogicW(ptr: *anyopaque) void {
        const self = @as(*HBoxContainer, @ptrCast(@alignCast(ptr)));
        for (self.children.items) |child| child.preLogicW();

        // calculate width
        self.fill_children_count = 0;
        self.content_width = 0;
        if (self.children.items.len >= 2) self.content_width += (@as(u32, @intCast(self.children.items.len)) - 1) * self.gap;
        for (self.children.items) |child| {
            if (child.behavW.* == .FILL) self.fill_children_count += 1;
            self.content_width += child.width.*;
        }
        if (self.behavW == .FILL) self.width = 0;
        if (self.behavW == .FIT_CONTENT) self.width = self.content_width;
    }

    pub fn preLogicH(ptr: *anyopaque) void {
        const self = @as(*HBoxContainer, @ptrCast(@alignCast(ptr)));
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
        const self = @as(*HBoxContainer, @ptrCast(@alignCast(ptr)));

        const leftover_width = self.width - self.content_width;
        var distributed_fill: u32 = 0;
        if (self.fill_children_count == 0) { distributed_fill = leftover_width; }
        else { distributed_fill = @divTrunc(leftover_width, self.fill_children_count); }
        

        var x_index = self.x;
        for (self.children.items, 0..) |child, i| {
            child.x.* = x_index;
            child.y.* = self.y;
            if (child.behavW.* == .FILL) child.width.* = distributed_fill;
            if (child.behavH.* == .FILL) child.height.* = self.height;
            if (self.gap_error and i == 0 and leftover_width - distributed_fill * self.fill_children_count > 0 ) {
                x_index += @as(i32, @intCast(leftover_width - distributed_fill * self.fill_children_count));   
            }
            x_index += @as(i32, @intCast(child.width.*));
            x_index += @as(i32, @intCast(self.gap));
            child.logic();
        }
    }

    pub fn draw(ptr: *anyopaque) void {
        const self = @as(*HBoxContainer, @ptrCast(@alignCast(ptr)));
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

    pub fn addChild(self: *HBoxContainer, child: Node) void {
        self.children.append(child) catch unreachable;
    }
    
    pub fn node(self: *HBoxContainer) Node {
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