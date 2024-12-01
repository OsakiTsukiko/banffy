const std = @import("std");
const rl = @import("raylib");

const Node = @import("./banffy/utils/node.zig");
const RootContainer = @import("./banffy/nodes/root_container.zig").RootContainer;
const Container = @import("./banffy/nodes/container.zig").Container;

pub fn main() anyerror!void {
    // Allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const screenWidth = 700;
    const screenHeight = 700;

    var root_container = RootContainer.init(100, 100, 500, 500);
    defer root_container.deinit();
    root_container.background = .{.r = 255, .g = 128, .b = 64, .a = 255};

    var container = Container.init(allocator, 0, 0, .FILL, .FILL, 100, 100, root_container.node());
    defer container.deinit();
    container.background = .{.r = 64, .g = 128, .b = 255, .a = 255};

    root_container.child = container.node();

    rl.initWindow(screenWidth, screenHeight, "Showcase Banffy");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        root_container.node().logic();

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        root_container.node().draw();
    }
}