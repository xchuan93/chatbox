#!/bin/bash
#
# Wire
# Copyright (C) 2016 Wire Swiss GmbH
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
# ----------------------------------------------------------------------


#
# USAGE:
# This scripts checks that the necessary tools are installed on the local machine
# and sets up the project so that it can be built with Xcode
#

set -e

function die { ( >&2 echo "$*"); exit 1; }

# CHECK PREREQUISITES
hash carthage 2>/dev/null || die "Can't find Carthage, please install from https://github.com/Carthage/Carthage"
hash xcodebuild 2>/dev/null || die "Can't find Xcode, please install from the App Store"
hash gem 2>/dev/null || die "Can't find Ruby (gem), please install from https://www.ruby-lang.org/en/"

version=`carthage version | tail -n 1`
CARTHAGE_VERSION=( ${version//./ } )
version=`xcodebuild -version | head -n 1 | sed "s/Xcode //"`
XCODE_VERSION=( ${version//./ } )

[[ ${CARTHAGE_VERSION[0]} -gt 0 || ${CARTHAGE_VERSION[1]} -ge 17 ]] || die "Carthage should be at least version 0.17"
[[ ${XCODE_VERSION[0]} -gt 7 || ( ${XCODE_VERSION[0]} -eq 7 && ${XCODE_VERSION[1]} -ge 3 ) ]] || die "Xcode version should be at least 7.3.1"

# SETUP
echo "ℹ️  Carthage bootstrap. This might take a while..."
carthage bootstrap --platform ios
echo ""

echo "ℹ️  Downloading AVS library..."
./Scripts/download-avs.sh
echo ""

echo "ℹ️  Check that bundler is installed... (requires SUDO)"
hash bundle 2>/dev/null || sudo gem install bundler
echo ""

echo "ℹ️  Pod install. This might take a while..."
bundle install --path ~/.gem && bundle exec pod install
echo ""

echo "ℹ️  Downloading additional assets..."
./Scripts/download-assets.sh
echo ""

echo "✅  Wire project was set up, you can now open Wire-iOS.xcworkspace"
