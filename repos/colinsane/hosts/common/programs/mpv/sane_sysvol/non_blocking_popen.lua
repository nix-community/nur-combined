-- source: <https://gist.github.com/max1220/c19ccd4d90ed32d41b879eba727cbcbd>
-- requires: luajit
--
-- Implements a basic binding for popen that allows non-blocking reads
-- returned "file" table only supports :read(with an optional size argument, no mode etc.) and :close
ffi = require("ffi")
-- C functions that we need
ffi.cdef([[
  void* popen(const char* cmd, const char* mode);
  int pclose(void* stream);
  int fileno(void* stream);
  int fcntl(int fd, int cmd, int arg);
  int *__errno_location ();
  ssize_t read(int fd, void* buf, size_t count);
]])

-- you can compile a simple C programm to find these values(Or look in the headers)
F_SETFL = 4
O_NONBLOCK = 2048
EAGAIN = 11

-- this "array" holds the errno variable
_errno = ffi.C.__errno_location()

popen_meta = {
  __index = {
    -- close the process, prevent reading, allow garbage colletion
    close = function(self)
      if self._file ~= nil then
        local _file = self._file
        self._file = nil
        self._fd = nil
        self._read_buffer = nil
        ffi.C.pclose(_file)
      end
    end,
    -- read up to size bytes from the process. Returns data(string) and number of bytes read if successfull,
    -- nil, "EAGAIN" if there is no data aviable, and
    -- nil, "closed" if the process has ended
    read = function(self, size)
      if self._fd == nil then
        return nil, "closed"
      end

      size = math.min(self._read_buffer_size, size)
      local nbytes = ffi.C.read(self._fd, self._read_buffer, size)

      if nbytes > 0 then
        local data = ffi.string(self._read_buffer, nbytes)
        return data, nbytes
      elseif (nbytes == -1) and (_errno[0] == EAGAIN) then
        return nil, "EAGAIN"
      else
        self:close()
        return nil, "closed"
      end
    end
  }
  -- __gc = function(self) self:close() end
  -- __close = function(self) p:close() end
}

local function non_blocking_popen(cmd, read_buffer_size)
  -- the buffer for reading from the process
  local read_buffer_size = tonumber(read_buffer_size) or 2048
  local read_buffer = ffi.new('uint8_t[?]',read_buffer_size)

  -- get a FILE* for our command
  local file = assert(ffi.C.popen(cmd, "r"))

  -- turn the FILE* to a fd (int) for fcntl
  local fd = ffi.C.fileno(file)

  -- set non-blocking mode for read
  assert(ffi.C.fcntl(fd, F_SETFL, O_NONBLOCK)==0, "fcntl failed")

  local p = {
    _fd = fd,
    _file = file,
    _read_buffer = read_buffer,
    _read_buffer_size = read_buffer_size,
  }

  setmetatable(p, popen_meta)

  return p
end

return {
  non_blocking_popen = non_blocking_popen
}
