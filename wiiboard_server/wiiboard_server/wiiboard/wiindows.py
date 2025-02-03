import pywinusb.hid as hid
import logging
from pywinusb.hid import winapi
from pywinusb.hid.winapi import c_ubyte, c_ulong, CreateFile, ReadFile, WriteFile, CloseHandle, byref
from pywinusb.hid.helpers import HIDError
from ctypes import GetLastError, FormatError

LOG = logging.getLogger(__name__)
handler = logging.StreamHandler() # or RotatingFileHandler
handler.setFormatter(logging.Formatter('[%(asctime)s][%(name)s][%(levelname)s] %(message)s'))
LOG.addHandler(handler)
LOG.setLevel(logging.INFO) # or DEBUG

def discover_devices(**filters) -> list[hid.HidDevice]:
    """Discover devices. Filters can be applied using keyword=value, e.g. discover_devices(product_name='Fancy Product')"""
    return hid.HidDeviceFilter(**filters).get_devices()

ReportBuffer = c_ubyte * 22

class WinBT:
    def __init__(self):
        self.device: hid.HidDevice = None
        self._hFile = 0
        self.connected = False
        
    def connect(self, device_path):
        if self.connected:
            raise ValueError('Already connected to a HID Device')
        self.device = hid.HidDevice(device_path)
        self._hFile = CreateFile(self.device.device_path,
                                 winapi.GENERIC_READ | winapi.GENERIC_WRITE,
                                 winapi.FILE_SHARE_READ | winapi.FILE_SHARE_WRITE,
                                 None,
                                 winapi.OPEN_EXISTING,
                                 0,
                                 0)
        self.connected = True
    
    def send(self, data):
        LOG.debug(f'Writing {len(data)} bytes to "{self.device.product_name}"')
        buf = ReportBuffer()
        for i in range(min(len(buf), len(data))):
            buf[i] = data[i]
        res = WriteFile(int(self._hFile), byref(buf), len(buf), None, None)
        self._error_check(res)

    def recv(self, n_bytes):
        LOG.debug(f'Trying to read {n_bytes} bytes from "{self.device.product_name}"')
        n_bytes = min(n_bytes, 22)
        buf = ReportBuffer()
        LOG.debug(f'Actual read buffer size: {len(buf)}')
        bytes_read = c_ulong()
        res = ReadFile(int(self._hFile),
                        byref(buf), len(buf),
                        byref(bytes_read),
                        None)
        self._error_check(res)
        data = bytes(buf)[:bytes_read.value]
        LOG.debug(f"ReadFile read {len(data)} bytes")
        return data

    def close(self):
        if not self.connected:
            return
        if self._hFile:
            LOG.debug(f'Closing file handle 0x{self._hFile:08x} for device "{self.device.product_name}"')
            CloseHandle(self._hFile)
            self._hFile = 0
        self.connected = False

    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
        return not exc_type # re-raise exception if any

    def __del__(self):
        self.close()

    def _error_check(self, res):
        if not res:
            error = GetLastError()
            if error == winapi.ERROR_IO_PENDING:
                #wait for event
                error = winapi.WaitForSingleObject(
                        self._overlapped.h_event,
                        winapi.INFINITE)
                if error != winapi.WAIT_OBJECT_0: #success
                    #Cancel the ReadFile call.  The read must not be in
                    #progress when run() returns, since the buffers used
                    #in the call will go out of scope and get freed.  If
                    #new data arrives (the read finishes) after these
                    #buffers have been freed then this can cause python
                    #to crash.
                    winapi.CancelIo( self.device.hid_handle )
                    # break #device has being disconnected
                    raise
            else:
                raise HIDError("Error %d when trying to read from HID "\
                               "device: %s"%(error, FormatError(error)) )
