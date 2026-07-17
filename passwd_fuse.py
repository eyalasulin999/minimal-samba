#!/usr/bin/env python3
import os
import sys
import errno
import stat
from fuse import FUSE, FuseOSError, Operations

class PasswdGroupFS(Operations):
    """
    A read-only FUSE filesystem that exclusively exposes 
    /etc/passwd and /etc/group.
    """
    def __init__(self):
        # Map the virtual paths inside our FUSE mount to the real host paths
        self.files = {
            '/passwd': '/etc/passwd',
            '/group': '/etc/group'
        }

    def getattr(self, path, fh=None):
        """
        Returns metadata (permissions, size, owner) for a given path.
        The OS calls this before reading a file to know how large it is.
        """
        if path == '/':
            # The root directory of our mount
            return {
                'st_mode': (stat.S_IFDIR | 0o755), # Directory, rwxr-xr-x
                'st_nlink': 2
            }
        elif path in self.files:
            # For our files, we mirror the actual size and timestamps of the real files,
            # but force the permissions to be read-only (0o444).
            real_path = self.files[path]
            st = os.stat(real_path)
            return {
                'st_mode': (stat.S_IFREG | 0o444), # Regular file, r--r--r--
                'st_nlink': 1,
                'st_size': st.st_size,
                'st_ctime': st.st_ctime,
                'st_mtime': st.st_mtime,
                'st_atime': st.st_atime,
                'st_uid': st.st_uid,
                'st_gid': st.st_gid,
            }
        else:
            # If the OS asks for any other file (like hidden files), return "No such file"
            raise FuseOSError(errno.ENOENT)

    def readdir(self, path, fh):
        """
        Lists the contents of a directory.
        """
        if path != '/':
            raise FuseOSError(errno.ENOENT)
        # Yield the standard directory pointers plus our two virtual files
        return ['.', '..', 'passwd', 'group']

    def open(self, path, flags):
        """
        Called when a file is opened. We ensure they aren't trying to write.
        """
        if path not in self.files:
            raise FuseOSError(errno.ENOENT)
        
        # Access mode mask for read/write flags is 3. O_RDONLY is 0.
        if (flags & 3) != os.O_RDONLY:
            raise FuseOSError(errno.EACCES) # Permission denied
            
        return 0 # Return a dummy file handle

    def read(self, path, length, offset, fh):
        """
        Reads the actual byte data from the file.
        """
        if path not in self.files:
            raise FuseOSError(errno.ENOENT)
            
        real_path = self.files[path]
        try:
            with open(real_path, 'rb') as f:
                f.seek(offset)
                return f.read(length)
        except IOError as e:
            raise FuseOSError(e.errno)

def main():
    mountpoint = '/tmp/passwd-fuse'
    
    # Ensure the mount point directory exists
    if not os.path.exists(mountpoint):
        os.makedirs(mountpoint)

    print(f"Starting FUSE mount at {mountpoint}...")
    print("Press Ctrl+C to stop.")
    
    # foreground=True keeps the script running in your terminal so you can see errors.
    # nothreads=True makes it single-threaded, which is safer/simpler for read-only FS.
    FUSE(PasswdGroupFS(), mountpoint, nothreads=True, foreground=True)

if __name__ == '__main__':
    main()