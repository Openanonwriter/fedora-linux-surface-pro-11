#!/usr/bin/python3 -I
"""Unpack Microsoft's Surface Pro 11 driver package (.msi) into the layout of a Windows driver store.

Usage: msi-driverstore.py PACKAGE.msi DEST
Writes DEST/Windows/System32/DriverStore/FileRepository/<driver>.inf_msi/<files>, one directory per driver of
the package, named after the driver's .inf file as Windows names its DriverStore packages (Windows appends an
architecture and a hash, this appends "msi"). The steps that read firmware and the sensor configuration from a
mounted Windows (30, 45) then work on the package unchanged: point WINDOWS_ROOT at DEST.
Needs msiinfo (msitools) and 7z.
"""
import os, shutil, subprocess, sys, tempfile


def table(msi, name):
    out = subprocess.run(['msiinfo', 'export', msi, name], capture_output=True, check=True).stdout.decode('latin-1')
    return [l.rstrip('\r').split('\t') for l in out.split('\n')[3:] if l.strip()]


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    msi, dest = sys.argv[1], sys.argv[2]
    comp = {r[0]: r[2] for r in table(msi, 'Component')}
    files = {}                                      # MSI directory key -> [(stream id, file name, size)]
    for r in table(msi, 'File'):
        files.setdefault(comp[r[1]], []).append((r[0], r[2].split('|')[-1], int(r[3])))
    repo = os.path.join(dest, 'Windows/System32/DriverStore/FileRepository')
    if os.path.isdir(repo):
        shutil.rmtree(repo)
    with tempfile.TemporaryDirectory(dir=os.path.dirname(os.path.abspath(dest)) or '.') as work:
        subprocess.run(['7z', 'x', '-y', '-o' + work, msi], stdout=subprocess.DEVNULL, check=True)
        n = 0
        for key, entries in sorted(files.items()):
            infs = sorted(e[1] for e in entries if e[1].lower().endswith('.inf'))
            name = (infs[0].lower() if infs else key.lower()) + '_msi'
            d = os.path.join(repo, name)
            if os.path.exists(d):                   # two folders with the same .inf name: keep both apart
                d = os.path.join(repo, name + '_' + key.lower())
            os.makedirs(d)
            for sid, fname, size in entries:
                src = os.path.join(work, sid)
                if os.path.getsize(src) != size:
                    sys.exit(f'{fname}: extracted size {os.path.getsize(src)} differs from the package table ({size})')
                shutil.move(src, os.path.join(d, fname)); n += 1
    print(f'{n} files in {len(os.listdir(repo))} driver packages under {repo}')


if __name__ == '__main__':
    main()
