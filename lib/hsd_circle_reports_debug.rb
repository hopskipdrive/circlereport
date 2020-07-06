# This is similar to the executable bin/hsd_circle_reports, with a different load path.
# It allows simple debugging access in RubyMine - this is the ruby script to name in
#   the "Ruby Script" argument in your Run/Debug configuration.
lib = File.expand_path('.', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hsd_circle_reports'
HsdCircleReports::Report.start(ARGV)
