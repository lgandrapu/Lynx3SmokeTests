require_relative 'auto_config'
require_relative 'profile_types'
require_relative 'lynx_auto_helper'

class PropertiesReader

  URL_PATH_SEPARATOR = AutoConfig::URL_PATH_SEPARATOR

  def self.load_get_properties_file

    @environment = LynxAutoHelper.get_execution_environment
    #puts "From <#{self.class.name}> class, environment passed to the 'constructor' is: <#{environment}>"

    @properties_file_name = AutoConfig.get_property_file_name(@environment)
    #puts "from PropertiesReader class, @properties_file_name is: <#{@properties_file_name}>"

    #puts "From <#{self.class.name}> class, @properties_file_name is: <#{@properties_file_name}>"

    # Load the properties file and raise exception if the file is not found
    begin

      @properties_file = YAML.load_file(@properties_file_name)

    rescue

      raise "Properties file with the name: <#{@properties_file_name}> expected for the environment: <#{@environment}> (which might have been a command line argument) passed to the constructor of the class '#{self.name}' does not exist."

    end

  end

  def self.get_user_name

    get_property('user_name')

  end

  def self.get_password

    get_property('password')

  end

  def self.get_invalid_password

    valid_password = get_password

    # Remove the first character (yet to find out if it makes the password too short and if it has any unintended consequences)
    valid_password[1..valid_password.length]

  end

  # Reads the property from the properties file (determined in the constructor based on the environment selected)
  # whose key is passed as an argument
  def self.get_property(property_key)

    load_get_properties_file

    # Get the property using the given key
    property_read = @properties_file[property_key]

    # If the property can not be found using the given key, throw an error
    if property_read.nil?

      raise "Property whose key: <#{property_key}> passed to the method: <#{__method__}> is not found in the properties file: <#{@properties_file_name}> for the given environment: <#{@environment}>"

    end

    puts "From the method: <#{__method__}>, the value for the key: <#{property_key}> read from properties file: <#{@properties_file_name}> is: <#{property_read}>"

    property_read

  end

  def self.get_location_uid

    get_property('location_uid')

  end

  def self.get_phone_number_uid

    get_property('phone_number_uid')

  end

  def self.get_npi_uid

    get_property('npi_uid')

  end

  def self.get_tax_id_uid

    get_property('tax_id_uid')

  end

  def self.get_bank_uid

    get_property('bank_uid')

  end

  def self.get_case_uid

    get_property('case_uid')

  end

  def self.get_recipient_uid

    get_property('recipient_uid')

  end

  def self.get_bank_account_uid

    get_property('bank_account_uid')

  end

  def self.get_provider_uid

    get_property('provider_uid')

  end

  def self.get_npi_profile_url

    #get_property('npi_profile_url')

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    npi_type = ProfileTypes::NPI

    # Get the uid from the properties file
    npi_uid = get_npi_uid

    get_profile_url(npi_type, npi_uid)

  end

  def self.get_recipient_profile_url

    #get_property('recipient_profile_url')

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    recipient_type = ProfileTypes::RECIPIENT

    # Get the uid from the properties file
    recipient_uid = get_recipient_uid

    get_profile_url(recipient_type, recipient_uid)

  end

  def self.get_location_profile_url

    #get_property('location_profile_url')

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    location_type = ProfileTypes::LOCATION

    # Get the uid from the properties file
    location_uid = get_location_uid

    get_profile_url(location_type, location_uid)

  end

  def self.get_tax_id_profile_url

    #get_property('tax_id_profile_url')

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    tax_id_type = ProfileTypes::TAX_ID

    # Get the uid from the properties file
    tax_id_uid = get_tax_id_uid

    get_profile_url(tax_id_type, tax_id_uid)

  end

  def self.get_phone_number_profile_url

    #get_property('phone_number_profile_url')

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    phone_number_type = ProfileTypes::PHONE_NUMBER

    # Get the uid from the properties file
    phone_number_uid = get_phone_number_uid

    get_profile_url(phone_number_type, phone_number_uid)

  end

  def self.get_bank_acct_profile_url

    #get_property('bank_acct_profile_url')

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    bank_acct_type = ProfileTypes::BANK_ACCOUNT

    # Get the uid from the properties file
    bank_acct_uid = get_bank_account_uid

    get_profile_url(bank_acct_type, bank_acct_uid)

  end

  def self.get_bank_profile_url

    #get_property('bank_profile_url')

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    bank_type = ProfileTypes::BANK

    # Get the uid from the properties file
    bank_uid = get_bank_uid

    get_profile_url(bank_type, bank_uid)

  end


  def self.get_case_profile_url

    #get_property('case_profile_url')

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    case_type = ProfileTypes::CASE

    # Get the uid from the properties file
    case_uid = get_case_uid

    get_profile_url(case_type, case_uid)

  end

  def self.get_https_base_url

    get_property('https_base_url')

  end

  #def self.get_metrics_url
  #
  #  get_property('metrics_url')
  #
  #end

  def self.get_search_term

    get_property('search_term')

  end

  # Returns the URL for the profile page of the first expected result on the search results page
  def self.get_exp_first_search_result_dest_url

    exp_1st_search_result_dest_url_suffix = get_property('exp_1st_search_result_dest_url_suffix')
    puts "From the method: <#{__method__}>, exp_1st_search_result_dest_url_suffix: <#{exp_1st_search_result_dest_url_suffix}>"

    base_profile_url_prefix = get_base_profile_url_prefix
    puts "From the method: <#{__method__}>, base_profile_url_prefix: <#{base_profile_url_prefix}>"

    exp_first_search_result_dest_url = base_profile_url_prefix + exp_1st_search_result_dest_url_suffix
    puts "From the method: <#{__method__}>, exp_first_search_result_dest_url: <#{exp_first_search_result_dest_url}>"

    exp_first_search_result_dest_url

  end

  # It uses the same value as the first 'suggestion' title, so it
  # doesn't have a property key of it's own in the properties file,
  # but if the design changes and the 'search result' is different from the 'suggestion', then
  # a key for this needs to be added to the properties file and the call
  # to the method 'get_property' below needs to be uncommented
  def self.get_exp_first_search_result_title

    # get_property('exp_first_search_result_title')
    get_exp_first_suggestion_title

  end

  def self.get_exp_first_suggestion_title

    get_property('exp_first_suggestion_title')

  end

  def self.get_exp_suggestions_type_count

    get_property('exp_suggestions_type_count')

  end

  def self.get_exp_location_navigated_to

    location1_uid = get_property('exp_location_navigated_to_uid')
    get_profile_url(ProfileTypes::LOCATION, location1_uid)

  end

  def self.get_exp_phone_navigated_to

    phone_uid = get_property('exp_phone_navigated_to_uid')
    get_profile_url(ProfileTypes::PHONE_NUMBER, phone_uid)

  end

  def self.get_exp_tax_id_navigated_to

    tax_id_uid = get_property('exp_tax_id_navigated_to_uid')
    get_profile_url(ProfileTypes::TAX_ID, tax_id_uid)

  end

  def self.get_exp_provider_navigated_to

    provider_nav_uid = get_property('exp_provider_navigated_to_uid')
    get_profile_url(ProfileTypes::PROVIDER, provider_nav_uid)

  end

  def self.get_expected_initial_node_count

    get_property('expected_initial_node_count')

  end

  def self.get_location1_node_message

    get_property('location1_node_message')

  end

  def self.get_node_vertex_id(uid)

    node_prefix_on_graph = get_node_prefix_on_graph

    node_prefix_on_graph + uid

  end

  def self.get_location1_node_vertex_id

    location1_node_uid = get_property('location1_node_uid')

    get_node_vertex_id(location1_node_uid)

  end

  def self.get_location2_node_message

    #get_property('location2_node_message')
  #
  end

  def self.get_location2_node_vertex_id

    #get_property('location2_node_uid')

    location2_node_uid = get_property('location2_node_uid')

    get_node_vertex_id(location2_node_uid)

  end

  def self.get_tax_id_node_message

    get_property('tax_id_node_message')

  end

  def self.get_tax_id_node_vertex_id

    tax_id_node_uid = get_property('tax_id_node_uid')
    get_node_vertex_id(tax_id_node_uid)

  end

  def self.get_provider_node_message

    get_property('provider_node_message')

  end

  def self.get_provider_node_vertex_id

    #get_property('provider_node_uid')
    #provider_node_uid = get_property('provider_node_uid')
    provider_node_uid = get_provider_uid
    get_node_vertex_id(provider_node_uid)

  end

  def self.get_npi_node_message

    get_property('npi_node_message')

  end

  def self.get_npi_node_vertex_id

    #get_property('npi_node_uid')

    npi_node_uid = get_property('npi_node_uid')
    get_node_vertex_id(npi_node_uid)

  end

  def self.get_suffix_node_vertex_id

    #get_property('suffix_node_uid')

    suffix_node_uid = get_property('suffix_node_uid')
    get_node_vertex_id(suffix_node_uid)

  end

  def self.get_suffix_node_message

    get_property('suffix_node_message')

  end

  def self.get_phone_node_vertex_id

    #phone_node_uid = get_phone_number_uid

    phone_node_uid = get_property('phone_node_uid')
    get_node_vertex_id(phone_node_uid)

  end

  def self.get_phone_node_message

    get_property('phone_node_message')

  end


  #The following methods don't directly access the properties from the properties file, but the values that they return are based on the values read from the properties file (for instance, get_provider_url uses the uid of the provider read from the proerties file)

  # Returns the base url that is common to any profile, for instance, on https://www.alpha.21ct.com, it would return: 'https://alpha.21ct.com/#/profile/' (notice the suffix that is added for profile)
  def self.get_base_profile_url_prefix

    base_url = get_https_base_url
    #puts("From the method: <#{__method__}>, base_url is: <#{base_url}>")

    profile_type_begin_delim = AutoConfig::PROFILE_TYPE_BEGIN_DELIM
    #puts("From the method: <#{__method__}>, profile_type_begin_delim is: <#{profile_type_begin_delim}>")

    base_profile_url_prefix = base_url + profile_type_begin_delim
    #puts("From the method: <#{__method__}>, base_profile_url_prefix is: <#{base_profile_url_prefix}>")

    base_profile_url_prefix

  end

  # Returns the url of the provider.
  def self.get_provider_profile_url

    # Get the string that is part of the URL for this specific profile (for instance, for NPI, it is 'national_provider')
    provider_type = ProfileTypes::PROVIDER

    # Get the uid from the properties file
    provider_uid = get_provider_uid

    get_profile_url(provider_type, provider_uid)

  end

  def self.get_profile_url(profile_type, profile_uid)

    #puts("From the method: '#{__method__}>, profile_type received is: <#{profile_type}>")
    #puts("From the method: '#{__method__}>, profile_uid received is: <#{profile_uid}>")

    provider_url = get_base_profile_url_prefix + profile_type + URL_PATH_SEPARATOR + profile_uid
    #puts("From the method: '#{__method__}>, provider_url is: <#{provider_url}>")

    provider_url

  end

  def self.get_exp_https_login_url

    #get_https_base_url + "/#/login"

    get_https_base_url + AutoConfig::LOGIN_URL_PART

  end

  # Returns the http url by changing the protocol from https to http
  def self.get_http_url

    https_base_url = get_https_base_url

    https_base_url.sub('https', 'http')

  end

  def self.get_metrics_end_point_url

    #metrics_url : 'https://alpha.21ct.com/api/v1/metrics/recipient/3c094bf6-6307-3939-992e-3604a0d566a3'
    metrics_end_point_url_suffix = get_property('metrics_end_point_url_suffix')

    base_url = get_https_base_url

    metrics_end_pt_url_part = get_metrics_end_pt_url_part

    base_url + URL_PATH_SEPARATOR + metrics_end_pt_url_part + metrics_end_point_url_suffix

  end

  # Returns the part of the url that points to the metrics end point (api/v1/metrics)
  def self.get_metrics_end_pt_url_part

    AutoConfig::METRICS_END_POINT_URL_PART

  end

  # Returns the vertex id of the node which is added on to the graph as a result of expansion
  def self.get_expand_resultant_node_vertex_id

    expand_resultant_node_uid = get_property('expand_resultant_node_uid')
    get_node_vertex_id(expand_resultant_node_uid)

  end

  # Returns the vertex id of the node which is added on to the graph as a result of expansion
  def self.get_expand_resultant_node_vertex_message

    get_property('expand_resultant_node_message')

  end

  # Returns the prefix for the identification of the node on the graph
  # for instance, for the node identified using g.id with the value of
  # 'vertex-a3f6ba9c-919c-3bcf-b626-e7bf2194d685', this prefix is 'vertex-'
  def self.get_node_prefix_on_graph

    node_prefix = AutoConfig::NODE_PREFIX_ON_GRAPH
    #puts "from <#{__method__}, node_prefix read from properties is #{node_prefix}"

    node_prefix

  end

  def self.get_dash_board_url

    base_url = get_https_base_url
    dashboard_url_part = AutoConfig::DASH_BOARD_URL_PART
    dash_board_url = base_url + dashboard_url_part

  end

  def self.get_data_center_url

    base_url = get_https_base_url
    data_center_url_part = AutoConfig::DATA_CENTER_URL_PART
    data_center_url = base_url + data_center_url_part

  end

  def self.get_address_text_to_click_on

    get_property('address_text_to_click_on')

  end

  def self.get_phone_number_text_to_click_on

    get_property('phone_number_text_to_click_on')

  end

  def self.get_tax_id_text_to_click_on

    get_property('tax_id_text_to_click_on')

  end

  def self.get_provider_link_text_to_click_on

    get_property('provider_link_text_to_click_on')

  end


  def self.get_expected_expansion_context_menu_text

    get_property('expected_expansion_context_menu_text')

  end

  def self.get_expected_expansion_result_node_count

  #  TODO Make this extraction code better

    expand_context_menu_text = get_expected_expansion_context_menu_text

    first_split = expand_context_menu_text.split('(')
    puts "first_split: #{first_split}"

    puts "first_split[1]: #{first_split[1]}"

    with_trailing_parantesis = first_split[1]
    puts "with_trailing_parantesis: #{with_trailing_parantesis}"

   expected_expansion_result_node_count = with_trailing_parantesis.split(')')[0]

    puts "expected_expansion_result_node_count: #{expected_expansion_result_node_count}"

    expected_expansion_result_node_count.to_i

  end

  def self.get_profile_tray_section_count

    get_property('profile_tray_section_count')

  end

  def self.get_suffix_node_title

    @properties_file = load_get_properties_file

    get_property('suffix_node_title')

  end

end
