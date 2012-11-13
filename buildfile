require 'buildr/git_auto_version'

BONITA_VERSION="5.7.1"
unzip_dir = "#{File.dirname(__FILE__)}/target/bonita"

task "unzip" do
  package_url = "http://repo.fire.dse.vic.gov.au/content/repositories/releases/com/bonitasoft/bonitasoft-server-sp/#{BONITA_VERSION}/bonitasoft-server-sp-#{BONITA_VERSION}.zip"
  package_zip = download("downloads/#{File.basename(package_url)}" => package_url)
  package_zip.invoke
  unzip_task = unzip(unzip_dir => package_zip)
  unzip_task.from_path("bonita_user_experience/with_execution_engine_without_client").include("bonita.war")
  unzip_task.from_path("bonita_execution_engine/interfaces/REST").include("without_engine*")
  unzip_task.from_path("bonita_execution_engine/engine").include("libs/dom4j*.jar")
  unzip_task.from_path("bonita_execution_engine/engine").include("libs/xpp*.jar")
  unzip_task.from_path("conf/bonita").include("client*")
  unzip_task.from_path("xcmis").include("xcmis.war")
  unzip_task.from_path("security").include("commons-codec-1.4.jar")
  unzip_task.from_path("security").include("generateKey-5.7.1.jar")
  unzip_task.from_path("security").include("sysUtil-5.7.1.jar")
  unzip_task.extract
end

define "bpm" do
  project.group = "au.gov.vic.dse.fire.bonita"
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  project.version = ENV['PRODUCT_VERSION'] if ENV['PRODUCT_VERSION']

  define "bonita" do
    resources.enhance %w(unzip) do
      package(:war).path("WEB-INF/lib").tap do |path|
        path.include Dir["#{unzip_dir}/without_engine/*.jar"]
      end
    end
    package(:war).tap do |war|
      war.merge("#{unzip_dir}/bonita.war").exclude("WEB-INF/web.xml")
    end
    check package(:war) do
      it.should contain("console/scripts/bonita.js")
      it.should contain("WEB-INF/lib/xpp3_min-1.1.4c.jar")
    end
  end

  define "keygen" do
    resources.enhance %w(unzip)
    package(:jar).tap do |jar|
      jar.merge("#{unzip_dir}/commons-codec-1.4.jar")
      jar.merge("#{unzip_dir}/generateKey-5.7.1.jar")
      jar.merge("#{unzip_dir}/sysUtil-5.7.1.jar")
    end
    check package(:jar) do
      it.should contain("org/apache/commons/codec/language/Soundex.class")
      it.should contain("org/bonitasoft/security/generateKey/GenerateKey.class")
      it.should contain("org/bonitasoft/security/sysutil/SysUtil.class")
    end
  end

  desc "A zip of the serverside client configuration directory"
  define "client" do
    resources.enhance %w(unzip) do
      package(:zip).tap do |zip|
        zip.include("#{unzip_dir}/client/*")
      end
    end
    package(:zip)
    check package(:zip) do
      it.should contain("conf/web/common/conf/cache-config.xml")
    end
  end

  define "xcmis", :base_dir => "xcmis" do
    resources.enhance %w(unzip) do
      package(:war).path("WEB-INF/lib").tap do |path|
        path.include Dir["#{unzip_dir}/libs/dom4j-*.jar"]
        path.include Dir["#{unzip_dir}/libs/xpp*.jar"]
      end
    end
    package(:war).tap do |war|
      war.merge("#{unzip_dir}/xcmis.war")
    end
    check package(:war), "should contain dependent libraries" do
      it.should contain("WEB-INF/lib/dom4j-1.6.1.jar")
    end
  end

  project.clean { rm_rf unzip_dir }
end
