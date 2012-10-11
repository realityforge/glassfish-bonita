BONITA_VERSION="5.7.1"
unzip_dir = "target/bonita-#{BONITA_VERSION}"

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

  define "bonita" do
    compile.enhance %w(unzip)
    package(:war).tap do |war|
      war.merge("#{unzip_dir}/bonita.war").exclude("WEB-INF/web.xml")
      war.libs += Dir["#{unzip_dir}/without_engine/*.jar"]
    end
  end

  define "keygen" do
    compile.enhance %w(unzip)
    package(:jar).tap do |jar|
      jar.merge("#{unzip_dir}/commons-codec-1.4.jar")
      jar.merge("#{unzip_dir}/generateKey-5.7.1.jar")
      jar.merge("#{unzip_dir}/sysUtil-5.7.1.jar")
    end
  end

  desc "A zip of the serverside client configuration directory"
  define "client" do
    compile.enhance %w(unzip)
    package(:zip).tap do |zip|
      zip.include("#{unzip_dir}/client/*")
    end
  end

  define "xcmis", :base_dir => "xcmis" do
    compile.enhance %w(unzip)
    package(:war).tap do |war|
      war.merge("#{unzip_dir}/xcmis.war")
      war.libs += Dir["#{unzip_dir}/libs/dom4j*.jar"]
      war.libs += Dir["#{unzip_dir}/libs/xpp*.jar"]
    end
  end

  compile.enhance do
    mkdir_p _(:target)
    File.open(_(:target, "version.txt"), "wb") do |f|
      f.write "PRODUCT_VERSION=#{project.version}\n"
    end
  end
end
