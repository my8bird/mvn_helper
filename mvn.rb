#!/bin/ruby

require 'fileutils'

# Launchy Config <runner plugin>:
# mvn
# C:\Windows\System32\cmd.exe
# /K "ruby C:\java\ProgrammerTools\bin\ruby\mvn.rb $$"

# Launchy Command: mvn <tab> <project name>...

def prettyArray(arg)
  ret = " "
  array = arg.sort
  array.each{|x|
    key = x[0]
    value = x[1]
    if (value)
      ret += key + " "
    end
  }
  ret
end

def runBuild(dir, mavenArgs, flags)
  s = ENV['PROJECT_DIR']
  if(s == nil)
    s = "C:\\users\\common\\privateoan"
  end
  
  projectDirectory = String.new(s)
  projectDirectory = File.join(projectDirectory.gsub("\\", "/"),  dir)
	
  mvnCommand = "mvn -B -ff -f #{projectDirectory}/pom.xml #{prettyArray(mavenArgs)} -Pisl-internal"
  puts mvnCommand

  if(flags[:printDoNotRun])
    puts mvnCommand
  elsif
    system(mvnCommand)

    if($?.exitstatus != 0)
      puts "Unusual retval"
      exit
    end

  end
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
    elsif
      if(dirMappings[arg])
        runBuild(dirMappings[arg], mavenArgs, flags)
      else
        regexStr = "^"
        arg.gsub(/./){|s| regexStr += s+"[a-zA-Z]*-"}
        regexStr = regexStr.chop
        regexStr += "$"
        
        regex = Regexp.new(regexStr)
        
        dirEntries = Dir.entries("C:/users/common/privateloan")
        dirEntries.each{|x|
          if (regex.match(x))
            runBuild(x, mavenArgs, flags)
            break 
          end
        }
      end
    end
    doMavenArgs = !doMavenArgs
  end
end

def parseCommands()
  s = ENV['MAVEN_COMMANDS']
puts s
  if(s == nil)
    s = "clean, install, process-resources, test-compile, jetty:run"
  end

  args={}
  list = s.split(',')
  list.each{|it|
    puts it
    args[it.strip] = false
  }

  args
end

possibleMavenArguments = parseCommands()

projectDirectoryMappings={}
projectDirectoryMappings['ippdf']='isl-privateloan-pdf'
projectDirectoryMappings['aw']='alpha/alpha-web'
projectDirectoryMappings['ae']='alpha/alpha-ear'
projectDirectoryMappings['gw']='genesis/genesis-web'
projectDirectoryMappings['ge']='genesis/genesis-ear'
projectDirectoryMappings['ipprocess']= 'isl-privateloan-process'

flags={}
flags[:printDoNotRun]=ARGV.include?("-v")

process(ARGV, flags, possibleMavenArguments, projectDirectoryMappings)
