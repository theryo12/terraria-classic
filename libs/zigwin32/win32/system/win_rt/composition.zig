//! NOTE: this file is autogenerated, DO NOT MODIFY
//--------------------------------------------------------------------------------
// Section: Constants (0)
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Section: Types (9)
//--------------------------------------------------------------------------------
const IID_ICompositionDrawingSurfaceInterop_Value = Guid.initString("fd04e6e3-fe0c-4c3c-ab19-a07601a576ee");
pub const IID_ICompositionDrawingSurfaceInterop = &IID_ICompositionDrawingSurfaceInterop_Value;
pub const ICompositionDrawingSurfaceInterop = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        BeginDraw: *const fn(
            self: *const ICompositionDrawingSurfaceInterop,
            updateRect: ?*const RECT,
            iid: ?*const Guid,
            updateObject: **anyopaque,
            updateOffset: ?*POINT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        EndDraw: *const fn(
            self: *const ICompositionDrawingSurfaceInterop,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        Resize: *const fn(
            self: *const ICompositionDrawingSurfaceInterop,
            sizePixels: SIZE,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        Scroll: *const fn(
            self: *const ICompositionDrawingSurfaceInterop,
            scrollRect: ?*const RECT,
            clipRect: ?*const RECT,
            offsetX: i32,
            offsetY: i32,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        ResumeDraw: *const fn(
            self: *const ICompositionDrawingSurfaceInterop,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SuspendDraw: *const fn(
            self: *const ICompositionDrawingSurfaceInterop,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn BeginDraw(self: *const ICompositionDrawingSurfaceInterop, updateRect: ?*const RECT, iid: ?*const Guid, updateObject: **anyopaque, updateOffset: ?*POINT) callconv(.Inline) HRESULT {
        return self.vtable.BeginDraw(self, updateRect, iid, updateObject, updateOffset);
    }
    pub fn EndDraw(self: *const ICompositionDrawingSurfaceInterop) callconv(.Inline) HRESULT {
        return self.vtable.EndDraw(self);
    }
    pub fn Resize(self: *const ICompositionDrawingSurfaceInterop, sizePixels: SIZE) callconv(.Inline) HRESULT {
        return self.vtable.Resize(self, sizePixels);
    }
    pub fn Scroll(self: *const ICompositionDrawingSurfaceInterop, scrollRect: ?*const RECT, clipRect: ?*const RECT, offsetX: i32, offsetY: i32) callconv(.Inline) HRESULT {
        return self.vtable.Scroll(self, scrollRect, clipRect, offsetX, offsetY);
    }
    pub fn ResumeDraw(self: *const ICompositionDrawingSurfaceInterop) callconv(.Inline) HRESULT {
        return self.vtable.ResumeDraw(self);
    }
    pub fn SuspendDraw(self: *const ICompositionDrawingSurfaceInterop) callconv(.Inline) HRESULT {
        return self.vtable.SuspendDraw(self);
    }
};

const IID_ICompositionDrawingSurfaceInterop2_Value = Guid.initString("41e64aae-98c0-4239-8e95-a330dd6aa18b");
pub const IID_ICompositionDrawingSurfaceInterop2 = &IID_ICompositionDrawingSurfaceInterop2_Value;
pub const ICompositionDrawingSurfaceInterop2 = extern union {
    pub const VTable = extern struct {
        base: ICompositionDrawingSurfaceInterop.VTable,
        CopySurface: *const fn(
            self: *const ICompositionDrawingSurfaceInterop2,
            destinationResource: ?*IUnknown,
            destinationOffsetX: i32,
            destinationOffsetY: i32,
            sourceRectangle: ?*const RECT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    ICompositionDrawingSurfaceInterop: ICompositionDrawingSurfaceInterop,
    IUnknown: IUnknown,
    pub fn CopySurface(self: *const ICompositionDrawingSurfaceInterop2, destinationResource: ?*IUnknown, destinationOffsetX: i32, destinationOffsetY: i32, sourceRectangle: ?*const RECT) callconv(.Inline) HRESULT {
        return self.vtable.CopySurface(self, destinationResource, destinationOffsetX, destinationOffsetY, sourceRectangle);
    }
};

const IID_ICompositionGraphicsDeviceInterop_Value = Guid.initString("a116ff71-f8bf-4c8a-9c98-70779a32a9c8");
pub const IID_ICompositionGraphicsDeviceInterop = &IID_ICompositionGraphicsDeviceInterop_Value;
pub const ICompositionGraphicsDeviceInterop = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        GetRenderingDevice: *const fn(
            self: *const ICompositionGraphicsDeviceInterop,
            value: **IUnknown,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetRenderingDevice: *const fn(
            self: *const ICompositionGraphicsDeviceInterop,
            value: ?*IUnknown,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn GetRenderingDevice(self: *const ICompositionGraphicsDeviceInterop, value: **IUnknown) callconv(.Inline) HRESULT {
        return self.vtable.GetRenderingDevice(self, value);
    }
    pub fn SetRenderingDevice(self: *const ICompositionGraphicsDeviceInterop, value: ?*IUnknown) callconv(.Inline) HRESULT {
        return self.vtable.SetRenderingDevice(self, value);
    }
};

const IID_ICompositorInterop_Value = Guid.initString("25297d5c-3ad4-4c9c-b5cf-e36a38512330");
pub const IID_ICompositorInterop = &IID_ICompositorInterop_Value;
pub const ICompositorInterop = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        CreateCompositionSurfaceForHandle: *const fn(
            self: *const ICompositorInterop,
            swapChain: ?HANDLE,
            result: **struct{comment: []const u8 = "MissingClrType ICompositionSurface.Windows.UI.Composition"},
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        CreateCompositionSurfaceForSwapChain: *const fn(
            self: *const ICompositorInterop,
            swapChain: ?*IUnknown,
            result: **struct{comment: []const u8 = "MissingClrType ICompositionSurface.Windows.UI.Composition"},
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        CreateGraphicsDevice: *const fn(
            self: *const ICompositorInterop,
            renderingDevice: ?*IUnknown,
            result: **struct{comment: []const u8 = "MissingClrType CompositionGraphicsDevice.Windows.UI.Composition"},
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn CreateCompositionSurfaceForHandle(self: *const ICompositorInterop, swapChain: ?HANDLE, result: **struct{comment: []const u8 = "MissingClrType ICompositionSurface.Windows.UI.Composition"}) callconv(.Inline) HRESULT {
        return self.vtable.CreateCompositionSurfaceForHandle(self, swapChain, result);
    }
    pub fn CreateCompositionSurfaceForSwapChain(self: *const ICompositorInterop, swapChain: ?*IUnknown, result: **struct{comment: []const u8 = "MissingClrType ICompositionSurface.Windows.UI.Composition"}) callconv(.Inline) HRESULT {
        return self.vtable.CreateCompositionSurfaceForSwapChain(self, swapChain, result);
    }
    pub fn CreateGraphicsDevice(self: *const ICompositorInterop, renderingDevice: ?*IUnknown, result: **struct{comment: []const u8 = "MissingClrType CompositionGraphicsDevice.Windows.UI.Composition"}) callconv(.Inline) HRESULT {
        return self.vtable.CreateGraphicsDevice(self, renderingDevice, result);
    }
};

const IID_ISwapChainInterop_Value = Guid.initString("26f496a0-7f38-45fb-88f7-faaabe67dd59");
pub const IID_ISwapChainInterop = &IID_ISwapChainInterop_Value;
pub const ISwapChainInterop = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetSwapChain: *const fn(
            self: *const ISwapChainInterop,
            swapChain: ?*IUnknown,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn SetSwapChain(self: *const ISwapChainInterop, swapChain: ?*IUnknown) callconv(.Inline) HRESULT {
        return self.vtable.SetSwapChain(self, swapChain);
    }
};

const IID_IVisualInteractionSourceInterop_Value = Guid.initString("11f62cd1-2f9d-42d3-b05f-d6790d9e9f8e");
pub const IID_IVisualInteractionSourceInterop = &IID_IVisualInteractionSourceInterop_Value;
pub const IVisualInteractionSourceInterop = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        TryRedirectForManipulation: *const fn(
            self: *const IVisualInteractionSourceInterop,
            pointerInfo: ?*const POINTER_INFO,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn TryRedirectForManipulation(self: *const IVisualInteractionSourceInterop, pointerInfo: ?*const POINTER_INFO) callconv(.Inline) HRESULT {
        return self.vtable.TryRedirectForManipulation(self, pointerInfo);
    }
};

const IID_ICompositionCapabilitiesInteropFactory_Value = Guid.initString("2c9db356-e70d-4642-8298-bc4aa5b4865c");
pub const IID_ICompositionCapabilitiesInteropFactory = &IID_ICompositionCapabilitiesInteropFactory_Value;
pub const ICompositionCapabilitiesInteropFactory = extern union {
    pub const VTable = extern struct {
        base: IInspectable.VTable,
        GetForWindow: *const fn(
            self: *const ICompositionCapabilitiesInteropFactory,
            hwnd: ?HWND,
            result: **struct{comment: []const u8 = "MissingClrType CompositionCapabilities.Windows.UI.Composition"},
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IInspectable: IInspectable,
    IUnknown: IUnknown,
    pub fn GetForWindow(self: *const ICompositionCapabilitiesInteropFactory, hwnd: ?HWND, result: **struct{comment: []const u8 = "MissingClrType CompositionCapabilities.Windows.UI.Composition"}) callconv(.Inline) HRESULT {
        return self.vtable.GetForWindow(self, hwnd, result);
    }
};

const IID_ICompositorDesktopInterop_Value = Guid.initString("29e691fa-4567-4dca-b319-d0f207eb6807");
pub const IID_ICompositorDesktopInterop = &IID_ICompositorDesktopInterop_Value;
pub const ICompositorDesktopInterop = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        CreateDesktopWindowTarget: *const fn(
            self: *const ICompositorDesktopInterop,
            hwndTarget: ?HWND,
            isTopmost: BOOL,
            result: **struct{comment: []const u8 = "MissingClrType DesktopWindowTarget.Windows.UI.Composition.Desktop"},
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        EnsureOnThread: *const fn(
            self: *const ICompositorDesktopInterop,
            threadId: u32,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn CreateDesktopWindowTarget(self: *const ICompositorDesktopInterop, hwndTarget: ?HWND, isTopmost: BOOL, result: **struct{comment: []const u8 = "MissingClrType DesktopWindowTarget.Windows.UI.Composition.Desktop"}) callconv(.Inline) HRESULT {
        return self.vtable.CreateDesktopWindowTarget(self, hwndTarget, isTopmost, result);
    }
    pub fn EnsureOnThread(self: *const ICompositorDesktopInterop, threadId: u32) callconv(.Inline) HRESULT {
        return self.vtable.EnsureOnThread(self, threadId);
    }
};

const IID_IDesktopWindowTargetInterop_Value = Guid.initString("35dbf59e-e3f9-45b0-81e7-fe75f4145dc9");
pub const IID_IDesktopWindowTargetInterop = &IID_IDesktopWindowTargetInterop_Value;
pub const IDesktopWindowTargetInterop = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        // TODO: this function has a "SpecialName", should Zig do anything with this?
        get_Hwnd: *const fn(
            self: *const IDesktopWindowTargetInterop,
            value: ?*?HWND,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn get_Hwnd(self: *const IDesktopWindowTargetInterop, value: ?*?HWND) callconv(.Inline) HRESULT {
        return self.vtable.get_Hwnd(self, value);
    }
};


//--------------------------------------------------------------------------------
// Section: Functions (0)
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Section: Unicode Aliases (0)
//--------------------------------------------------------------------------------
const thismodule = @This();
pub usingnamespace switch (@import("../../zig.zig").unicode_mode) {
    .ansi => struct {
    },
    .wide => struct {
    },
    .unspecified => if (@import("builtin").is_test) struct {
    } else struct {
    },
};
//--------------------------------------------------------------------------------
// Section: Imports (11)
//--------------------------------------------------------------------------------
const Guid = @import("../../zig.zig").Guid;
const BOOL = @import("../../foundation.zig").BOOL;
const HANDLE = @import("../../foundation.zig").HANDLE;
const HRESULT = @import("../../foundation.zig").HRESULT;
const HWND = @import("../../foundation.zig").HWND;
const IInspectable = @import("../../system/win_rt.zig").IInspectable;
const IUnknown = @import("../../system/com.zig").IUnknown;
const POINT = @import("../../foundation.zig").POINT;
const POINTER_INFO = @import("../../ui/input/pointer.zig").POINTER_INFO;
const RECT = @import("../../foundation.zig").RECT;
const SIZE = @import("../../foundation.zig").SIZE;

test {
    @setEvalBranchQuota(
        comptime @import("std").meta.declarations(@This()).len * 3
    );

    // reference all the pub declarations
    if (!@import("builtin").is_test) return;
    inline for (comptime @import("std").meta.declarations(@This())) |decl| {
        _ = @field(@This(), decl.name);
    }
}