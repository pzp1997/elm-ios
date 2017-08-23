#!/usr/bin/env python2.7

"""Compiles and builds elm-ios apps."""

import os
import os.path
import plistlib
import shutil
import subprocess
import sys

__author__ = 'Palmer Paul'
__email__ = 'pzpaul2002@yahoo.com'
__version__ = '0.1.0'

# Constants
TEMPLATE_NAME = 'ExampleApp'
OWNER = 'pzp1997'
VERSION = '0.1.0'

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
            bundle_id = (arg.split('=', maxsplit=1)[-1]
                         if '=' in arg else next(it))
            continue

        if arg in ('--help', '-h'):
            print ("usage: ./elm-ios.py --name=com.company.ExampleApp ...\n"
                   "The --name flag is mandatory. All the other arguments "
                   "and flags are identical to those from elm-make, except "
                   "for --output (which is ignored). See `elm-make --help`")
            raise SystemExit

        new_args.append(arg)

    return new_args, bundle_id


def update_info_plist(path, bundle_id, app_name):
    with open(path, 'w+') as file_pointer:
        info_plist = plistlib.readPlist(file_pointer)
        info_plist['CFBundleIdentifier'] = bundle_id
        info_plist['CFBundleName'] = app_name
        info_plist['CFBundleExecutable'] = app_name
        plistlib.writePlist(info_plist, file_pointer)


def change_name(path, bundle_id, app_name):
    # Rename executable
    os.rename(join_path(path, TEMPLATE_NAME), join_path(path, app_name))

    # Update Info.plist
    update_info_plist(
        join_path(path, app_name, 'Info.plist'), bundle_id, app_name)

    # TODO Rename top-level .app directory
    # os.rename(template_path, join_path(template_path, '..', app_name + '.app'))


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
    TEMPLATE_DIR = join_path(
        CWD, 'elm-stuff', 'packages', OWNER, 'elm-ios', VERSION, 'template')
    ASSETS_DIR = join_path(CWD, 'assets')
    BUILD_DIR = join_path(CWD, 'ios')
    COMPILED_CODE = join_path(CWD, 'index.js')

    # Assert that the template dir exists
    if not os.path.isdir(TEMPLATE_DIR):
        print ("I require {0}/elm-ios v{1} but it's not installed. Please "
               "install it using `elm-package install {0}/elm-ios`. "
               "Aborting.").format(OWNER, VERSION)
        raise SystemExit

    # Process the args for later use
    elm_make_args, bundle_id = process_args(sys.argv)

    if bundle_id is None:
        print ("You must specify a Bundle Identifier using the --bundle-id "
               "flag. Typically, the Bundle Identifier is in reverse domain "
               "name notation, e.g. com.company.MyAwesomeApp.")
        raise SystemExit

    run_elm_make(elm_make_args)

    # # Create the build directory if it doesn't yet exist
    #
    # if not os.path.isdir(BUILD_DIR):
    #     os.makedirs(BUILD_DIR)

    # Clean the build directory
    if os.path.isdir(BUILD_DIR):
        shutil.rmtree(BUILD_DIR)

        # bundle_id = bundle_id or 'com.company.ExampleApp'

    # Copy the template into the build directory
    shutil.copytree(TEMPLATE_DIR, BUILD_DIR)

    # Change the name in the build directory
    app_name = bundle_id.rsplit('.', 1)[-1]
    change_name(BUILD_DIR, bundle_id, app_name)

    # Move the compiled elm code into the bundle
    os.rename(COMPILED_CODE, join_path(BUILD_DIR, 'index.js'))

    # Copy any assets, if they exist
    if os.path.isdir(ASSETS_DIR):
        shutil.copytree(ASSETS_DIR, join_path(BUILD_DIR, 'assets'))


if __name__ == '__main__':
    main()
