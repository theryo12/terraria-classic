//! NOTE: this file is autogenerated, DO NOT MODIFY
//--------------------------------------------------------------------------------
// Section: Constants (0)
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Section: Types (3)
//--------------------------------------------------------------------------------
const CLSID_IsolatedAppLauncher_Value = Guid.initString("bc812430-e75e-4fd1-9641-1f9f1e2d9a1f");
pub const CLSID_IsolatedAppLauncher = &CLSID_IsolatedAppLauncher_Value;

pub const IsolatedAppLauncherTelemetryParameters = extern struct {
    EnableForLaunch: BOOL,
    CorrelationGUID: Guid,
};

const IID_IIsolatedAppLauncher_Value = Guid.initString("f686878f-7b42-4cc4-96fb-f4f3b6e3d24d");
pub const IID_IIsolatedAppLauncher = &IID_IIsolatedAppLauncher_Value;
pub const IIsolatedAppLauncher = extern union {
    pub const VTable = extern struct {
        base: IUnknown.VTable,
        Launch: *const fn(
            self: *const IIsolatedAppLauncher,
            appUserModelId: ?[*:0]const u16,
            arguments: ?[*:0]const u16,
            telemetryParameters: ?*const IsolatedAppLauncherTelemetryParameters,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IUnknown: IUnknown,
    pub fn Launch(self: *const IIsolatedAppLauncher, appUserModelId: ?[*:0]const u16, arguments: ?[*:0]const u16, telemetryParameters: ?*const IsolatedAppLauncherTelemetryParameters) callconv(.Inline) HRESULT {
        return self.vtable.Launch(self, appUserModelId, arguments, telemetryParameters);
    }
};


//--------------------------------------------------------------------------------
// Section: Functions (10)
//--------------------------------------------------------------------------------
// TODO: this type is limited to platform 'windows8.0'
pub extern "kernel32" fn GetAppContainerNamedObjectPath(
    Token: ?HANDLE,
    AppContainerSid: ?PSID,
    ObjectPathLength: u32,
    ObjectPath: ?[*:0]u16,
    ReturnLength: ?*u32,
) callconv(@import("std").os.windows.WINAPI) BOOL;

pub extern "api-ms-win-security-isolatedcontainer-l1-1-1" fn IsProcessInWDAGContainer(
    Reserved: ?*anyopaque,
    isProcessInWDAGContainer: ?*BOOL,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub extern "api-ms-win-security-isolatedcontainer-l1-1-0" fn IsProcessInIsolatedContainer(
    isProcessInIsolatedContainer: ?*BOOL,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

pub extern "isolatedwindowsenvironmentutils" fn IsProcessInIsolatedWindowsEnvironment(
    isProcessInIsolatedWindowsEnvironment: ?*BOOL,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows8.0'
pub extern "userenv" fn CreateAppContainerProfile(
    pszAppContainerName: ?[*:0]const u16,
    pszDisplayName: ?[*:0]const u16,
    pszDescription: ?[*:0]const u16,
    pCapabilities: ?[*]SID_AND_ATTRIBUTES,
    dwCapabilityCount: u32,
    ppSidAppContainerSid: ?*?PSID,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows8.0'
pub extern "userenv" fn DeleteAppContainerProfile(
    pszAppContainerName: ?[*:0]const u16,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows8.0'
pub extern "userenv" fn GetAppContainerRegistryLocation(
    desiredAccess: u32,
    phAppContainerKey: ?*?HKEY,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows8.0'
pub extern "userenv" fn GetAppContainerFolderPath(
    pszAppContainerSid: ?[*:0]const u16,
    ppszPath: ?*?PWSTR,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows10.0.10240'
pub extern "userenv" fn DeriveRestrictedAppContainerSidFromAppContainerSidAndRestrictedName(
    psidAppContainerSid: ?PSID,
    pszRestrictedAppContainerName: ?[*:0]const u16,
    ppsidRestrictedAppContainerSid: ?*?PSID,
) callconv(@import("std").os.windows.WINAPI) HRESULT;

// TODO: this type is limited to platform 'windows8.0'
pub extern "userenv" fn DeriveAppContainerSidFromAppContainerName(
    pszAppContainerName: ?[*:0]const u16,
    ppsidAppContainerSid: ?*?PSID,
) callconv(@import("std").os.windows.WINAPI) HRESULT;


//--------------------------------------------------------------------------------
// Section: Unicode Aliases (0)
//--------------------------------------------------------------------------------
const thismodule = @This();
pub usingnamespace switch (@import("../zig.zig").unicode_mode) {
    .ansi => struct {
    },
    .wide => struct {
    },
    .unspecified => if (@import("builtin").is_test) struct {
    } else struct {
    },
};
//--------------------------------------------------------------------------------
// Section: Imports (9)
//--------------------------------------------------------------------------------
const Guid = @import("../zig.zig").Guid;
const BOOL = @import("../foundation.zig").BOOL;
const HANDLE = @import("../foundation.zig").HANDLE;
const HKEY = @import("../system/registry.zig").HKEY;
const HRESULT = @import("../foundation.zig").HRESULT;
const IUnknown = @import("../system/com.zig").IUnknown;
const PSID = @import("../foundation.zig").PSID;
const PWSTR = @import("../foundation.zig").PWSTR;
const SID_AND_ATTRIBUTES = @import("../security.zig").SID_AND_ATTRIBUTES;

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