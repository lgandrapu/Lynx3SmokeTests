# Provides generic methods to support automation
class LynxAutoHelper

  total_verification_count = 0

  def self.setup_test

    total_verification_count += 1
    # Reset the pass/fail status of the test to true at the start of each
    set_test_status(true)

  end

  def self.set_execution_environment(environment)

    #TODO assert argument not null, not emptry
    @execution_environment = environment

    puts "The environment passed to the method: <#{__method__}> in class: #{self.name} is : #{environment}"

  end

  def self.get_execution_environment

    @execution_environment

  end


  def self.set_test_status(has_passed)

  end

  def self.set_browser_instance(browser)

    #TODO assert argument not null, not emptry
    @browser = browser

  end

  def self.get_browser_instance

    @browser

  end

# Returns the operating system that this code is running on
  def self.get_host_os
    @os ||= (
    host_os = RbConfig::CONFIG['host_os'].to_s
    case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        :windows
      when /darwin|mac os/
        :macosx
      when /linux/
        :linux
      when /solaris|bsd/
        :unix
      else
        raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
    end
    )
  end
  #host_os
end