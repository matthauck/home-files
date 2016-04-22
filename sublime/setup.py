#!/usr/bin/env python

import os, sys, platform
import shutil
import subprocess
import zipfile

def main():
    packages_dir = os.path.join( sublime_dir(), 'Installed Packages' )
    if not os.path.exists( packages_dir ):
        os.makedirs(packages_dir)

    install_package_control(packages_dir)

    symlink_user_dir()

def install_package_control(packages_dir):
    pkg_ctrl = os.path.join(packages_dir, "Package Control.sublime-package")
    if not os.path.exists(pkg_ctrl):
        print 'Installing Package Control...'
        subprocess.check_call(['git', 'clone', 'https://github.com/wbond/package_control'], cwd=packages_dir)

        pkg_ctrl_source = os.path.join(packages_dir, 'package_control')
        # checkout a known good state
        subprocess.check_call(['git', 'checkout', '-b', 'v3.1.2', '3.1.2'], cwd=pkg_ctrl_source)

        zf = zipfile.ZipFile(pkg_ctrl, 'w')
        prev_dir = os.getcwd()
        os.chdir(pkg_ctrl_source)
        try:
            for dirname, subdirs, files in os.walk("."):
                if '.git' in dirname:
                    continue
                zf.write(dirname)
                for filename in files:
                    if filename == '.gitignore':
                        continue
                    zf.write(os.path.join(dirname, filename))

        finally:
            os.chdir(prev_dir)

def symlink_user_dir():
    packages_dir = os.path.join(sublime_dir(), 'Packages')
    if not os.path.exists(packages_dir):
        os.makedirs(packages_dir)
    users_dir = os.path.join(packages_dir, 'User')
    if os.path.exists(users_dir):
        if os.path.islink(users_dir) or is_windows():
            return
        os.rename(users_dir, os.path.join(packages_dir, '..', 'User.bak'))

    print 'Setting up User directory'
    target = os.path.join(current_dir(), 'User')
    if is_windows():
        subprocess.check_call(['mklink', '/D', users_dir, target], shell=True)
    else:
        os.symlink(target, users_dir)

    # cp preferences template
    shutil.copy(os.path.join(users_dir, 'Preferences.sublime-settings.template'),
                os.path.join(users_dir, 'Preferences.sublime-settings'))

def current_dir():
    return os.path.dirname(os.path.realpath(__file__))

def sublime_dir():
    if is_windows():
        return os.path.join(os.path.expanduser('~'), 'AppData', 'Roaming', 'Sublime Text 3')
    elif is_mac():
        return os.path.join(os.path.expanduser('~'), 'Library', 'Application Support', 'Sublime Text 3')
    else:
        return os.path.join(os.path.expanduser('~'), '.config', 'sublime-text-3')

def is_mac():
    return platform.system() == 'Darwin'

def is_windows():
    return os.name == 'nt'

# call main
if __name__ == '__main__':
    main()
