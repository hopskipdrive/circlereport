lib = File.expand_path('.', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hsd_circle_reports'
HsdCircleReports::Report.start(ARGV)
