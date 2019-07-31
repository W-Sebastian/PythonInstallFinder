# Python Installation Finder



A bat script to look for a specific version of python and get its directory. It it intended to be used on applications or installers that rely on python to do their work.

# Usage

To get the location of python 3.6:

> find_python.bat -pv 3.6



To get the location of python 3.6, 3.5, 3.4 or 3.3:

> find_python.bat -pv 3.6 3.5 3.4 3.3



Both these runs show no output so it can be easily integrated in other scripts. The location of the python directory can be found in the environment variable `PYTHON_INSTALL_DIR`. From batch, python can be invoked using `%PYTHON_INSTALL_DIR%\python.exe`.

If the path is preferred to be taken from the output, then the `-p` extra option can be used:

> find_python.bat -pv 3.5 -p

If this command runs then the output will either be "Python installation not found" or the actual location of python executable for 3.5.

When providing multiple versions the order is important because the check is done from the first to the last, first for 64 bit then for 32 bit. So if the above example the script tries to find the installation for python 3.6 on 64 bit, then for 3.6 on 32 bit, then moves to 3.5 64 bit and so on. As soon as one is found the script ends.


# How it works

When called it first looks in the `$PATH$` variable for `python.exe`. If it is found then it asks for its versions and check if it matches any of the provided versions returning that path.

If this didn't worked it looks into registry and tried to find an entry for a python installation matching the provided versions.  If that is found it simply returns that path with no further extra checks. There is a chance that the registry are still there while the user might had deleted the local files; this is not covered in the script.


# Limitations

- The versions must be of the form `Major.Minor`. No other version format is supported;
- It always looks for both 32 and 64 bit versions. There is currently no way to disable or force to look for one although this should be fairly trivial to support;
- If python is found on the path it no longer checks if the version is 32 or 64 bit. 
