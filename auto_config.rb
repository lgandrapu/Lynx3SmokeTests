require_relative 'lynx_auto_helper'
require_relative 'lynx_auto_helper'

class AutoConfig

  QA_ENVIRONMENT = 'qa'

  STAGING_ENVIRONMENT = 'staging'

  SUPPORTED_ENVIRONMENTS = [QA_ENVIRONMENT, STAGING_ENVIRONMENT]

  QA_PROPERTIES_FILE_NAME_WINDOWS = 'c:\smoke_test_qa_properties.yml'

  QA_PROPERTY_FILE_NAME_LINUX = '/opt/temp/smoke_test_qa_properties.yml'

  # Leaving the file name to be part of this constant, but if the file name is the same on different platforms,
  # that can be extracted into a constant, which can be used by the two environments
  STAGING_PROPERTIES_FILE_NAME_WINDOWS = 'c:\smoke_test_staging_properties.yml'

  STAGING_PROPERTIES_FILE_NAME_LINUX = '/opt/temp/smoke_test_staging_properties.yml'

  WINDOWS_OS = 'windows'

  LINUX_OS = 'linux'


  def self.get_supported_environments

    public
    SUPPORTED_ENVIRONMENTS

  end

    # Returns the name of the property file including the full path determined by the host operating system
  def self.get_property_file_name(environment)

  public

    #TODO assert argument is not null and not empty
    case environment

    when QA_ENVIRONMENT

      get_qa_properties_file_name

    when STAGING_ENVIRONMENT

      get_staging_properties_file_name

      else

        raise "The environment: #{environment} passed to the method: <#{__method__}> in class: #{self.name} is not supported by automation, check with automation team"

    end
  end

  # Returns the properties file name for the QA environment for windows and linux
  def self.get_qa_properties_file_name

    host_os = LynxAutoHelper.get_host_os

    case "#{host_os}"

      when WINDOWS_OS

        QA_PROPERTIES_FILE_NAME_WINDOWS

      when LINUX_OS

        QA_PROPERTY_FILE_NAME_LINUX

      else

        raise "Host operating system: <#{host_os}> is not supported by automation, so the request <#{__method__}> is invalid"

    end
  end

  # Returns the properties file name for the staging environment for windows and linux
  def self.get_staging_properties_file_name

    host_os = LynxAutoHelper.get_host_os

    case "#{host_os}"

    when WINDOWS_OS

      STAGING_PROPERTIES_FILE_NAME_WINDOWS

    when LINUX_OS

      STAGING_PROPERTIES_FILE_NAME_LINUX

    else

     raise "Host operating system: <#{host_os}> is not supported by automation, so the request <#{__method__}> is invalid"

    end

  end


  URL_PATH_SEPARATOR = '/'

  # This is the prefix that identifies the node on the graph
  # vertex-3f30c6d7-e595-3153-b408-8564b86869a4
  NODE_PREFIX_ON_GRAPH = 'vertex-'

  # part of the url that points to the metrics end point
  METRICS_END_POINT_URL_PART = 'api/v1/metrics/'

  # This is the string of the string at the end of which the profile type starts in the URL (for instance, in 'https://alpha.21technologies.com/#/profile/provider/3f30c6d7-e595-3153-b408-8564b86869a4', profile type is between this delimited and the first '/' after the begin delimited)
  PROFILE_TYPE_BEGIN_DELIM = '/#/profile/'

  LOGIN_URL_PART = '/#/login'

  DATA_CENTER_URL_PART = '/#/datacenter'

  DASH_BOARD_URL_PART = '/#/dashboard'

  # This is the string/character that follows the profile type in the URL
  PROFILE_TYPE_END_DELIM = '/'

  # Expected number of nodes as a result of expansion
  # TODO use this to determine the text for expand link
  EXPANSION_NODE_COUNT = 95

end