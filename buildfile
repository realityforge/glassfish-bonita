require 'buildr/git_auto_version'
require 'buildr/single_intermediate_layout'

BONITA_VERSION='5.8'
unzip_dir = "#{File.dirname(__FILE__)}/target/extracted"

task 'unzip' do
  package_url = "http://repo.fire.dse.vic.gov.au/content/repositories/fisg/com/bonitasoft/bonitasoft-server-sp/#{BONITA_VERSION}/bonitasoft-server-sp-#{BONITA_VERSION}.zip"
  package_zip = download("downloads/#{File.basename(package_url)}" => package_url)
  package_zip.invoke
  unzip_task = unzip(unzip_dir => package_zip)
  unzip_task.from_path('bonita_user_experience/with_execution_engine_without_client').include('bonita.war')
  unzip_task.from_path('conf/bonita').include('client*')
  unzip_task.from_path('security').include('commons-codec-1.4.jar')
  unzip_task.from_path('security').include("generateKey-#{BONITA_VERSION}.jar")
  unzip_task.from_path('security').include("sysUtil-#{BONITA_VERSION}.jar")
  unzip_task.extract
end

define 'bonita' do
  project.group = 'au.gov.vic.dse.fire.bonita'
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  project.version = ENV['PRODUCT_VERSION'] if ENV['PRODUCT_VERSION']

  define 'user-experience' do
    project.no_iml
    package(:war).tap do |war|
      war.merge("#{unzip_dir}/bonita.war").exclude("WEB-INF/web.xml")
    end
    check package(:war) do
      it.should contain('console/scripts/bonita.js')
      it.should contain('WEB-INF/lib/xpp3_min-1.1.4c.jar')
    end
  end

  define 'keygen' do
    project.no_iml
    resources.enhance %w(unzip)
    package(:jar).tap do |jar|
      jar.merge("#{unzip_dir}/commons-codec-1.4.jar")
      jar.merge("#{unzip_dir}/generateKey-#{BONITA_VERSION}.jar")
      jar.merge("#{unzip_dir}/sysUtil-#{BONITA_VERSION}.jar")
    end
    check package(:jar) do
      it.should contain('org/apache/commons/codec/language/Soundex.class')
      it.should contain('org/bonitasoft/security/generateKey/GenerateKey.class')
      it.should contain('org/bonitasoft/security/sysutil/SysUtil.class')
    end
  end

  desc 'A zip of the serverside client configuration directory'
  define 'client' do
    project.no_iml
    resources.enhance %w(unzip) do
      package(:zip).tap do |zip|
        zip.include("#{unzip_dir}/client/*")
      end
    end
    package(:zip)
    check package(:zip) do
      it.should contain('conf/web/common/conf/cache-config.xml')
    end
  end
end
