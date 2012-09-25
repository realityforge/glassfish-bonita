BONITA_VERSION="5.7.1"
package_url = "http://example.com/BOS-SP-#{BONITA_VERSION}-deploy.zip"
package_zip = download("downloads/#{File.basename(package_url)}" => package_url)
unzip_dir = "target/#{File.basename(package_url, '.zip')}"

task "unzip" do
  unzip_task = unzip(unzip_dir => package_zip.name)
  unzip_task.from_path("bonita_user_experience/with_execution_engine_without_client").include("bonita.war")
  #unzip_task.from_path("bonita_execution_engine/interfaces/REST/with_engine").include("bonita-server-rest.war")
  unzip_task.from_path("xcmis").include("xcmis.war")
  unzip_task.extract
end

file("#{unzip_dir}/bonita.war" => "unzip")
#file("#{unzip_dir}/bonita-server-rest.war" => "unzip")
file("#{unzip_dir}/xcmis.war" => "unzip")

define "bonita" do
  project.group = "au.gov.vic.dse.fire.bonita"
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'
  compile.enhance ["unzip"]
  package(:war).tap do |war|
    war.merge("#{unzip_dir}/bonita.war")#.exclude("WEB-INF/web.xml")
    #war.merge("#{unzip_dir}/bonita-server-rest.war").exclude("WEB-INF/web.xml")
  end
end

define "xcmis", :base_dir => "xcmis" do
  project.group = "au.gov.vic.dse.fire.bonita"
  compile.enhance ["unzip"]
  package(:war).tap do |war|
    war.merge("#{unzip_dir}/xcmis.war")
  end
end
