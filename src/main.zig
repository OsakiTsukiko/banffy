const std = @import("std");
const rl = @import("raylib");

const Node = @import("./banffy/utils/node.zig");
const RootContainer = @import("./banffy/nodes/root_container.zig").RootContainer;
const Container = @import("./banffy/nodes/container.zig").Container;
const MarginContainer = @import("./banffy/nodes/margin_container.zig").MarginContainer;
const HBoxContainer = @import("./banffy/nodes/hbox_container.zig").HBoxContainer;
const VBoxContainer = @import("./banffy/nodes/vbox_container.zig").VBoxContainer;

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

    // var cont2 = Container.init(allocator, 0, 0, .FIXED, .FILL, 100, 100, margin_container.node());
    // defer cont2.deinit();
    // cont2.background = .{.r = 255, .g = 64, .b = 128, .a = 255};
    // margin_container.addChild(cont2.node());

    // var cont3 = Container.init(allocator, 0, 0, .FILL, .FIXED, 50, 50, margin_container.node());
    // defer cont3.deinit();
    // cont3.background = .{.r = 128, .g = 64, .b = 255, .a = 255};
    // margin_container.addChild(cont3.node());

    // HBOX
    var hbc = HBoxContainer.init(
        allocator, 0, 0, 
        .FIXED, 
        .FIXED,
        300,
        300, 
        margin_container.node()
    );
    defer hbc.deinit();
    hbc.background = .{.r = 10, .g = 60, .b = 140, .a = 255};
    hbc.gap = 10;
    hbc.gap_error = true;
    margin_container.addChild(hbc.node());

    var hbc_c1 = VBoxContainer.init(allocator, 0, 0, .FILL, .FILL, 0, 0, hbc.node());
    defer hbc_c1.deinit();
    hbc_c1.background = .{.r = 255, .g = 0, .b = 0, .a = 255};
    hbc_c1.gap = 10;
    hbc_c1.gap_error = true;
    hbc.addChild(hbc_c1.node());

    var hbc_c1_c1 = Container.init(allocator, 0, 0, .FILL, .FILL, 10, 10, hbc_c1.node());
    defer hbc_c1_c1.deinit();
    hbc_c1_c1.background = .{ .r = 128, .g = 0, .b = 128, .a = 255 };
    hbc_c1.addChild(hbc_c1_c1.node());
    
    var hbc_c2_c2 = Container.init(allocator, 0, 0, .FILL, .FILL, 10, 10, hbc_c1.node());
    defer hbc_c2_c2.deinit();
    hbc_c2_c2.background = .{ .r = 64, .g = 0, .b = 128, .a = 255 };
    hbc_c1.addChild(hbc_c2_c2.node());

    var hbc_c2_c3 = Container.init(allocator, 0, 0, .FILL, .FILL, 10, 10, hbc_c1.node());
    defer hbc_c2_c3.deinit();
    hbc_c2_c3.background = .{ .r = 128, .g = 0, .b = 64, .a = 255 };
    hbc_c1.addChild(hbc_c2_c3.node());

    var hbc_c2 = Container.init(allocator, 0, 0, .FIXED, .FILL, 50, 0, hbc.node());
    defer hbc_c2.deinit();
    hbc_c2.background = .{.r = 0, .g = 255, .b = 0, .a = 255};
    hbc.addChild(hbc_c2.node());
    
    var hbc_c3 = Container.init(allocator, 0, 0, .FIT_CONTENT, .FILL, 0, 0, hbc.node());
    defer hbc_c3.deinit();
    hbc_c3.background = .{.r = 0, .g = 0, .b = 255, .a = 255};
    hbc.addChild(hbc_c3.node());

    root_container.child = container.node();

    rl.initWindow(screenWidth, screenHeight, "Showcase Banffy");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        hbc_c2.width = @as(u32, @intFromFloat(@abs(50 * std.math.sin(@as(f32, @floatFromInt(@mod(std.time.milliTimestamp(), 1000))) / 1000.0))));

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