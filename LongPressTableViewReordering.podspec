Pod::Spec.new do |s|
  s.name             = 'LongPressTableViewReordering'
  s.version          = '0.1.0'
s.summary          = 'LongPressTableViewReordering lets you long press to reorder cells in a UITableView.'

  s.description      = <<-DESC
LongPressTableViewReordering is a Swift library that lets you
long press to reorder cells in a UITableView.

LongPressTableViewReorderer extends the UITableViewDataSource
protocol. Just implement the protocol to automatically enable
this functionality for any table view.

                       DESC

  s.homepage         = 'https://github.com/danielsaidi/LongPressTableViewReordering'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Saidi' => 'daniel.saidi@bookbeat.com' }
  s.source           = { :git => 'https://github.com/danielsaidi/LongPressTableViewReordering.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/danielsaidi'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LongPressTableViewReordering/Classes/**/*'
end
