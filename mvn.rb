#!/bin/ruby

# Launchy Config <runner plugin>:
# mvn
# C:\Windows\System32\cmd.exe
# /K "ruby C:\java\ProgrammerTools\bin\ruby\mvn.rb $$"

# Launchy Command: mvn <tab> <project name>...

require 'fileutils'
require 'yaml'
require 'javascript_hash'

@config = nil
@mvnCommand = ""

def prettyArray(arg)
  ret = " "
  array = arg.sort
  array.each{|key, value|
    if (value)
      ret += key + " "
    end
  }
  ret
end
def pretty_maven_arguments()
  ret = ""
  @config.maven.arguments.each{ |it|
    ret += it + " "
  }
  ret
end

def addBuild(dir, mavenArgs, flags)
  projectDirectory = String.new(@config.directory)
  projectDirectory = File.join(projectDirectory.gsub("\\", "/"),  dir)
  
  if(@mvnCommand.length > 0)
    @mvnCommand << " && "
  end
	
  @mvnCommand << "mvn #{prettyArray(mavenArgs)} -f #{projectDirectory}/pom.xml #{pretty_maven_arguments()} "
end

def setToForIn(status, args, map)
  argsArray = args.split(//)
  argsArray.each { |char|
    map.each { |key, value|
      regex = Regexp.new("^"+char+".+")
      if(regex.match(key))
        map[key] = status
      end
    }
  }
end

# m ci ip ci gw p i =>
# mvn clean install isl-privateloan
# mvn clean install genesis/genesis-web
# mvn process-sources integration

def process(args, flags, mavenArgs, dirMappings)
  doMavenArgs = true;
  args.each do |arg|
    if(/^-/.match(arg))
      next
    end

    if(doMavenArgs)
      setToForIn(false, "cipt", mavenArgs)
      setToForIn(true, arg, mavenArgs)
    else
      dirMappings.each{ |it|
        puts dirMappings[it]
        puts it
      }
      if(dirMappings[arg])
        addBuild(dirMappings[arg], mavenArgs, flags)
      else
        regexStr = "^"
        arg.gsub(/./){|s| regexStr += s+"[a-zA-Z]*-"}
        regexStr = regexStr.chop
        regexStr += "$"
        
        regex = Regexp.new(regexStr)
        
        dirEntries = Dir.entries(@config.directory)
        dirEntries.each{|x|
          if (regex.match(x))
            addBuild(x, mavenArgs, flags)
            break 
          end
        }
      end
    end
    doMavenArgs = !doMavenArgs
  end
  
  puts "****************************************************"
  puts "Maven Command(s) to execute:\n" + @mvnCommand.gsub(" && ", " &&\n")
  puts "****************************************************\n\n"
  
  system (@mvnCommand)
end

def parsePhases()
  s = @config.maven.phases
  phases = { }
  s.each{|it|
    phases[it] = false
  }
  phases
end

file_location = ENV['M_SETTINGS_FILE']
if(file_location == nil)
  file_location = "mvnSettings.yml"
end

@config = YAML::load_file(file_location);

flags={}
flags[:printDoNotRun]=ARGV.include?("-v")
process(ARGV, flags, parsePhases(),  @config.mappings )
