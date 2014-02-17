include Test::Unit::Assertions

require 'watir-webdriver'
require 'yaml'
require 'rbconfig'
require 'watir-scroll'
require 'test/unit'

require_relative 'id_types'
require_relative 'properties_reader'
require_relative 'element_names'
require_relative 'context_menu_items'

class PlaceHolder

  public
    LOGIN_ERROR_MESSAGE = 'Wrong username or password. Try again!'


  # Constant definitions
  DATA_ORIGINAL_TITLE = 'data-original-title'

  #def initialize
  #
  #  @properties_reader = PropertiesReader.new
  #  #@properties_reader = PropertiesReader.new('staging')
  #  #@properties_reader = PropertiesReader.new($cmd_args0_environment)
  #
  #end

  begin

    ON_CLICK_EVENT = 'onclick'

    ON_MOUSE_OVER_EVENT = 'onMouseOver'

  end

  #def assert_main_drop_down_link_exists(message)
  #
  #  main_drop_down_link = get_main_drop_down_link
  #  main_drop_down_link_exists = main_drop_down_link.exists?
  #
  #  assert_equal(true, main_drop_down_link_exists, "main drop down link by id: #{ElementNames::MAIN_DROP_DOWN}")
  #
  #end

  #def get_main_drop_down_link
  #
  #  get_link_by_id(ElementNames::MAIN_DROP_DOWN)
  #
  #end
  #
  #def click_on_main_drop_down_menu
  #
  #  click(get_main_drop_down_link)
  #
  #end

  def click_on_nav_link(message)

    assert_nav_link_exists(message)
    click(get_nav_link)
    sleep(1)

  end

  #Returns the link that collapses the location section in the profile tray
  def get_location_section_collapse_link

    LynxAutoHelper.get_browser_instance.a(:href => /location-section/)

  end

  def get_data_center_link

    LynxAutoHelper.get_browser_instance.a(:href => /datacenter/)
    #LynxAutoHelper.get_browser_instance.a(:text, 'Data Center')

  end

  def expand_node(node_vertex_id, node_message)

    # First make sure the node exists before deleting it (to avoid false alarms with the assertion below).
    # TODO Introduce a boolean argument to the called method as not all the times that method is called is a verification
    assert_node_existence_on_graph(node_vertex_id, true, node_message)

    # Open the context menu
    right_click(get_node_on_graph_by_id(node_vertex_id))

    expansion_context_menu_text = PropertiesReader.get_expected_expansion_context_menu_text
    #expand_context_item = get_link_by_text(expand_recipient_95_context_item, "to context click on on <#{node_message}")
    expand_context_item = get_link(IDTypes::TEXT, expansion_context_menu_text)
    click(expand_context_item)

    sleep(6)

  end

  def delete_node(node_vertex_id, node_message, is_delete_verification)

    # TODO Use the boolean argument 'is_delete_verification' to check if it is a verification of just intermediate check

    # First make sure the node exists before deleting it (to avoid false alarms with the assertion below).
    # TODO Introduce a boolean argument to the called method as not all the times that method is called is a verification
    assert_node_existence_on_graph(node_vertex_id, true, node_message)

    # Open the context menu
    right_click(get_node_on_graph_by_id(node_vertex_id))

    # Click on the context menu item to delete the node
    #del_vertex_context_item = get_link_by_id(ContextMenuItems::VERTEX_DEL_CONTEXT_ID)
    del_vertex_context_item = get_element(ContextMenuItems::VERTEX_DEL_CONTEXT_ID)
    click(del_vertex_context_item)

    # Verify that the node doesn't appear on the graph any more after it was deleted
    assert_node_existence_on_graph(node_vertex_id, false, node_message)

  end

  # Returns the number of nodes that currently appear on the graph
  def get_actual_node_count

    #nodes_by_css_class_count = LynxAutoHelper.get_browser_instance.elements(:css => 'vertex').count
    nodes_by_css_class_count = LynxAutoHelper.get_browser_instance.elements(:css => 'g.vertex').count

    puts "nodes_by_css_class_count: #{nodes_by_css_class_count}"

    nodes_by_css_class_count

  end

  # Asserts the number of nodes on the graph
  def assert_actual_node_count(expected_node_count, message)

    actual_node_count = get_actual_node_count

    assert_equal(expected_node_count, actual_node_count, message)

  end


  # Clicks on the buttons to send the nodes to the graph
  # It doesn't looks for text that specific for 'adding to' or
  # 'viewing' on graph
  # There are two methods that looks for specific text: 'add_to_graph', 'view_on_graph',
  # but if the text on the button is to be asserted, instead of calling the specific
  # method, it is suggested to call the method 'assert_add_to_view_on_graph_btn_text'
  def add_to_or_view_on_graph(message)

    sleep(1)
    click(get_add_to_view_on_graph_button(message))

    #sleep(2)
    sleep(6)

  end

  # Returns the button/link that sends the nodes to the graph
  # @param message this message indicates the scenario in which this button is expected to exists (for instance, "initially on the profile page before the nodes are sent to the graph")
  # Note: This method returns the button despite the text on it (i.e. it doesn't distinguish if the text on the button reads 'View on Graph' or 'Add to Graph')
  # If the caller is particular about the text on the button, specific methods ('get_add_to_graph button' or 'get_view_on_button' (names of these two methods might be different, please check the doc on the methods)) needs to be called.

  def get_add_to_view_on_graph_button(message)

    view_on_or_add_to_graph_btn = get_button_by_class(ElementNames::VIEW_ON_OR_ADD_TO_GRAPH_BTN_CLASS_NAME, message)

  end

  # Asserts the text on the text button/link that sends the nodes to the graph
  # @param message this message indicates the scenario when the expected verification is to be carried out (for instance, "initially on the profile page before the nodes are sent to the graph")
  def assert_add_to_view_on_graph_btn_text(expected_text, message)

    # add to graph or view on graph button
    view_or_add_to_btn_msg = "the text on <#{ElementNames::VIEW_ON_GRAPH_SPAN_TEXT}>/<#{ElementNames::VIEW_ON_GRAPH_SPAN_TEXT}> button/link"
    extended_message = view_or_add_to_btn_msg + '' + message

    view_on_or_add_to_graph_btn = get_add_to_view_on_graph_button(view_or_add_to_btn_msg + '' + message)
    text_on_btn = view_on_or_add_to_graph_btn.text

    assert_message = 'text on the button to send to graph initially on the profile page'
    assert_equal(expected_text, text_on_btn, extended_message)

  end

  def go_to_profiles_view

    click(get_profiles_href_by_text)
    sleep(1)

  end

  # Verifies the first search result (title) is as expected
  def assert_1st_search_result_title

    # Verify the title of the first search result
    first_search_results_text = get_first_search_result_text
    first_search_results_1st_line = first_search_results_text.split("\n").first
    assertion_message = 'First line (title of the profile) in the returned search results'
    assert_equal(PropertiesReader.get_exp_first_search_result_title, first_search_results_1st_line, assertion_message)

  end

  def send_enter_key

    LynxAutoHelper.get_browser_instance.send_keys :enter

  end

  # Returns the div that contains the search results (on results page)
  def get_search_results_body

    LynxAutoHelper.get_browser_instance.div(class: ElementNames::SEARCH_RESULTS_BODY)

  end


  # Verifies the title of the top search suggestion
  def assert_first_suggestion_title

    first_suggestion_text = get_first_suggestion_text
    puts "first_suggestion_text: #{first_suggestion_text}"

    first_suggestion_1st_line = first_suggestion_text.split("\n").first
    puts "first_suggestion_1st_line: #{first_suggestion_1st_line}"

    assertion_message = 'First line (title of the profile) in the returned search suggestions'
    assert_equal(PropertiesReader.get_exp_first_suggestion_title, first_suggestion_1st_line, assertion_message)

  end

  def get_search_suggestion_container

    LynxAutoHelper.get_browser_instance.div(class: ElementNames::RESULT_CONTAINER)

  end

  def browser_go_back

    LynxAutoHelper.get_browser_instance.back
    sleep(1)

  end

  def browser_go_back_assert_url(expected_back_url, assert_fail_message)

    browser_go_back
    sleep(1)
    assert_actual_url(expected_back_url, assert_fail_message)

  end

  def get_span_by_text(text_on_span)

    LynxAutoHelper.get_browser_instance.span(text: text_on_span)

  end


  # Clicks on 'Add to Graph' span
  # This method looks for the span by the expected text
  # If the text on the button doesn't matter. then call the method
  # 'add_to_or_view_on_graph' button
  def add_to_graph(message="button: #{ElementNames::ADD_TO_GRAPH_SPAN_TEXT}")

    sleep(1)
    # Click on the link to add the nodes to the graph
    click(get_add_to_graph_span(message))
    sleep(2)

  end

  def get_view_on_graph_span

    get_span_by_text(ElementNames::VIEW_ON_GRAPH_SPAN_TEXT)

  end

  # Clicks on 'View on Graph' span
  # This method looks for the span by the expected text
  # If the text on the button doesn't matter. then call the method
  # 'add_to_or_view_on_graph' button
  def view_on_graph

    sleep(1)

    # Click on the link to add the nodes to the graph
    click(get_view_on_graph_span)

    sleep(2)

  end

  # Returns the arrow that collapses and expands the graph controls
  def get_collapse_expand_arrow

    LynxAutoHelper.get_browser_instance.a(class: ElementNames::COLLAPSE_EXPAND_ARROW_CLASS_NAME)

  end

  # Does the following:
  # a) Navigates to a different profile by clicking on the hyperlink declared as span identified using the text and
  # b) Verifies the navigation to the expected URL
  def nav_via_hyperlink_assert_url(text_on_span, exp_dest_url, assert_fail_message)

    # Click on the span identified by the text on it
    get_span_by_text(text_on_span).click
    sleep(1)

    assert_actual_url(exp_dest_url, assert_fail_message)

  end

  def right_click(element)

    element.right_click
    sleep(2)

  end

  def get_add_to_graph_span(message)

    #get_button_by_class(ElementNames::ADD_TO_GRAPH_SPAN_TEXT, message)
    get_span_by_text(ElementNames::ADD_TO_GRAPH_SPAN_TEXT)

  end

  def click(element, message = '')

    assert_exists_visible(element, "requested to be clicked on #{message}")

    element.click

    sleep(1)

  end

  def get_node_on_graph_by_id(node_id)

    LynxAutoHelper.get_browser_instance.g(id: node_id)

  end

  # TODO Introduce a boolean argument to this method as not all the times that this method is called is a verification
  # For instance, from the 'delete_node' method,
  def assert_node_existence_on_graph(vertex_id, expected_to_exist, message)

    # TODO Make sure the node_id received is not null
    node_by_id = get_node_on_graph_by_id(vertex_id)
    node_exists = node_by_id.exists?

    assert_equal(expected_to_exist, node_exists, "Existence of the node with the given id: #{vertex_id} for '#{message}' is not as expected on the graph")

  end


  # Returns the text displayed on the first suggestion (returns multiple lines when applicable)
  def get_first_suggestion_text

    # TODO make sure the return value of the called method is not nil before calling the 'text' method on it
    get_first_suggestion_div.text

  end

  # Clicks on the span identified using the text on in
  def click_on_span_by_text(text_on_span)

    sleep(1)
    click(get_span_by_text(text_on_span))
    #sleep(1)
    sleep(2)

  end

  # Returns the first Div element in the suggestions container
  # TODO AS there are multiple divs that are given the same class name, this method uses the fact specifying the div class name returns the first one of all the UI elements/components that can be recognized, but this can be improved by retuning the one at index 0
  def get_first_search_results_div

    # When the page first loads, if this sleep statement is not there, when the 'text' method is called on this element, it may not get the expected text, might get something like the profile type as noticed earlier, as that is the text displayed prior to the titles of the test results
    sleep(1)

    LynxAutoHelper.get_browser_instance.div(class: ElementNames::SEARCH_RESULT_ROW_DIV_CLASS_NAME)

  end

  # Returns the first Div element in the suggestions container
  # TODO AS there are multiple divs that are given the same class name, this method uses the fact specifying the div class name returns the first one of all the UI elements/components that can be recognized, but this can be improved by retuning the one at index 0
  def get_first_suggestion_div

    LynxAutoHelper.get_browser_instance.div(class: ElementNames::SUGGESTION_ROW_DIV_CLASS_NAME)

  end

  # Returns the text displayed on the first suggestion (returns multiple lines when applicable)
  def get_first_search_result_text

    # TODO make sure the return value of the called method is not nil before calling the 'text' method on it
    get_first_search_results_div.text

  end

  # Logs in to the application and goes to the profile using the URL given and verifies the profile page
  def login_and_assert_profile(profile_url)

    # Login and go the profile whose URL is given
    login_goto_profile(profile_url)

    # Verify the contents of the profile page
    assert_profile(profile_url)

  end

  # Asserts the common sections/divs that apply to all the profile types
  # For instance, score_card, profile_content_card..etc that appear on
  # all the profile page for all the profile types.
  # Assumes that the user is already logged in and the profile to verify is already loaded
  def assert_profile(profile_url)

    # Determine the profile type using the url
    profile_type = get_profile_type_from_url(profile_url)

    # profile type: 'Case' does not have score card, so skip this verification for that profile
    unless profile_type.to_s == ElementNames::CASE_PROFILE_AS_IN_URL

      # Verify that the top panel where the profile info is displayed exists
      assert_score_card_exists

    end

    # Verify that the profile summary header exists
    assert_profile_summary_hr_exists

    # Verify the profile icon appears
    assert_profile_icon_exists(profile_url)

  end

  # Verifies that the number of profile types suggested (container count) matches the number of suggested profile types expected
  def assert_suggestion_container_count(exp_suggestion_container_count)

    actual_result_container_count = get_results_container_count

    puts "actual_result_container_count: #{actual_result_container_count}"
    assert_message = 'Number of (profile types) sets of suggestions'
    assert_equal(exp_suggestion_container_count, actual_result_container_count, assert_message)

  end

  # Verifies that the top panel where the profile info is displayed exists
  def assert_score_card_exists

    score_card_content_div_exists = get_div_by_id(ElementNames::SCORE_CARD_CONTENT_DIV_ID).exists?
    assert_message = 'Existence of score card that is expected to contain the information about the profile'
    assert_equal(true, score_card_content_div_exists, assert_message)

  end

  def get_div_by_id(div_id)

    #LynxAutoHelper.get_browser_instance.div(id: div_id)

    generic_element = LynxAutoHelper.get_browser_instance.element(:css => "[id=#{div_id}]")

    generic_element.to_subtype

  end

  def get_header_by_id(header_id)

    LynxAutoHelper.get_browser_instance.header(header_id)

  end

  def get_profile_summary_header

    #LynxAutoHelper.get_browser_instance.header(id: ElementNames::PROFILE_SUMMARY)
    get_header_by_id(id: ElementNames::PROFILE_SUMMARY)

  end

  # Verifies that the profile summary header exists
  def assert_profile_summary_hr_exists

    profile_summary_header_exists = get_profile_summary_header.exists?
    assert_message = "Existence of the header with id: #{ElementNames::PROFILE_SUMMARY} that is expected to contain the profile summary"
    assert_equal(true, profile_summary_header_exists, )

    # TODO Verify the child count of the profile summary header to make sure it is not empty

  end

  # Logs in to the application and goes to the profile using the URL given
  def login_goto_profile(profile_url)

    login_with_proper_credentials

    # Access the given profile using its URL
    go_to(profile_url)

    sleep(1)

  end


  # Returns the profile type that is part of the given profile URL
  # This method is written to use the profile url, if this needs to be extended to use with graph url (i.e. instead of 'profile' (for instance, 'graph') in the begin delimiter, this method can be updated to take a parameter)
  def get_profile_type_from_url(profile_url)

    # extract the string until the end of the begin delimiter (i.e from the beginning of the profile type) all the way till the end of the profile URL
    str_prior_to_profile_type = profile_url.split(AutoConfig::PROFILE_TYPE_BEGIN_DELIM)[1]

    # Extract and return the string that represents the profile type in the URL
    str_prior_to_profile_type.split(AutoConfig::PROFILE_TYPE_END_DELIM)[0]

  end

  # Returns the expected name of the profile icon using the URl
  def get_profile_icon_name(profile_url)

    # TODO Handle invalid key (which returns in 'Nil')va to give the list of profile types
    # Profile type exists as part of the URL between specific delimiters
    profile_type = get_profile_type_from_url(profile_url)

    # Get the suffix of the icon using the profile type
    profile_icon_name_suffix = ElementNames::ICON_SUFFIXES[profile_type]

    # Return the string that is used to identity the icon (prefix is common to all the profiles and only the suffix changes depending on the profile type)
    ElementNames::ICON_NAME_PREFIX + profile_icon_name_suffix

  end

  # Verifies that the icon for the given profile exists under profile summary (not just that it appears somewhere on the page )
  def assert_profile_icon_exists(profile_url)

    # Determine the profile type using the given URL
    profile_type = get_profile_type_from_url(profile_url)

    # Determine the name of the icon using the profile type
    profile_icon_name = get_profile_icon_name(profile_url)

    # To make sure the icon appears under profile summary and not just anywhere on the page, use the parent
    #profile_icon_exists = LynxAutoHelper.get_browser_instance.span(class: profile_icon_name).exists?
    profile_summary_header = get_profile_summary_header
    profile_icon_exists = profile_summary_header.span(class: profile_icon_name).exists?
    assert_equal(true, profile_icon_exists, "Existence of the profile icon as span with class: <#{profile_icon_name}> for <#{profile_type}> profile")

  end

  # Prints the HTML contents of the current page
  def print_html_contents

    browser_html = LynxAutoHelper.get_browser_instance.html
    puts "\n\n****** HTML contents of the current page follow \n #{browser_html}"

  end


  # clicks on the link whose a id is given
  # As onclick event is not automatically fired by clicking the link, this method
  # takes care of firing that event
  def click_on_a_link(link_id)

    link_using_id = get_link_by_id(link_id)

    ensure_link_exists(link_id)

    link_using_id.click

    # With logout button, it is noted that clicking on it doesn't cause the
    # 'onclick' event to be automatically fired, so having to explicitly fire the event
    link_using_id.fire_event(ON_CLICK_EVENT)

    sleep(1)

  end

  # Attempts to sign out using the gear navigational tool bar
  # Assumes that the user is logged in
  def logout_using_gear_icon

    mouse_over_link(ElementNames::TOOLS_GEAR_ICON)

    click_on_a_link(ElementNames::LOGOUT_HREF_ID)

    sleep(2)

  end

  def assert_actual_url(expected_url, failure_message)

    @actual_url = LynxAutoHelper.get_browser_instance.url

    assert_equal(expected_url, @actual_url, failure_message)

  end

  def go_to(url)

    puts "url: #{url}"

    LynxAutoHelper.get_browser_instance.goto url

    sleep(1)
  end


  # Clicks on the button whose id is given. First checks if the button exists and enabled
  def click_on_button(button_id)

    given_button = get_button_by_id(button_id)

    current_url = LynxAutoHelper.get_browser_instance.url

    unless given_button.exists?
      raise "The button whose id given is: #{button_id} is not enabled on the browser page: #{current_url}"
    end

    unless given_button.enabled?
      raise "The button whose id given is: #{button_id} is not enabled on the browser page: #{current_url}"
    end

    #given_button.wait_until_present(2)

    given_button.click

    sleep(1)
  end

  # Enters the users id and password, clicks on the submit button and waits for a second
  def login_with_proper_credentials

    valid_user_name = PropertiesReader.get_user_name
    valid_password =  PropertiesReader.get_password

    set_text(ElementNames::USERNAME_TEXTFIELD_NAME, valid_user_name)

    set_text(ElementNames::PASSWORD_TEXTFIELD_NAME, valid_password)

    click_on_button(ElementNames::SUBMIT_BUTTON_ID)

  end

  # Fires the onMouseOver event for the link whose id is given
  def mouse_over_link(link_id)

    link_using_id = get_link_by_id(link_id)

    link_using_id.fire_event ON_MOUSE_OVER_EVENT

  end

  # Checks if the link using the given id exists and if not, throws an error.
  # Called by the method that need to make sure the element exists because attempting
  # to perform operations on it, such as clicking
  def ensure_link_exists(link_id)

    link_exists = get_link_by_id(link_id).exists?

    # Make sure the link exists, throw an error if it doesn't
    unless link_exists

      current_url = LynxAutoHelper.get_browser_instance.url
      raise "The link whose id given is: <#{link_id}> doesn't exist on the page: <#{current_url}>"

    end

  end

  def get_link(id_type, value_of_id)

    LynxAutoHelper.get_browser_instance.a(id_type, value_of_id)

  end

  def get_link_by_text(link_text, message)

    LynxAutoHelper.get_browser_instance.a(text: link_text)

  end

  def get_link_by_class(link_class_name)

    LynxAutoHelper.get_browser_instance.a(class: link_class_name)

    #LynxAutoHelper.get_browser_instance.element(:css => "[class=#{link_class_name}]")
  end

  def get_link_by_id(link_id)

    #LynxAutoHelper.get_browser_instance.a(id: link_id)

    #LynxAutoHelper.get_browser_instance.a(id: link_id)
    LynxAutoHelper.get_browser_instance.element(:css => "[id=#{link_id}]")

  end

  def get_element(element_id)

    LynxAutoHelper.get_browser_instance.element(:css => "[id=#{element_id}]")

  end

  # As 'enabled?' method is not available for some elements such as anchors, enabled check is performed by a separate method and this method server the common purpose for all the emelemts
  def assert_exists_visible(element, message)

    # TODO take parameters for fast_fail
    current_url = LynxAutoHelper.get_browser_instance.url

    element_exists = element.exists?

    puts "From 'assert_exists_visible method, for #{message}, element_exists: #{element_exists}"
    #begin
    assert_equal(true, element_exists, "Existence of the element #{message} on the browser page: #{current_url}")
    #rescue MiniTest::Assertion => mta
    #  puts mta.message
    #  puts mta.backtrace
    #end

    #begin
    element_visible = element.visible?
    assert_equal(true, element_visible, "Visible setting of the element #{message} on the browser page: #{current_url}")
    #rescue MiniTest::Assertion => mta
    #  puts mta.message
    #  puts mta.backtrace
    #end

  end

  def assert_enabled(element, message)

    current_url = LynxAutoHelper.get_browser_instance.url

    element_enabled = element.enabled?
    assert_equal(true, element_enabled, "The element: #{message} is not enabled on the browser page: #{current_url}")

  end

  def assert_button_exists_enabled(button_id)

    given_button = get_button_by_id(button_id)

    current_url = LynxAutoHelper.get_browser_instance.url

    button_exists = given_button.exist?
    assert_message = "Existence of the element #{message} whose id given is: #{button_id} on the browser page: #{current_url}"
    assert_equal(true, button_exists, assert_message)

    button_enabled = given_button.enabled?
    assert_message = "The button whose id given is: #{button_id} is not enabled on the browser page: #{current_url}"
    assert_equal(true, button_enabled, assert_message)

  end



  def enter_search_text(text_to_set)

    search_text_field = LynxAutoHelper.get_browser_instance.text_field(class: "#{ElementNames::SEARCH_TEXT_FIELD_CLASS_NAME}")

    search_text_field.wait_until_present(2)
    search_text_field.set(text_to_set)

    #sleep(1)
    sleep(5)

  end

  # Sets the text in the text field whose name is given
  # @param [String] text_field_name of the text field used for identification
  # @param [String] value_to_set
  def set_text(text_field_name, value_to_set)

    # TODO Make sure the value to set received is not null
    given_text_field = LynxAutoHelper.get_browser_instance.text_field(name: "#{text_field_name}")

    given_text_field.wait_until_present(3)
    given_text_field.set value_to_set

    #Make sure the value set is retained in the text field
    begin
      value_after_set = given_text_field.value

      if value_after_set != value_to_set
        raise "The attempt to set the text: #{value_to_set} in the text field #{text_field_name} was not successful. The text field now contains: <#{value_after_set}>"
      end
    end

  end

  def get_button_by_id(button_id)

    LynxAutoHelper.get_browser_instance.button(id: button_id)

  end

  def get_button_by_class(button_class_name, message)

    button_by_class = LynxAutoHelper.get_browser_instance.button(class: "#{button_class_name}")
    assert_exists_visible(button_by_class, message)

    button_by_class

  end

  # Returns the number of results that are returned (i.e. number of profile types found as there would be once results container for each profile)
  def get_results_container_count

    results_containers = LynxAutoHelper.get_browser_instance.divs(class: ElementNames::RESULT_CONTAINER)

    results_containers.count

  end


  # Verifies the existence of link to the data center
  def assert_data_ctr_link_exists(message)

    # As the data center link is not visible unless the navigation link is clicked on, first click on it
    assert_nav_link_exists(message)
    click(get_nav_link)
    data_center_link = get_data_center_link

    data_center_link_exists = data_center_link.exists?
    assert_equal(true, data_center_link_exists, 'existence of the navigation link ' + message)

  end

  def get_ul_by_id(id)

    LynxAutoHelper.get_browser_instance.ul(id: id)


  end

  # Returns the navigation menu on the top left corner that contains the link for the data center
  def get_nav_link

    get_ul_by_id(ElementNames::NAV_MENU_UL_ID)

  end

  def assert_nav_link_exists(message)

    nav_link = get_nav_link
    nav_link_exists = nav_link.exists?
    assert_equal(true, nav_link_exists, "navigation link (ul) with id: #{ElementNames::NAV_MENU_UL_ID} #{message}")


  end

  # Verifies that the attempt to access the site via HTTP redirects to HTTPS
  def test_http_redirects_to_https

    assert_actual_url(PropertiesReader.get_exp_https_login_url, 'not redirected to HTTPS login when the site is accessed via HTTP')

  end


  def go_to_data_center(message)

    click_on_nav_link(message)

    click(get_data_center_link)

  end

  def assert_nav_data_ctr_links_exist(message)

    ## Verify on the profile page that the navigation menu (that contains the link to the data center) exists
    #assert_nav_link_exists("from the profile page of the provider: #{@provider_node_message}")
    #
    ## Verify on the profile page that the link to the data center exists
    #assert_data_ctr_link_exists("from the profile page of the provider: #{@provider_node_message}")

    assert_nav_link_exists("from the profile page of the provider: #{@provider_node_message}")

    assert_data_ctr_link_exists(message)

  end
  #
  #def assert_main_drop_down_data_ctr_links_exist(message)
  #
  #  ## Verify on the profile page that the navigation menu (that contains the link to the data center) exists
  #
  #  ## Verify on the profile page that the link to the data center exists
  #  assert_main_drop_down_link_exists(message)
  #
  #  assert_data_ctr_link_exists(message)
  #
  #end


  # Verifies that the divs that are expected (4 divs as seen for the selected
  # profile)
  def assert_divs_exist_on_data_center(message)

    # TODO These need to be moved to the properties file in the form of data structure (so can be iterated)
    # TODO Write a generic e a method to read multiple values from the properties file (for instance, using a delimiter that is not expected to be part of the values )
    #

    assert_div_by_id_existence('provider_stats', true, 'after navigating to the data center')

    assert_div_by_id_existence('recipient_stats', true, 'after navigating to the data center')

    assert_div_by_id_existence('additional_stats', true, 'after navigating to the data center')

    assert_div_by_id_existence('claim_stats', true, 'after navigating to the data center')

  end

  # Sets the given text into the global search text field
  def set_global_search_term(search_term)

    global_search_text_field = get_global_search_text_field

    # Frame work method: 'set_text' doesn't apply to this as that waits for the text field with the given name, but the identification of this text field is different (in that it uses its parent to make sure that the one in use is in the expected place/parent)
    global_search_text_field.set search_term
    #sleep(2)

    sleep(5)
  end


  # Verifies the number of sections listed in the profile tray
  def assert_profile_tray_section_count(expected_section_count, message)

    type_section_headers = LynxAutoHelper.get_browser_instance.divs(class: 'type-section-header')
    type_section_header_count = type_section_headers.count

    assert_equal(expected_section_count, type_section_header_count, "the number of section headers expected  #{}")

  end

  def get_profile_tray_section

    LynxAutoHelper.get_browser_instance.section(id: 'profile-tray')

  end

  def assert_profile_tray_section_exists(message)

    profile_tray_section_exists = get_profile_tray_section.exists?

    puts "profile_tray_section_exists: #{profile_tray_section_exists}"
    assert_equal(true, profile_tray_section_exists, "existence of profile tray section #{message}")

  end


  def get_profile_tray_expand_link

    # TODO move to ElementsUtil
    #get_link_by_class('profile-tray-thumb ng-scope lynx-icon-arrowexpand')
    # TODO Update test as it is expecting that the value used is: 'profile-tray-thumb ng-scope lynx-icon-arrowexpand'
    #get_link_by_class('profile-tray-thumb ng-scope lynx-icon-arrowexpand')

    #TODO Use the following way to avoid ng-scope (test uses arrowexapnd and collapse to decide its status so test needs to be updated )
    get_link_by_class(/profile-tray-thumb/)

  end

  def get_profile_tray_collapse_link

    # TODO move to ElementsUtil
    get_link_by_class('profile-tray-thumb ng-scope lynx-icon-arrowcollapse')

  end

  def assert_profile_tray_expand_link_exists(message)

    profile_tray_expand_link_exists = get_profile_tray_expand_link.exists?

    #puts "profile_tray_expand_link_exists: #{profile_tray_expand_link_exists}"

    assert_equal(true, profile_tray_expand_link_exists, "existence of profile tray expand link #{message}")

  end

  def assert_profile_tray_collapse_link_exists(message)

    profile_tray_collapse_link_exists = get_profile_tray_collapse_link.exists?

    #puts "profile_tray_collapse_link_exists: #{profile_tray_collapse_link_exists}"

    assert_equal(true, profile_tray_collapse_link_exists, "existence of profile tray collapse link #{message}")

  end

  def expand_profile_tray

    profile_tray_expand_link = get_profile_tray_expand_link
    click(profile_tray_expand_link)

  end

  def collapse_profile_tray

    profile_tray_collapse_link = get_profile_tray_collapse_link
    click(profile_tray_collapse_link)

  end


  def assert_div_by_id_existence(div_id, expected_to_exist, assert_message = '')

    div_by_id = get_div_by_id(div_id)
    div_by_id_exists = div_by_id.exists?

    puts "div_by_id_exists for id: #{div_id}:  #{div_by_id_exists}"

    assert_equal(expected_to_exist, div_by_id_exists, "existence of the div whose id is: <#{div_id}> #{assert_message}")

  end

  def get_global_search_container

    get_ul_by_id('global-search-container')

  end

  def get_global_search_text_field

    global_search_container = get_global_search_container

    #  TODO Make sure the parent exists before attempting to find the search text filed
    # unless global_search_container.exists?

    global_search_container.text_field(id: ElementNames::GLOBAL_SEARCH_TEXT_FIELD_ID)

  end

  def assert_global_search_field_exists(message)

    global_search_text_field = get_global_search_text_field
    global_search_field_exists = global_search_text_field.exists?

    assert_equal(true, global_search_field_exists, "existence of the global text field #{message}")

  end

  # Asserts that the expected nodes for the provider are on the graph
  # Prerequisite: Graph should already be displayed (i.e. current perspective should be Graph view)
  # TODO Take boolean argument to check if it is an intermediate check or a functional verification
  # TODO add a parameter to take message (for instance, 'before expanding the node' or 'after the node is expanded to verify that expansion didn't messa up the existing nodes on the graph')
  def assert_nodes_on_provider_graph

    assert_node_existence_on_graph(PropertiesReader.get_location1_node_vertex_id, true, PropertiesReader.get_location1_node_message)

    assert_node_existence_on_graph(PropertiesReader.get_suffix_node_vertex_id, true, PropertiesReader.get_suffix_node_message)

    assert_node_existence_on_graph(PropertiesReader.get_location2_node_vertex_id, true, PropertiesReader.get_location2_node_message)

    assert_node_existence_on_graph(PropertiesReader.get_tax_id_node_vertex_id, true, PropertiesReader.get_tax_id_node_message)

    assert_node_existence_on_graph(PropertiesReader.get_provider_node_vertex_id, true, PropertiesReader.get_provider_node_message)

    assert_node_existence_on_graph(PropertiesReader.get_npi_node_vertex_id, true, PropertiesReader.get_npi_node_message)

    assert_node_existence_on_graph(PropertiesReader.get_phone_node_vertex_id, true, PropertiesReader.get_phone_node_message)

  end

  # Returns the link that navigates to the profile view
  def get_profiles_href_by_text

    profile_href_text = ElementNames::PROFILES_HREF_TEXT
    puts "profile_href_text is: #{profile_href_text}"

    LynxAutoHelper.get_browser_instance.a(text: profile_href_text)

  end


  # TODO The ultimate goal is to have simplified getters for elements as given below
  def get_pan_zoom_element

    get_element(ElementNames::PAN_ZOOM_BUTTON_ID)

  end

  def get_multi_select_element

    get_element(ElementNames::MULTI_SELECT_BUTTON_ID)

  end

  def get_zoom_to_fit_element

    get_element(ElementNames::ZOOM_TO_FIT_BUTTON_ID)

  end



end