//! NOTE: this file is autogenerated, DO NOT MODIFY
//--------------------------------------------------------------------------------
// Section: Constants (0)
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
// Section: Types (1)
//--------------------------------------------------------------------------------
const IID_IChannelCredentials_Value = Guid.initString("181b448c-c17c-4b17-ac6d-06699b93198f");
pub const IID_IChannelCredentials = &IID_IChannelCredentials_Value;
pub const IChannelCredentials = extern union {
    pub const VTable = extern struct {
        base: IDispatch.VTable,
        SetWindowsCredential: *const fn(
            self: *const IChannelCredentials,
            domain: ?BSTR,
            username: ?BSTR,
            password: ?BSTR,
            impersonationLevel: i32,
            allowNtlm: BOOL,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetUserNameCredential: *const fn(
            self: *const IChannelCredentials,
            username: ?BSTR,
            password: ?BSTR,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetClientCertificateFromStore: *const fn(
            self: *const IChannelCredentials,
            storeLocation: ?BSTR,
            storeName: ?BSTR,
            findYype: ?BSTR,
            findValue: VARIANT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetClientCertificateFromStoreByName: *const fn(
            self: *const IChannelCredentials,
            subjectName: ?BSTR,
            storeLocation: ?BSTR,
            storeName: ?BSTR,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetClientCertificateFromFile: *const fn(
            self: *const IChannelCredentials,
            filename: ?BSTR,
            password: ?BSTR,
            keystorageFlags: ?BSTR,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetDefaultServiceCertificateFromStore: *const fn(
            self: *const IChannelCredentials,
            storeLocation: ?BSTR,
            storeName: ?BSTR,
            findType: ?BSTR,
            findValue: VARIANT,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetDefaultServiceCertificateFromStoreByName: *const fn(
            self: *const IChannelCredentials,
            subjectName: ?BSTR,
            storeLocation: ?BSTR,
            storeName: ?BSTR,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetDefaultServiceCertificateFromFile: *const fn(
            self: *const IChannelCredentials,
            filename: ?BSTR,
            password: ?BSTR,
            keystorageFlags: ?BSTR,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetServiceCertificateAuthentication: *const fn(
            self: *const IChannelCredentials,
            storeLocation: ?BSTR,
            revocationMode: ?BSTR,
            certificateValidationMode: ?BSTR,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
        SetIssuedToken: *const fn(
            self: *const IChannelCredentials,
            localIssuerAddres: ?BSTR,
            localIssuerBindingType: ?BSTR,
            localIssuerBinding: ?BSTR,
        ) callconv(@import("std").os.windows.WINAPI) HRESULT,
    };
    vtable: *const VTable,
    IDispatch: IDispatch,
    IUnknown: IUnknown,
    pub fn SetWindowsCredential(self: *const IChannelCredentials, domain: ?BSTR, username: ?BSTR, password: ?BSTR, impersonationLevel: i32, allowNtlm: BOOL) callconv(.Inline) HRESULT {
        return self.vtable.SetWindowsCredential(self, domain, username, password, impersonationLevel, allowNtlm);
    }
    pub fn SetUserNameCredential(self: *const IChannelCredentials, username: ?BSTR, password: ?BSTR) callconv(.Inline) HRESULT {
        return self.vtable.SetUserNameCredential(self, username, password);
    }
    pub fn SetClientCertificateFromStore(self: *const IChannelCredentials, storeLocation: ?BSTR, storeName: ?BSTR, findYype: ?BSTR, findValue: VARIANT) callconv(.Inline) HRESULT {
        return self.vtable.SetClientCertificateFromStore(self, storeLocation, storeName, findYype, findValue);
    }
    pub fn SetClientCertificateFromStoreByName(self: *const IChannelCredentials, subjectName: ?BSTR, storeLocation: ?BSTR, storeName: ?BSTR) callconv(.Inline) HRESULT {
        return self.vtable.SetClientCertificateFromStoreByName(self, subjectName, storeLocation, storeName);
    }
    pub fn SetClientCertificateFromFile(self: *const IChannelCredentials, filename: ?BSTR, password: ?BSTR, keystorageFlags: ?BSTR) callconv(.Inline) HRESULT {
        return self.vtable.SetClientCertificateFromFile(self, filename, password, keystorageFlags);
    }
    pub fn SetDefaultServiceCertificateFromStore(self: *const IChannelCredentials, storeLocation: ?BSTR, storeName: ?BSTR, findType: ?BSTR, findValue: VARIANT) callconv(.Inline) HRESULT {
        return self.vtable.SetDefaultServiceCertificateFromStore(self, storeLocation, storeName, findType, findValue);
    }
    pub fn SetDefaultServiceCertificateFromStoreByName(self: *const IChannelCredentials, subjectName: ?BSTR, storeLocation: ?BSTR, storeName: ?BSTR) callconv(.Inline) HRESULT {
        return self.vtable.SetDefaultServiceCertificateFromStoreByName(self, subjectName, storeLocation, storeName);
    }
    pub fn SetDefaultServiceCertificateFromFile(self: *const IChannelCredentials, filename: ?BSTR, password: ?BSTR, keystorageFlags: ?BSTR) callconv(.Inline) HRESULT {
        return self.vtable.SetDefaultServiceCertificateFromFile(self, filename, password, keystorageFlags);
    }
    pub fn SetServiceCertificateAuthentication(self: *const IChannelCredentials, storeLocation: ?BSTR, revocationMode: ?BSTR, certificateValidationMode: ?BSTR) callconv(.Inline) HRESULT {
        return self.vtable.SetServiceCertificateAuthentication(self, storeLocation, revocationMode, certificateValidationMode);
    }
    pub fn SetIssuedToken(self: *const IChannelCredentials, localIssuerAddres: ?BSTR, localIssuerBindingType: ?BSTR, localIssuerBinding: ?BSTR) callconv(.Inline) HRESULT {
        return self.vtable.SetIssuedToken(self, localIssuerAddres, localIssuerBindingType, localIssuerBinding);
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
// Section: Imports (7)
//--------------------------------------------------------------------------------
const Guid = @import("../../zig.zig").Guid;
const BOOL = @import("../../foundation.zig").BOOL;
const BSTR = @import("../../foundation.zig").BSTR;
const HRESULT = @import("../../foundation.zig").HRESULT;
const IDispatch = @import("../../system/com.zig").IDispatch;
const IUnknown = @import("../../system/com.zig").IUnknown;
const VARIANT = @import("../../system/com.zig").VARIANT;

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