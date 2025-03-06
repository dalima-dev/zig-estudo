const std = @import("std");

const c = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_main.h");
});

const WINDOW_WIDTH = 640;
const WINDOW_HEIGHT = 480;
var current_sine_sample: c_int = 0;

var stream: ?*c.SDL_AudioStream = undefined;

pub fn createWindownAndRenderer() struct { *c.SDL_Window, *c.SDL_Renderer } {
    c.SDL_SetMainReady();

    _ = c.SDL_SetAppMetadata("Example Audio Simple Playback", "0.0.0", "sdl-examples.simple-playback");
    _ = c.SDL_Init(c.SDL_INIT_VIDEO | c.SDL_INIT_AUDIO);

    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = create_window_and_renderer: {
        var window: ?*c.SDL_Window = null;
        var renderer: ?*c.SDL_Renderer = null;
        _ = c.SDL_CreateWindowAndRenderer("Window", WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer);
        errdefer comptime unreachable;

        break :create_window_and_renderer .{ window.?, renderer.? };
    };

    return .{ window, renderer };
}

pub fn initialize() void {
    var spec: c.SDL_AudioSpec = undefined;

    spec.channels = 1;
    spec.format = c.SDL_AUDIO_F32;
    spec.freq = 8000;
    stream = c.SDL_OpenAudioDeviceStream(c.SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &spec, null, null);

    if (stream == null) {
        c.SDL_Log("Couldn't create audio stream: %s", c.SDL_GetError());
    }

    _ = c.SDL_ResumeAudioStreamDevice(stream);
}

pub fn updateFrame() void {
    const minimum_audio = (8000 * @sizeOf(f32)) / 2;
    const freq = 440;

    if (c.SDL_GetAudioStreamQueued(stream) < minimum_audio) {
        var samples: [500]f32 = undefined;

        for (samples, 0..) |_, i| {
            const phase: f32 = @as(f32, @floatFromInt(current_sine_sample * freq)) / 8000;

            samples[i] = c.SDL_sinf(phase * 2 * c.SDL_PI_F);
            current_sine_sample += 1;
        }

        current_sine_sample = @rem(current_sine_sample, 8000);
        _ = c.SDL_PutAudioStreamData(stream, &samples[0], @sizeOf(@TypeOf(samples)));
    }
}

pub fn render(renderer: ?*c.SDL_Renderer) void {
    _ = c.SDL_RenderClear(renderer);
    _ = c.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    const window: *c.SDL_Window, const renderer: *c.SDL_Renderer = createWindownAndRenderer();
    defer c.SDL_Quit();
    defer c.SDL_DestroyRenderer(renderer);
    defer c.SDL_DestroyWindow(window);

    initialize();

    main_loop: while (true) {
        var event: c.SDL_Event = undefined;

        while (c.SDL_PollEvent(&event)) {
            if (event.type == c.SDL_EVENT_QUIT) break :main_loop;
        }

        updateFrame();
        render(renderer);
    }
}
