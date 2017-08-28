#!/usr/bin/env python2.7

"""Compiles and builds elm-ios apps."""

import os
import os.path
import shutil
import stat
import subprocess
import sys

__author__ = 'Palmer Paul'
__email__ = 'pzpaul2002@yahoo.com'
__version__ = '0.1.0'

# Constants
TEMPLATE_NAME = 'AppTemplate'
COMPILED_ELM_FNAME = 'compiledElm.js'
ASSETS_FNAME = 'assets'
OWNER = 'pzp1997'
VERSION = __version__


def join_path(*args):
    """Create an absolute path from the partial paths."""
    return os.path.abspath(os.path.join(*args))


def process_args(args):
    """Pre-processes the passed args before they are given to elm-make"""
    it = iter(args)
    next(it)

    new_args = ['elm-make']
    bundle_id = None

    for arg in it:
        if arg.startswith('--output'):
            if '=' not in arg:
                next(it)
            continue

        if arg.startswith('--name'):
            bundle_id = (arg.split('=', 1)[-1]
                         if '=' in arg else next(it))
            continue

        if arg in ('--help', '-h'):
            print ("usage: ./elm-ios.py --name=com.company.ExampleApp ...\n"
                   "All the other arguments and flags are identical to those "
                   "from elm-make, except for --output (which is ignored). "
                   "See `elm-make --help` for details.")
            raise SystemExit

        new_args.append(arg)

    new_args.append('--output={}'.format(COMPILED_ELM_FNAME))

    return new_args, bundle_id


def find_and_replace(filepath, old, new):
    with open(filepath, 'r+') as f:
        content = f.read()
        if old in content:
            new_content = content.replace(old, new)
            f.seek(0)
            f.truncate()
            f.write(new_content)


def change_app_name(path, app_name):
    for dirpath, dirnames, filenames in os.walk(path, topdown=True):
        for filename in filenames:
            # skip the compiled Elm file
            if filename == COMPILED_ELM_FNAME:
                continue

            filepath = os.path.join(dirpath, filename)

            # make the file writable
            permissions_mode = os.stat(filepath).st_mode
            os.chmod(filepath, permissions_mode | stat.S_IWOTH)

            # find and replace the app name in the file
            find_and_replace(filepath, TEMPLATE_NAME, app_name)

            # rename the file if it contains the app name
            if TEMPLATE_NAME in filename:
                new_name = filename.replace(TEMPLATE_NAME, app_name)
                os.rename(filepath, os.path.join(dirpath, new_name))

        # skip the assets directory
        dirnames[:] = [dirname for dirname in dirnames
                       if dirname != ASSETS_FNAME]

        for index, dirname in enumerate(dirnames):
            # rename the directory if it contains the app name
            if TEMPLATE_NAME in dirname:
                new_name = dirname.replace(TEMPLATE_NAME, app_name)
                # update the directory name for the rest of the traversal
                dirnames[index] = new_name
                os.rename(os.path.join(dirpath, dirname),
                          os.path.join(dirpath, new_name))


def change_bundle_id(path, bundle_id, app_name):
    pbxproj_path = join_path(
        path, '{}.xcodeproj'.format(app_name), 'project.pbxproj')
    find_and_replace(
        pbxproj_path, 'org.elm-lang.{}'.format(app_name), bundle_id)


def run_elm_make(elm_make_args):
    try:
        subprocess.check_call(elm_make_args)
    except subprocess.CalledProcessError:
        print "Uh oh! Looks like your Elm app didn't compile. Aborting."
        raise SystemExit
    except OSError:
        print ("I require elm-make but it's not installed. Go to elm-lang.org "
               "to find a guide for installing it. Aborting.")
        raise SystemExit


def main():
    # Calculate the necessary paths
    CWD = os.getcwd()
    ELM_IOS_DIR = join_path(
        CWD, 'elm-stuff', 'packages', OWNER, 'elm-ios', VERSION)

    # Assert that elm-ios is installed
    if not os.path.isdir(ELM_IOS_DIR):
        print ("I require {0}/elm-ios v{1} but it's not installed. Please "
               "install it using `elm-package install {0}/elm-ios`. "
               "Aborting.").format(OWNER, VERSION)
        raise SystemExit

    TEMPLATE_DIR = join_path(ELM_IOS_DIR, 'AppTemplate')
    BUILD_DIR = join_path(CWD, 'ios')
    ASSETS_DIR = join_path(CWD, ASSETS_FNAME)

    # Process the args for later use
    elm_make_args, bundle_id = process_args(sys.argv)

    run_elm_make(elm_make_args)

    # Clean the build directory
    if os.path.isdir(BUILD_DIR):
        shutil.rmtree(BUILD_DIR)

    # Copy the template into the build directory
    shutil.copytree(TEMPLATE_DIR, BUILD_DIR)

    # Move the compiled elm code into the bundle
    os.rename(join_path(CWD, COMPILED_ELM_FNAME),
              join_path(BUILD_DIR, TEMPLATE_NAME, COMPILED_ELM_FNAME))

    # Copy any assets, if they exist
    if os.path.isdir(ASSETS_DIR):
        shutil.copytree(
            ASSETS_DIR, join_path(BUILD_DIR, TEMPLATE_NAME, 'assets'))

    # Rename stuff if --name flag is present
    if bundle_id is not None:
        # Change the name in the build directory
        app_name = bundle_id.rsplit('.', 1)[-1]
        change_app_name(BUILD_DIR, app_name)
        change_bundle_id(BUILD_DIR, bundle_id, app_name)

    print "created Xcode project in ./ios"


if __name__ == '__main__':
    main()
