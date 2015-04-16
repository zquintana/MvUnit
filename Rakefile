MODULE_CODE = "mvunit"
VERSION = "5.000"
MVS = FileList["src/mvunit.mv"]
CWD = Dir.pwd


directory "build"



task :default => [:compile]

desc "Clean up build"
task :clean do
	rm_rf "build"
end

desc "Compile module resources"
task :compile_resources => [:clean, "build"] do
	list = []
	FileList['resources/**/**.coffee'].each do |f|
		list.push f.to_s
	end
	sh "cat #{list.join(' ')} | coffee --compile --stdio > ./resources/js/mv-unit.js"
	sh "sass --sourcemap=none --update resources/scss/admin.scss:resources/css/admin.css"
end

desc "Build the module"
task :compile => [:clean, "build"] do
	compile_mvs(!ENV['DEBUG'] || ENV['DEBUG'] != '1')
end

desc "Compile resources and build module"
task :compile_all => [:clean, 'build', :compile_resources] do 
	compile_mvs(!ENV['DEBUG'] || ENV['DEBUG'] != '1')
end

task :release => [:compile_all] do
	rm_rf 'release'
	mkdir_p 'release'
	FileList['build/**/**'].each do |f|
		basename = File.basename(f)
		mv f, "release/#{basename}"
	end
	rm_rf 'build'
end

task :debug do
	ENV['DEBUG'] = '1'
	Rake::Task['compile'].invoke
end


def compile_mvs(clean=true) 
	mvc = "mvc"
	mvc += " -D DEBUG" if ENV['DEBUG'] && ENV['DEBUG'] == '1'

	MVS.each do |f|
		basename = File.basename(f)
		cp f, "build/#{basename}"
		sh "#{mvc} build/#{basename}"
		rm "build/#{basename}"
	end
end