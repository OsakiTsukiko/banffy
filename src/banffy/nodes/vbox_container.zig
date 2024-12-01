const std = @import("std");

const Node = @import("../utils/node.zig").Node;
const Draw = @import("../utils/draw.zig").Draw;
const Color = @import("../utils/color.zig").Color;

pub const VBoxContainer = struct {
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
    ) VBoxContainer {
        return VBoxContainer {
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

    pub fn deinit(self: *VBoxContainer) void {
        self.children.deinit();
    }

    pub fn preLogicW(ptr: *anyopaque) void {
        const self = @as(*VBoxContainer, @ptrCast(@alignCast(ptr)));
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
        const self = @as(*VBoxContainer, @ptrCast(@alignCast(ptr)));
        for (self.children.items) |child| child.preLogicH();

        // calculate height
        self.fill_children_count = 0;
        self.content_height = 0;
        if (self.children.items.len >= 2) self.content_height += (@as(u32, @intCast(self.children.items.len)) - 1) * self.gap;
        for (self.children.items) |child| {
            if (child.behavH.* == .FILL) self.fill_children_count += 1;
            self.content_height += child.height.*;
        }
        if (self.behavH == .FILL) self.height = 0;
        if (self.behavH == .FIT_CONTENT) self.height = self.height;
    }
    
    pub fn logic(ptr: *anyopaque) void {
        const self = @as(*VBoxContainer, @ptrCast(@alignCast(ptr)));

        const leftover_height = self.height - self.content_height;
        var distributed_fill: u32 = 0;
        if (self.fill_children_count == 0) { distributed_fill = leftover_height; }
        else { distributed_fill = @divTrunc(leftover_height, self.fill_children_count); }
        

        var y_index = self.y;
        for (self.children.items, 0..) |child, i| {
            child.x.* = self.x;
            child.y.* = y_index;
            if (child.behavW.* == .FILL) child.width.* = self.width;
            if (child.behavH.* == .FILL) child.height.* = distributed_fill;
            if (self.gap_error and i == 0 and leftover_height - distributed_fill * self.fill_children_count > 0 ) {
                y_index += @as(i32, @intCast(leftover_height - distributed_fill * self.fill_children_count));   
            }
            y_index += @as(i32, @intCast(child.height.*));
            y_index += @as(i32, @intCast(self.gap));
            child.logic();
        }
    }

    pub fn draw(ptr: *anyopaque) void {
        const self = @as(*VBoxContainer, @ptrCast(@alignCast(ptr)));
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

    pub fn addChild(self: *VBoxContainer, child: Node) void {
        self.children.append(child) catch unreachable;
    }
    
    pub fn node(self: *VBoxContainer) Node {
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