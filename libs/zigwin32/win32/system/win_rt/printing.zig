//! NOTE: this file is autogenerated, DO NOT MODIFY
//--------------------------------------------------------------------------------
// Section: Constants (0)
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Section: Types (7)
//--------------------------------------------------------------------------------
const IID_IPrinting3DManagerInterop_Value = Guid.initString("9ca31010-1484-4587-b26b-dddf9f9caecd");
pub const IID_IPrinting3DManagerInterop = &IID_IPrinting3DManagerInterop_Value;
pub const IPrinting3DManagerInterop = extern union {
    pub const VTable = extern struct {
        base: IInspectable.VTable,
        GetForWindow: *const fn(
            self: *const IPrinting3DManagerInterop,
            appWindow: ?HWND,
            riid: ?*const Guid,
            printManager: **anyopaque,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        ShowPrintUIForWindowAsync: *const fn(
            self: *const IPrinting3DManagerInterop,
            appWindow: ?HWND,
            riid: ?*const Guid,
            asyncOperation: **anyopaque,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IInspectable: IInspectable,
    IUnknown: IUnknown,
    pub fn GetForWindow(self: *const IPrinting3DManagerInterop, appWindow: ?HWND, riid: ?*const Guid, printManager: **anyopaque) callconv(.Inline) HRESULT {
        return self.vtable.GetForWindow(self, appWindow, riid, printManager);
    }
    pub fn ShowPrintUIForWindowAsync(self: *const IPrinting3DManagerInterop, appWindow: ?HWND, riid: ?*const Guid, asyncOperation: **anyopaque) callconv(.Inline) HRESULT {
        return self.vtable.ShowPrintUIForWindowAsync(self, appWindow, riid, asyncOperation);
    }
};

// TODO: this type is limited to platform 'windows8.0'
const IID_IPrintManagerInterop_Value = Guid.initString("c5435a42-8d43-4e7b-a68a-ef311e392087");
pub const IID_IPrintManagerInterop = &IID_IPrintManagerInterop_Value;
pub const IPrintManagerInterop = extern union {
    pub const VTable = extern struct {
        base: IInspectable.VTable,
        GetForWindow: *const fn(
            self: *const IPrintManagerInterop,
            appWindow: ?HWND,
            riid: ?*const Guid,
            printManager: **anyopaque,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        ShowPrintUIForWindowAsync: *const fn(
            self: *const IPrintManagerInterop,
            appWindow: ?HWND,
            riid: ?*const Guid,
            asyncOperation: **anyopaque,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IInspectable: IInspectable,
    IUnknown: IUnknown,
    pub fn GetForWindow(self: *const IPrintManagerInterop, appWindow: ?HWND, riid: ?*const Guid, printManager: **anyopaque) callconv(.Inline) HRESULT {
        return self.vtable.GetForWindow(self, appWindow, riid, printManager);
    }
    pub fn ShowPrintUIForWindowAsync(self: *const IPrintManagerInterop, appWindow: ?HWND, riid: ?*const Guid, asyncOperation: **anyopaque) callconv(.Inline) HRESULT {
        return self.vtable.ShowPrintUIForWindowAsync(self, appWindow, riid, asyncOperation);
    }
};

const IID_IPrintWorkflowXpsReceiver_Value = Guid.initString("04097374-77b8-47f6-8167-aae29d4cf84b");
pub const IID_IPrintWorkflowXpsReceiver = &IID_IPrintWorkflowXpsReceiver_Value;
pub const IPrintWorkflowXpsReceiver = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetDocumentSequencePrintTicket: *const fn(
            self: *const IPrintWorkflowXpsReceiver,
            documentSequencePrintTicket: ?*IStream,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetDocumentSequenceUri: *const fn(
            self: *const IPrintWorkflowXpsReceiver,
            documentSequenceUri: ?[*:0]const u16,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        AddDocumentData: *const fn(
            self: *const IPrintWorkflowXpsReceiver,
            documentId: u32,
            documentPrintTicket: ?*IStream,
            documentUri: ?[*:0]const u16,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        AddPage: *const fn(
            self: *const IPrintWorkflowXpsReceiver,
            documentId: u32,
            pageId: u32,
            pageReference: ?*IXpsOMPageReference,
            pageUri: ?[*:0]const u16,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        Close: *const fn(
            self: *const IPrintWorkflowXpsReceiver,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn SetDocumentSequencePrintTicket(self: *const IPrintWorkflowXpsReceiver, documentSequencePrintTicket: ?*IStream) callconv(.Inline) HRESULT {
        return self.vtable.SetDocumentSequencePrintTicket(self, documentSequencePrintTicket);
    }
    pub fn SetDocumentSequenceUri(self: *const IPrintWorkflowXpsReceiver, documentSequenceUri: ?[*:0]const u16) callconv(.Inline) HRESULT {
        return self.vtable.SetDocumentSequenceUri(self, documentSequenceUri);
    }
    pub fn AddDocumentData(self: *const IPrintWorkflowXpsReceiver, documentId: u32, documentPrintTicket: ?*IStream, documentUri: ?[*:0]const u16) callconv(.Inline) HRESULT {
        return self.vtable.AddDocumentData(self, documentId, documentPrintTicket, documentUri);
    }
    pub fn AddPage(self: *const IPrintWorkflowXpsReceiver, documentId: u32, pageId: u32, pageReference: ?*IXpsOMPageReference, pageUri: ?[*:0]const u16) callconv(.Inline) HRESULT {
        return self.vtable.AddPage(self, documentId, pageId, pageReference, pageUri);
    }
    pub fn Close(self: *const IPrintWorkflowXpsReceiver) callconv(.Inline) HRESULT {
        return self.vtable.Close(self);
    }
};

const IID_IPrintWorkflowXpsReceiver2_Value = Guid.initString("023bcc0c-dfab-4a61-b074-490c6995580d");
pub const IID_IPrintWorkflowXpsReceiver2 = &IID_IPrintWorkflowXpsReceiver2_Value;
pub const IPrintWorkflowXpsReceiver2 = extern union {
    pub const VTable = extern struct {
        base: IPrintWorkflowXpsReceiver.VTable,
        Failed: *const fn(
            self: *const IPrintWorkflowXpsReceiver2,
            XpsError: HRESULT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IPrintWorkflowXpsReceiver: IPrintWorkflowXpsReceiver,
    IUnknown: IUnknown,
    pub fn Failed(self: *const IPrintWorkflowXpsReceiver2, XpsError: HRESULT) callconv(.Inline) HRESULT {
        return self.vtable.Failed(self, XpsError);
    }
};

const IID_IPrintWorkflowObjectModelSourceFileContentNative_Value = Guid.initString("68c9e477-993e-4052-8ac6-454eff58db9d");
pub const IID_IPrintWorkflowObjectModelSourceFileContentNative = &IID_IPrintWorkflowObjectModelSourceFileContentNative_Value;
pub const IPrintWorkflowObjectModelSourceFileContentNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        StartXpsOMGeneration: *const fn(
            self: *const IPrintWorkflowObjectModelSourceFileContentNative,
            receiver: ?*IPrintWorkflowXpsReceiver,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        // TODO: this function has a "SpecialName", should Zig do anything with this?
        get_ObjectFactory: *const fn(
            self: *const IPrintWorkflowObjectModelSourceFileContentNative,
            value: ?*?*IXpsOMObjectFactory1,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn StartXpsOMGeneration(self: *const IPrintWorkflowObjectModelSourceFileContentNative, receiver: ?*IPrintWorkflowXpsReceiver) callconv(.Inline) HRESULT {
        return self.vtable.StartXpsOMGeneration(self, receiver);
    }
    pub fn get_ObjectFactory(self: *const IPrintWorkflowObjectModelSourceFileContentNative, value: ?*?*IXpsOMObjectFactory1) callconv(.Inline) HRESULT {
        return self.vtable.get_ObjectFactory(self, value);
    }
};

const IID_IPrintWorkflowXpsObjectModelTargetPackageNative_Value = Guid.initString("7d96bc74-9b54-4ca1-ad3a-979c3d44ddac");
pub const IID_IPrintWorkflowXpsObjectModelTargetPackageNative = &IID_IPrintWorkflowXpsObjectModelTargetPackageNative_Value;
pub const IPrintWorkflowXpsObjectModelTargetPackageNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        // TODO: this function has a "SpecialName", should Zig do anything with this?
        get_DocumentPackageTarget: *const fn(
            self: *const IPrintWorkflowXpsObjectModelTargetPackageNative,
            value: ?*?*IXpsDocumentPackageTarget,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn get_DocumentPackageTarget(self: *const IPrintWorkflowXpsObjectModelTargetPackageNative, value: ?*?*IXpsDocumentPackageTarget) callconv(.Inline) HRESULT {
        return self.vtable.get_DocumentPackageTarget(self, value);
    }
};

const IID_IPrintWorkflowConfigurationNative_Value = Guid.initString("c056be0a-9ee2-450a-9823-964f0006f2bb");
pub const IID_IPrintWorkflowConfigurationNative = &IID_IPrintWorkflowConfigurationNative_Value;
pub const IPrintWorkflowConfigurationNative = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        // TODO: this function has a "SpecialName", should Zig do anything with this?
        get_PrinterQueue: *const fn(
            self: *const IPrintWorkflowConfigurationNative,
            value: ?*?*IPrinterQueue,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        // TODO: this function has a "SpecialName", should Zig do anything with this?
        get_DriverProperties: *const fn(
            self: *const IPrintWorkflowConfigurationNative,
            value: ?*?*IPrinterPropertyBag,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        // TODO: this function has a "SpecialName", should Zig do anything with this?
        get_UserProperties: *const fn(
            self: *const IPrintWorkflowConfigurationNative,
            value: ?*?*IPrinterPropertyBag,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn get_PrinterQueue(self: *const IPrintWorkflowConfigurationNative, value: ?*?*IPrinterQueue) callconv(.Inline) HRESULT {
        return self.vtable.get_PrinterQueue(self, value);
    }
    pub fn get_DriverProperties(self: *const IPrintWorkflowConfigurationNative, value: ?*?*IPrinterPropertyBag) callconv(.Inline) HRESULT {
        return self.vtable.get_DriverProperties(self, value);
    }
    pub fn get_UserProperties(self: *const IPrintWorkflowConfigurationNative, value: ?*?*IPrinterPropertyBag) callconv(.Inline) HRESULT {
        return self.vtable.get_UserProperties(self, value);
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
// Section: Imports (12)
//--------------------------------------------------------------------------------
const Guid = @import("../../zig.zig").Guid;
const HRESULT = @import("../../foundation.zig").HRESULT;
const HWND = @import("../../foundation.zig").HWND;
const IInspectable = @import("../../system/win_rt.zig").IInspectable;
const IPrinterPropertyBag = @import("../../graphics/printing.zig").IPrinterPropertyBag;
const IPrinterQueue = @import("../../graphics/printing.zig").IPrinterQueue;
const IStream = @import("../../system/com.zig").IStream;
const IUnknown = @import("../../system/com.zig").IUnknown;
const IXpsDocumentPackageTarget = @import("../../storage/xps.zig").IXpsDocumentPackageTarget;
const IXpsOMObjectFactory1 = @import("../../storage/xps.zig").IXpsOMObjectFactory1;
const IXpsOMPageReference = @import("../../storage/xps.zig").IXpsOMPageReference;
const PWSTR = @import("../../foundation.zig").PWSTR;

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