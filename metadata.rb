name 'stock_app_cookbook'
maintainer 'match8969'
maintainer_email 'match8969@yahoo.co.jp'
license 'All Rights Reserved'
description 'Installs/Configures stock_app_cookbook'
long_description 'Installs/Configures stock_app_cookbook'
version '0.1.0'
chef_version '>= 14.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/stock_app_cookbook/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/stock_app_cookbook'

depends 'opsworks_ruby', '1.8.0'
depends 'yum', '~> 5.1.0'


