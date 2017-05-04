Pod::Spec.new do |s|
  s.name             = 'LongPressTableViewReordering'
  s.version          = '0.3.0'
s.summary          = 'LongPressTableViewReordering lets you long press to reorder table view cells.'

  s.description      = <<-DESC
LongPressTableViewReordering is a library that makes it easy
to let users long press to reorder cells in a table view. To
use it, implement the `LongPressTableViewReorderer` protocol
instead of `UITableViewDataSource` and use it as data source.
This will automatically enable long press to reorder.

                       DESC

  s.homepage         = 'https://github.com/danielsaidi/LongPressTableViewReordering'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Saidi' => 'daniel.saidi@bookbeat.com' }
  s.source           = { :git => 'https://github.com/danielsaidi/LongPressTableViewReordering.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/danielsaidi'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LongPressTableViewReordering/Classes/**/*'
end
