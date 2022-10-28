const std = @import("std");

/// Directories with our includes.
const root = thisDir();
pub const include_paths = [_][]const u8{
    root,
};

pub const pkg = std.build.Pkg{
    .name = "stb_image_resize",
    .source = .{ .path = thisDir() ++ "/main.zig" },
};

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}

pub const Options = struct {};

pub fn link(
    b: *std.build.Builder,
    step: *std.build.LibExeObjStep,
    opt: Options,
) !*std.build.LibExeObjStep {
    const lib = try buildStbImageResize(b, step, opt);
    step.linkLibrary(lib);
    inline for (include_paths) |path| step.addIncludePath(path);
    return lib;
}

pub fn buildStbImageResize(
    b: *std.build.Builder,
    step: *std.build.LibExeObjStep,
    opt: Options,
) !*std.build.LibExeObjStep {
    _ = opt;

    const lib = b.addStaticLibrary("stb_image_resize", null);
    lib.setTarget(step.target);
    lib.setBuildMode(step.build_mode);

    // Include
    inline for (include_paths) |path| lib.addIncludePath(path);

    // Link
    lib.linkLibC();

    // Compile
    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();
    try flags.appendSlice(&.{
        //"-fno-sanitize=undefined",
    });

    // C files
    lib.addCSourceFile(root ++ "/stb_image_resize.c", flags.items);

    return lib;
}