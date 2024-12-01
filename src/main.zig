const std = @import("std");
const rl = @import("raylib");

const Node = @import("./banffy/utils/node.zig");
const RootContainer = @import("./banffy/nodes/root_container.zig").RootContainer;
const Container = @import("./banffy/nodes/container.zig").Container;
const MarginContainer = @import("./banffy/nodes/margin_container.zig").MarginContainer;

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

    var margin_container = MarginContainer.init(
        allocator, 
        0, 0, 
        .FILL, .FILL, 
        0, 0, 
        .{
            .left = 10, .right = 10,
            .top = 10, .bottom = 10,
        }, 
        container.node()
    );
    defer margin_container.deinit();
    container.addChild(margin_container.node());

    var cont2 = Container.init(allocator, 0, 0, .FIXED, .FILL, 100, 100, container.node());
    defer cont2.deinit();
    cont2.background = .{.r = 255, .g = 64, .b = 128, .a = 255};

    var cont3 = Container.init(allocator, 0, 0, .FILL, .FIXED, 50, 50, container.node());
    defer cont3.deinit();
    cont3.background = .{.r = 128, .g = 64, .b = 255, .a = 255};

    margin_container.addChild(cont3.node());
    margin_container.addChild(cont2.node());

    root_container.child = container.node();

    rl.initWindow(screenWidth, screenHeight, "Showcase Banffy");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        root_container.node().preLogicW();
        root_container.node().preLogicH();
        root_container.node().logic();

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        root_container.node().draw();
        if (rl.isKeyDown(rl.KeyboardKey.key_enter)) container.node().debugDraw();
    }
}