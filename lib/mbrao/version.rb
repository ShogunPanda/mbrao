# encoding: utf-8
#
# This file is part of the mbrao gem. Copyright (C) 2013 and above Shogun <shogun_panda@me.com>.
# Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
#

module Mbrao
  # The current version of mbrao, according to semantic versioning.
  #
  # @see http://semver.org
  module Version
    # The major version.
    MAJOR = 0

    # The minor version.
    MINOR = 5

    # The patch version.
    PATCH = 0

    # The current version of mbrao.
    STRING = [MAJOR, MINOR, PATCH].compact.join(".")
  end
end
