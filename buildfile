BONITA_VERSION="5.7.1"
unzip_dir = "target/bonita-#{BONITA_VERSION}"

task "unzip" do
  package_url = "http://repo.fire.dse.vic.gov.au/content/repositories/releases/com/bonitasoft/bonitasoft-server-sp/#{BONITA_VERSION}/bonitasoft-server-sp-#{BONITA_VERSION}.zip"
  package_zip = download("downloads/#{File.basename(package_url)}" => package_url)
  package_zip.invoke
  unzip_task = unzip(unzip_dir => package_zip)
  unzip_task.from_path("bonita_user_experience/with_execution_engine_without_client").include("bonita.war")
  #unzip_task.from_path("bonita_execution_engine/interfaces/REST/with_engine").include("bonita-server-rest.war")
  unzip_task.from_path("xcmis").include("xcmis.war")
  unzip_task.extract
end

file("#{unzip_dir}/bonita.war" => "unzip")
#file("#{unzip_dir}/bonita-server-rest.war" => "unzip")
file("#{unzip_dir}/xcmis.war" => "unzip")

define "bpm" do
  project.group = "au.gov.vic.dse.fire.bonita"
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'

  define "bonita" do
    compile.enhance %w(unzip)
    package(:war).tap do |war|
      war.merge("#{unzip_dir}/bonita.war")
      #.exclude("WEB-INF/web.xml")
      #war.merge("#{unzip_dir}/bonita-server-rest.war").exclude("WEB-INF/web.xml")
    end
  end

  define "xcmis", :base_dir => "xcmis" do
    compile.enhance %w(unzip)
    package(:war).tap do |war|
      war.merge("#{unzip_dir}/xcmis.war")
    end
  end

  package.enhance do
    mkdir_p _(:target)
    File.open(_(:target, "version.txt"), "wb") do |f|
      f.write "PRODUCT_VERSION=#{project.version}\n"
    end
  end
end
