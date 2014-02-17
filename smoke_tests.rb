require 'test/unit'
require 'watir-webdriver'
require 'yaml'
require 'rbconfig'
require 'watir-scroll'

require_relative 'id_types'
require_relative 'properties_reader'
require_relative 'element_names'
require_relative 'place_holder'

# test-unit treats the command line arguments differently than is expected (as mentioned at: http://stackoverflow.com/questions/18929452/block-in-non-options-file-not-found-argumenterror)
# so the work around is to save the command line arguments before test-unit takes over
$cmd_args0_environment = ARGV[0]
ARGV[0] = nil

class SmokeTests < Test::Unit::TestCase

  # Called before every test method runs.
  # To avoid side affects of one test caused by the previous test,
  # browser is started at the beginning of each test and closed
  # after the test ends
  def setup

    LynxAutoHelper.set_execution_environment('qa')
    #LynxAutoHelper.set_execution_environment($cmd_args0_environment)

    $browser = Watir::Browser.new :chrome

    LynxAutoHelper.set_browser_instance($browser)
    @place_holder = PlaceHolder.new

    $browser.cookies.clear

    # TODO Clear browser cache

    set_commonly_used_variables

    https_base_url = PropertiesReader.get_https_base_url
    @place_holder.go_to(https_base_url)

  end

  # Called after every test method runs. Closes the browser.
  def teardown

    # Close the browser unless there was an error in the setup which caused $browser to not get initialized
    unless $browser.nil?

      $browser.close

    end

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2240
  # Verify that adding the nodes on graph from the profile page adds all the expected nodes on to the graph
  def test_nodes_added_to_graph

    @place_holder.login_goto_profile(@provider_url)

    # Click on the link to add the nodes to the graph
    @place_holder.add_to_graph

    # Verify that the expected nodes for the provider are on the graph
    # Until there is
    #@place_holder.assert_nodes_on_provider_graph

    # Verify that the node count on the graph matches
    message = "node count when they are sent to the graph initially from the profile of #{@provider_node_message}"
    @place_holder.assert_actual_node_count(PropertiesReader.get_expected_initial_node_count, message)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2523
  # Verifies that the graph controls such as 'zoom to fit' exist and their 'visible' property is set to true
  # (does not mean they are physically visible, i.e. even though their visible property is set to true, if the parent is collapsed, they will not physically appear)
  # TODO Verifying that clicking on the graph controls (zoom, pan..etc) work as expected require support in the product code and Martin is willing provide that support, Lalita will discuss the options with him. This may not be implemented before LA.
  # JIRA ticket: http://lynxjira.21technologies.com/jira/browse/THREE-1755 was created under 3x for dev to add the support for automation
  # Ticket to be created under QA project to update the test after the above issue was resolved
  def test_graph_controls

    @place_holder.login_goto_profile(PropertiesReader.get_provider_profile_url)

    @place_holder.add_to_graph

    # Verify that the following buttons/links exist and its visibility property is set to true (doesn't mean it physically is visible, i.e. even though its visible property is set to true, if its parent is collapsed, it will nto physically appear)
    # This was removed http://lynx-app02/jira/browse/THREE-1409 (From JIRA: 'The collapse / expand control on the toolbar shall be removed')
    # assert_exists_visible(get_collapse_expand_arrow, 'handle for expanding and collapsing the graph controls')

    #@place_holder.assert_exists_visible(@place_holder.get_link_by_id(ElementNames::PAN_ZOOM_BUTTON_ID), 'on the graph right after the nodes are initially added')
    #
    #@place_holder.assert_exists_visible(@place_holder.get_link_by_id(ElementNames::MULTI_SELECT_BUTTON_ID), 'on the graph right after the nodes are initially added')
    #
    #@place_holder.assert_exists_visible(@place_holder.get_link_by_id(ElementNames::ZOOM_TO_FIT_BUTTON_ID), 'on the graph right after the nodes are initially added')

    @place_holder.assert_exists_visible(@place_holder.get_pan_zoom_element, 'on the graph right after the nodes are initially added')

    @place_holder.assert_exists_visible(@place_holder.get_multi_select_element, 'on the graph right after the nodes are initially added')

    @place_holder.assert_exists_visible(@place_holder.get_zoom_to_fit_element, 'on the graph right after the nodes are initially added')

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2836
  # Verifies deleting the profile node itself and switching back to the graph view adds the profile node back to the graph
  # Verifies that the text on the button reads 'Add to Graph' after the profile node is deleted from the graph
  def test_del_profile_node_add_back

    provider_profile_url = PropertiesReader.get_provider_profile_url
    @place_holder.login_goto_profile(provider_profile_url)

    # Switch the perspective to 'Graph'
    @place_holder.add_to_graph

    provider_node_vertex_id  =   PropertiesReader.get_provider_node_vertex_id
    provider_node_message    =   PropertiesReader.get_provider_node_message

    # Delete the profile node
    @place_holder.delete_node(provider_node_vertex_id, provider_node_message, true)

    # Switch the perspective to 'Profiles'
    @place_holder.go_to_profiles_view

    # Verify the text on the button reads 'Add to Graph' (indicating that the profile node is not on the graph) after it is deleted from the graph
    assert_message = 'to indicate that the profile node is not on the graph after it is deleted from the graph and view is switched to Profiles'
    @place_holder.assert_add_to_view_on_graph_btn_text(ElementNames::ADD_TO_GRAPH_SPAN_TEXT, assert_message)

    # Switch the perspective to 'Graph'
    @place_holder.add_to_or_view_on_graph('to add the profile node back to the graph after it was deleted')

    # Verify that the provider node is added back to the graph after it was deleted and then switched to the Profile view and then back to the graph view
    assert_message = "Profile node: <#{provider_node_message}> is added back to the graph after it was deleted and then view is switched to the 'Profiles' and clicked on <#{ElementNames::ADD_TO_GRAPH_SPAN_TEXT}> after this node was deleted from the graph"
    @place_holder.assert_node_existence_on_graph(provider_node_vertex_id, true, assert_message)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2841
  # Verifies deleting the suffix node and switching between profiles cause the deleted node to stay deleted
  # Verifies the text on the button that sends nodes to the graph before (expected 'Add to Graph') and
  # after ('View on Graph')adding the nodes to the graph
  def test_del_suffix_node

    @place_holder.login_goto_profile(@provider_url)

    # Verify the text on the button initially. This will be a fast fail assertion
    assert_message = 'initially on the profile page (before nodes are sent to graph'
    @place_holder.assert_add_to_view_on_graph_btn_text(ElementNames::ADD_TO_GRAPH_SPAN_TEXT, assert_message)

    # Switch the perspective to 'Graph'
    @place_holder.add_to_or_view_on_graph('initially from the profile view when the nodes are not yet added to the graph')

    # Delete a single (suffix) node
    begin

      # Delete suffix node
      suffix_node_vertex_id = PropertiesReader.get_suffix_node_vertex_id
      suffix_node_message = PropertiesReader.get_suffix_node_message
      @place_holder.delete_node(suffix_node_vertex_id, suffix_node_message, true)

    end

    # Switch the perspective to 'Profiles'
    @place_holder.go_to_profiles_view

    # Verify the text on the button after the view is switched back to 'Profiles' from graph. This will be a fast fail assertion
    assert_message = "after the view is switched back to 'Profiles' from graph after non-profile nodes are deleted from the graph"
    @place_holder.assert_add_to_view_on_graph_btn_text(ElementNames::VIEW_ON_GRAPH_SPAN_TEXT, assert_message)

    #view_on_graph
    @place_holder.add_to_or_view_on_graph("after switching back to 'Profiles' view after the nodes are deleted from the graph")

    # Verify that the deleted suffix node stays deleted
    begin

      # Verify that the Suffix node stays deleted on the graph after it was deleted and perspective is switched to 'Profiles' and then back to the graph perspective
      assert_message = "The existence/persistence of the deleted (non-profile) node <#{suffix_node_message}> after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
      @place_holder.assert_node_existence_on_graph(suffix_node_vertex_id, false, assert_message)

    end

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2504
  # When multiple nodes (excluding the profile node itself) are deleted, switching back and forth from different perspectives
  # retain the status of the graph i.e. nodes stay deleted (deleting the profile node itself is a different scenario,
  # which is covered in a different test as the flow is different)
  def test_del_multiple_non_profile_nodes

    @place_holder.login_goto_profile(@provider_url)

    # Switch the perspective to 'Graph'
    @place_holder.add_to_or_view_on_graph('initially form the profile view when the nodes are not yet added to the graph')

    # Delete multiple nodes
    begin

      # Delete NPI node
      npi_node_vertex_id = PropertiesReader.get_npi_node_vertex_id
      npi_node_message = PropertiesReader.get_npi_node_message
      @place_holder.delete_node(npi_node_vertex_id, npi_node_message, true)

      # Delete location node
      location1_node_vertex_id = PropertiesReader.get_location1_node_vertex_id
      location1_node_message = PropertiesReader.get_location1_node_message
      @place_holder.delete_node(location1_node_vertex_id, location1_node_message, true)

      # Until dependency on uids is reduced, these two nodes are excluded
      begin
        ## Delete phone node
        #phone_node_vertex_id = PropertiesReader.get_phone_node_vertex_id
        #phone_node_message = PropertiesReader.get_phone_node_message
        #@place_holder.delete_node(phone_node_vertex_id, phone_node_message, true)
        #
        ## Delete tax_id node
        #tax_id_node_vertex_id = PropertiesReader.get_tax_id_node_vertex_id
        #tax_id_node_message = PropertiesReader.get_tax_id_node_message
        #@place_holder.delete_node(tax_id_node_vertex_id, tax_id_node_message, true)

      end
    end

    # Switch the perspective to 'Profiles'
    @place_holder.go_to_profiles_view

    # Switch back to the graph view
    @place_holder.add_to_or_view_on_graph("after switching back to 'Profiles' view after the nodes are deleted from the graph")

    # Verify that all the deleted nodes stay deleted
    begin

      # Verify that the NPI node stays deleted (i.e. doesn't appear back on the graph) after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
      assert_message = "The existence/persistence of the deleted (non-profile) node <#{npi_node_message}> after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
      @place_holder.assert_node_existence_on_graph(npi_node_vertex_id, false, assert_message)

      # Verify that the location node stays deleted (i.e. doesn't appear back on the graph) after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
      assert_message = "The existence/persistence of the deleted (non-profile) node <#{location1_node_message}> after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
      @place_holder.assert_node_existence_on_graph(location1_node_vertex_id, false, assert_message)

      # Until dependency on uids is reduced, these two nodes are excluded
      begin
        ## Verify that the tax_id node stays deleted (i.e. doesn't appear back on the graph) after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
        #assert_message = "The existence/persistence of the deleted (non-profile) node <#{tax_id_node_message}> after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
        #@place_holder.assert_node_existence_on_graph(tax_id_node_vertex_id, false, assert_message)
        #
        ## Verify that the phone node stays deleted (i.e. doesn't appear back on the graph) after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
        #assert_message = "The existence/persistence of the deleted (non-profile) node <#{phone_node_message}> after it was deleted and the view is switched to 'Profiles' view and then back to the graph view"
        #@place_holder.assert_node_existence_on_graph(phone_node_vertex_id, false, assert_message)
      end

    end

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2608
  # Verifies that
  #   The profile tray expand control exists initially right after switching to profile view from graph
  #   Clicking on this control opens the profile tray
  #   The control changes to the collapse control once the tray is opened
  #   Number of sections headers in the profile tray is as expected
  #   All the expected headers exist
  def test_profile_tray

    @place_holder.login_goto_profile(@provider_url)

    # Send to graph
    @place_holder.add_to_or_view_on_graph('initially from the profile view')

    @place_holder.go_to_profiles_view

    # Verify that initially that the link that expands the profile tray exists
    @place_holder.assert_profile_tray_expand_link_exists('initially in profile view right after switching to profile view from graph')

    @place_holder.expand_profile_tray

    # Verify that the main section that contains the entire profile tray is displayed
    @place_holder.assert_profile_tray_section_exists('after clicking on the control to expand the profile tray')

    # Verify that the link that collapses the profile tray exists when the tray is expanded
    @place_holder.assert_profile_tray_collapse_link_exists('after profile tray was opened')

    # Verify the count and names of the sections in profile tray match the expected
    begin

    # If a data structure is used, this count constant can be eliminated (by using the 'length' or 'size' method)
      # profile_tray_section_count = 5
      profile_tray_section_count = PropertiesReader.get_profile_tray_section_count

    # Verify the number of sections in the profile tray
    @place_holder.assert_profile_tray_section_count(profile_tray_section_count, 'after the profile tray is expanded when the graph is not altered (i.e. no nodes added/deleted/expanded..etc')

      # TODO Move the ids of these to ElementNames and the getters to ElementsUtil
      # TODO Declare a data structure so these verifications can be put in a loop
      @place_holder.assert_div_by_id_existence('provider-section', true,'')
      @place_holder.assert_div_by_id_existence('national_provider-section', true, '')
      @place_holder.assert_div_by_id_existence('location-section', true, '')
      @place_holder.assert_div_by_id_existence('tax_id-section', true, '')
      @place_holder.assert_div_by_id_existence('phone_number-section', true, '')

    end

    # Verify that collapsing the profile tray changes the control back to the expand control
    begin

      @place_holder.collapse_profile_tray

      # Verify that the link that expands the profile tray exists when the tray is collapsed
      @place_holder.assert_profile_tray_expand_link_exists('after profile tray was collapsed')

    end

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2610
  # Verifies that
  #     Global search text field exists on the data center and takes input
  #     Number of profile types returned in search suggestions match
  #     First one of the search suggestions has the expected title
  def test_global_search_from_data_ctr

     # Login to the application
    @place_holder.login_with_proper_credentials

    # Navigate to the data center
    @place_holder.go_to_data_center('from the dashboard')

    # Verify that the global text field exists on the data center page
    @place_holder.assert_global_search_field_exists('on data center page')

    @place_holder.set_global_search_term(@search_term)

    # Verify that there are 4 suggestion containers, one for each profile type suggested
    @place_holder.assert_suggestion_container_count(PropertiesReader.get_exp_suggestions_type_count)

    # Verify that the first one of the search suggestions has the expected title
    @place_holder.assert_first_suggestion_title

  end

  # Verifies that global search text field exists on the graph and takes input
  # First one of the search 'results' (not suggestions) has the expected title
  def test_global_search_from_graph

    @place_holder.login_goto_profile(@provider_url)

    @place_holder.add_to_or_view_on_graph("from #{@provider_node_message} profile")

    # Verify that the global text field exists on the data center page
    @place_holder.assert_global_search_field_exists("on the profile page for #{@provider_node_message}")

    #global_search_text_field = get_global_search_text_field
    #global_search_text_field.set @search_term
    @place_holder.set_global_search_term(@search_term)

    @place_holder.send_enter_key

    @place_holder.print_html_contents

    # Wait and then time out if the container that displays the search results for the given search term does not appear
    @place_holder.get_search_results_body.wait_until_present(2)

    # Verify the title of the first search result
    @place_holder.assert_1st_search_result_title

  end

  # Verifies that
  #     Global search text field exists on the profile page and takes input
  #     Number of suggestion containers (i.e. the profile types returned)
  #     First one of the search suggestions has the expected title
  def test_global_search_on_profile_page

    @place_holder.login_goto_profile(@provider_url)

    # Verify that the global text field exists on the data center page
    @place_holder.assert_global_search_field_exists("on profile page for #{@provider_node_message}")

    #global_search_text_field = get_global_search_text_field
    #global_search_text_field.set @search_term
    @place_holder.set_global_search_term(@search_term)

    # Verify that there are 4 suggestion containers, one for each profile type suggested
    @place_holder.assert_suggestion_container_count(PropertiesReader.get_exp_suggestions_type_count)

    # Verify the title of the first suggestion
    @place_holder.assert_first_suggestion_title

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2609
  # Carries out the following verifications on the profile page
    # Verifies that the navigation menu exists
    # Verifies that the link to the data center exists
  # Verifies that clicking on the 'data Center' link navigates to the data center when navigated from the profile page
  # Verifies that the following 4 divs exist on the data center:
  def test_data_ctr_from_profile_page

    @place_holder.login_goto_profile(@provider_url)

    # Message to be used below for assertions, navigations
    profile_page_message = "from the profile page of the provider: #{@provider_node_message}"

    # Verify on the profile page that the following exist
    # a) the navigation menu (that contains the link to the data center)
    # b) link to the data center
    @place_holder.assert_nav_data_ctr_links_exist(profile_page_message)

    #@place_holder.assert_main_drop_down_data_ctr_links_exist(profile_page_message)
    # Navigate to the data center from the profile page
    @place_holder.go_to_data_center(profile_page_message)

    # Verify the navigation to the data center from the profile page
    @place_holder.assert_actual_url(PropertiesReader.get_data_center_url, 'after clicking on the data center link ' + profile_page_message)

    # Verify that the expected divs exists on the data center page when navigated from the profile page
    @place_holder.assert_divs_exist_on_data_center('after navigating to the data center ' + profile_page_message)

  end

  #  https://lynxeonqa.testrail.com/index.php?/cases/view/2839
  # Carries out the following verifications on the graph view
  # Verifies that the navigation menu exists
  # Verifies that the link to the data center exists
  # Verifies that clicking on the 'data Center' link navigates to the data center when navigated from the graph view
  # Verifies that the following 4 divs exist on the data center:
  def test_data_ctr_from_graph_view

    @place_holder.login_goto_profile(@provider_url)

    # Switch to the graph view
    @place_holder.add_to_or_view_on_graph('to test the data center from the graph view')

    # Message to be used below for navigations and assertions
    graph_view_message = "from the graph view of the provider: #{@provider_node_message}"

    # Verify on the graph view that the following exist
    # a) the navigation menu (that contains the link to the data center)
    # b) link to the data center
    @place_holder.assert_nav_data_ctr_links_exist(graph_view_message)

    # Navigate to the data center from the graph view
    @place_holder.go_to_data_center("from the graph view")

    # Verify the navigation to the data center from the graph view
    @place_holder.assert_actual_url(PropertiesReader.get_data_center_url, 'after clicking on the data center link' + graph_view_message)

    # Verify that the expected divs exists on the data center page when navigated from the graph view
    @place_holder.assert_divs_exist_on_data_center('after navigating to the data center ' + graph_view_message)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2840
  # Carries out the following verifications on the dashboard
    # Verifies that the navigation menu exists
    # Verifies that the link to the data center exists
  # Verifies that clicking on the 'data Center' link navigates to the data center when navigated from the dashboard
  # Verifies that the following 4 divs exist on the data center:
  def test_data_ctr_from_dashboard

    # Sign into the application
    @place_holder.login_with_proper_credentials

    # Make sure the current page is dashboard (this actually is not a functional verification, but just an intermediate check to make sure the following
    # assertions are carried out on the dashboard)
    @place_holder.assert_actual_url(PropertiesReader.get_dash_board_url, 'just an intermediate check to make sure the following assertions are carried out on the dashboard')

    #sleep(60)
    # Verify on the dash board that the following exist
    # a) the navigation menu (that contains the link to the data center)
    # b) link to the data center
    @place_holder.assert_nav_data_ctr_links_exist('on dashboard')

    # Navigate to the data center from dashboard
    @place_holder.go_to_data_center("from dashboard")

    # Verify the navigation to the data center from the dashboard
    @place_holder.assert_actual_url(PropertiesReader.get_data_center_url, 'after clicking on the data center link from dashboard')

    # Verify that the expected divs exists on the data center page when navigated from the dashboard
    @place_holder.assert_divs_exist_on_data_center('after navigating to the data center from dashboard')

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2233
  # Verifies that the attempt to login with bogus credentials does the following:
  # a) Expected error message
  # b) Redirects to the secure login page
  def test_valid_uname_invalid_pwd

    https_url = PropertiesReader.get_https_base_url
    @place_holder.go_to(https_url)

    valid_user_name = PropertiesReader.get_user_name
    @place_holder.set_text(ElementNames::USERNAME_TEXTFIELD_NAME, valid_user_name)

    invalid_password = PropertiesReader.get_invalid_password
    @place_holder.set_text(ElementNames::PASSWORD_TEXTFIELD_NAME, invalid_password)

    @place_holder.click_on_button(ElementNames::SUBMIT_BUTTON_ID)

    # Verify that the user stays on the secure login page
    @place_holder.assert_actual_url(PropertiesReader.get_exp_https_login_url, 'Not redirected to HTTPS login page after a failed login attempt')

    begin # Verify the error message displays

      $browser.p(class: ElementNames::FORM_CONTROL_STATIC_LOGINALERT_P_CLASS).wait_until_present(2)

      login_alert_class = $browser.p(class: ElementNames::FORM_CONTROL_STATIC_LOGINALERT_P_CLASS)
      actual_login_alert_text = login_alert_class.text

      exp_error_message = PlaceHolder::LOGIN_ERROR_MESSAGE
      @place_holder.assert_equal(exp_error_message, actual_login_alert_text, 'The text on the error message when attempted to login with invalid password for a valid user')

    end

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2235
  def test_profile_url_redirection

    bank_profile_url = PropertiesReader.get_bank_profile_url

    # Attempt to access the profile using the URL when not signed in
    @place_holder.go_to(bank_profile_url)

    # Verify that login screen is displayed which means access to the profile is not allowed without signing in
    @place_holder.assert_actual_url(PropertiesReader.get_exp_https_login_url, 'Attempting to access a profile using profile URL when not signed in does not redirect to HTTPS login page')

    @place_holder.login_with_proper_credentials

    # After logging in, verify that the user is taken to the requested profile and not the user's home page
    @place_holder.assert_actual_url(bank_profile_url, 'Signing in after attempting to directly access the profile redirects to the requested page (not the home page)')

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2261
  # Navigates to the 'provider' profile and does the following:
  # Verify that the score card div exist on the profile page
  # Verify that the profile summary header exists
  # Verify that the icon specific to the profile appears under the profile summary header
  def test_provider_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_provider_profile_url)

  end

 #  https://lynxeonqa.testrail.com/index.php?/cases/view/2262
  # Navigates to the 'NPI' profile and does the following:
  # Verify that the score card div exist on the profile page
  # Verify that the profile summary header exists
  # Verify that the icon specific to the profile appears under the profile summary header
  def test_npi_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_npi_profile_url)

  end

  #  https://lynxeonqa.testrail.com/index.php?/cases/view/2262
  # Navigates to the 'Recipient' profile and does the following:
  # Verify that the score card div exist on the profile page
  # Verify that the profile summary header exists
  # Verify that the icon specific to the profile appears under the profile summary header
  def test_recipient_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_recipient_profile_url)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2264
  # Navigates to the 'Location' profile and verifies the divs/sections on the profile page are loaded
  def test_location_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_location_profile_url)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2265
  # Navigates to the 'Tax ID' profile and verifies the divs/sections on the profile page are loaded
  def test_tax_id_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_tax_id_profile_url)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2838
  # Navigates to the 'Phone Number' profile and verifies the divs/sections on the profile page are loaded
  def test_phone_number_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_phone_number_profile_url)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2837
  # Navigates to the 'Bank Account' profile and does the following:
  #* Verify that the score card div exist on the profile page
  #* Verify that the profile summary header exists
  #* Verify that the icon specific to the profile appears under the profile summary header
  def test_bank_acct_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_bank_acct_profile_url)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2260
  # Navigates to the 'Bank Account' profile and does the following:
  #* Verify that the score card div exist on the profile page
  #* Verify that the profile summary header exists
  #* Verify that the icon specific to the profile appears under the profile summary header
  def test_bank_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_bank_profile_url)

  end

  # Navigates to the 'Bank' profile and verifies the divs/sections on the profile page are loaded
  def test_case_profile

    @place_holder.login_and_assert_profile(PropertiesReader.get_case_profile_url)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2239
  # Verifies the navigation between the profiles using the hyperlinks on the profile page
  # This test verifies navigation to 4 different profiles: Provider, NPI, Tax ID, Phone Number (selected profile has links only to these 4 profile types)
  # If navigation to all the 8 profiles need to be tested, then this test needs to be updated
  # def test_nav_between_profiles_using_hyperlinks
  # TODO Use hash
  def test_nav_between_profiles

    recipient_profile_url = PropertiesReader.get_recipient_profile_url
    @place_holder.login_goto_profile(recipient_profile_url)

    # Verify navigation to and back from location page
    begin

      # Verify navigation to the location page
      assert_fail_message = 'Clicking on the location of this profile takes to the expected URL'
      @place_holder.nav_via_hyperlink_assert_url(PropertiesReader.get_address_text_to_click_on, PropertiesReader.get_exp_location_navigated_to, assert_fail_message)

      # Click on the browser back button and verify that the user is navigated back to the original profile page
      back_nav_assert_fail_msg = 'Clicking on the back button from the location page does not take to the expected URL'
      @place_holder.browser_go_back_assert_url(recipient_profile_url, back_nav_assert_fail_msg)

    end

    # Verify navigation to and back from phone number page
    begin

      # Verify navigation to the address page
      assert_fail_message = 'Clicking on the phone number of this profile takes to the expected URL'
      @place_holder.nav_via_hyperlink_assert_url(PropertiesReader.get_phone_number_text_to_click_on, PropertiesReader.get_exp_phone_navigated_to, assert_fail_message)

      # Click on the browser back button and verify that the user is navigated back to the original profile page (the following navigations rely being on this pag)
      back_nav_assert_fail_msg = 'Clicking on the back button from the phone number page does not take to the expected URL'
      @place_holder.browser_go_back_assert_url(recipient_profile_url, back_nav_assert_fail_msg)

    end

    # Verify navigation to and back from Tax ID page
    begin

      # Verify navigation to the Tax ID page
      assert_fail_message = 'Clicking on the Tax ID of this profile takes to the expected URL'
      @place_holder.nav_via_hyperlink_assert_url(PropertiesReader.get_tax_id_text_to_click_on, PropertiesReader.get_exp_tax_id_navigated_to, assert_fail_message)

      # Click on the browser back button and verify that the user is navigated back to the original profile page (the following navigations rely being on this pag)
      back_nav_assert_fail_msg = 'Clicking on the back button from the Tax ID page does not take to the expected URL'
      @place_holder.browser_go_back_assert_url(recipient_profile_url, back_nav_assert_fail_msg)

    end

    # Verify navigation to and back from Provider page
    begin

      # Verify navigation to the Provider page
      assert_fail_message = 'Clicking on the Provider of this takes to the expected URL'
      provider_link_text_to_click_on = PropertiesReader.get_provider_link_text_to_click_on
      @place_holder.nav_via_hyperlink_assert_url(provider_link_text_to_click_on, PropertiesReader.get_exp_provider_navigated_to, assert_fail_message)

      # Click on the browser back button and verify that the user is navigated back to the original profile page (the following navigations rely being on this pag)
      back_nav_assert_fail_msg = 'Clicking on the back button from the Tax ID page does not take to the expected URL'
      @place_holder.browser_go_back_assert_url(recipient_profile_url, back_nav_assert_fail_msg)

    end

  end
  # https://lynxeonqa.testrail.com/index.php?/cases/view/2611
  # Verifies that when switching the perspectives, the most recently viewed profile is displayed when switched to 'Profiles' view after adding a different profile to the graph
  def test_switch_views_last_viewed_profile

    recipient_profile_url = PropertiesReader.get_recipient_profile_url

    @place_holder.login_goto_profile(recipient_profile_url)

    @place_holder.add_to_or_view_on_graph('to switch to graph view')

    @place_holder.go_to_profiles_view

    # Verify that the profile displayed is the one that was last viewed
    @place_holder.assert_actual_url(recipient_profile_url, 'switching the view from graph to profile displays the last viewed profile')

    # Navigate to a different profile using a hyperlink given on this profile page (to verify that last viewed (i.e. this location)) profile is displayed when the view is switched to 'Profile'
    begin

      assert_fail_message = 'navigating to a different profile'
      # TODO this is not a functional verification, it is just to make sure that the following assertion is valid
      exp_location_profile_displayed = PropertiesReader.get_exp_location_navigated_to

      address_text_to_click_on = PropertiesReader.get_address_text_to_click_on
      @place_holder.nav_via_hyperlink_assert_url(address_text_to_click_on, exp_location_profile_displayed, assert_fail_message)

      # To test the switching between the views, switch to graph view first (i.e. this new profile is added on to the graph)
      @place_holder.add_to_or_view_on_graph('after navigating to a different profile')

      # Switch to profile view to verify which profile is displayed
      @place_holder.go_to_profiles_view

      # Verify that the most recently viewed profile is the one that the switching between perspective takes to
      @place_holder.assert_actual_url(exp_location_profile_displayed, 'switching to the profile view after adding a different profile to the graph takes to the most recently viewed profile')

    end

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2242
  # Verifies that the attempt to access a profile after logging out redirects to the home page and that
  # an attempt to access the profile using its URL causes the redirection to the secure login page
  def test_profile_url_redirects

    @place_holder.login_with_proper_credentials

    @place_holder.logout_using_gear_icon

    exp_https_url = PropertiesReader.get_exp_https_login_url
    #Verify the redirection to the secure login takes place after signing out
    @place_holder.assert_actual_url(exp_https_url, 'Not redirected to HTTPS login page after signing out using gear icon')

    @place_holder.go_to(PropertiesReader.get_recipient_profile_url)
    sleep(1)

    @place_holder.assert_actual_url(exp_https_url, 'Attempting to access a profile using profile URL after signing out using gear icon does not redirect to the HTTPS login page')

  end

  #https://lynxeonqa.testrail.com/index.php?/cases/view/2237
  # Verifies that
  # a) Number of types of profiles returned as part of the search suggestions and
  # b) the title of the first suggestion match the expected for the given search term
  def test_search_suggestions

    @place_holder.login_with_proper_credentials

    @place_holder.enter_search_text(@search_term)

    # Wait for only one seconds before timing out if the suggestions container that displays the suggestions for the given search term does not appear
    @place_holder.get_search_suggestion_container.wait_until_present(1)

    # Verify that there are 4 suggestion containers, one for each profile type suggested
    @place_holder.assert_suggestion_container_count(PropertiesReader.get_exp_suggestions_type_count)
    @place_holder.print_html_contents

    #sleep(60)
    # Verify the title of the first suggestion
    @place_holder.assert_first_suggestion_title

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2238
  # Verifies that
  # a) The intended search result is returned as the top 1 result
  # b) When clicked on the first result, it takes to the expected profile
  def test_search_results

    @place_holder.login_with_proper_credentials

    @place_holder.enter_search_text(@search_term)

    @place_holder.send_enter_key

    # Wait and then time out if the container that displays the search results for the given search term does not appear
    @place_holder.get_search_results_body.wait_until_present(2)

    # Verify the title of the first search result
    @place_holder.assert_1st_search_result_title

    # Click on the first search result
    @place_holder.click(@place_holder.get_first_search_results_div)

    exp_first_search_result_dest_url = PropertiesReader.get_exp_first_search_result_dest_url
    # Verify the navigation to the expected profile took place after clicking on the above result
    @place_holder.assert_actual_url(exp_first_search_result_dest_url, 'not taken to the expected url after clicking on the first search result')

    # Verify that the expected divs/sections are displayed
    @place_holder.assert_profile(exp_first_search_result_dest_url)

  end

  # https://lynxeonqa.testrail.com/index.php?/cases/view/2241
  # Verifies the expansion of the suffix node for the provider profile
  # Once Dev provides id for the graph 'view', this test needs to be updated
  # to reduce dependency on the data
  # http://lynxjira.21technologies.com/jira/browse/THREE-1755
  def test_expand_provider_suffix

    provider_profile_url =PropertiesReader.get_provider_profile_url
    @place_holder.login_goto_profile(provider_profile_url)

    @place_holder.add_to_or_view_on_graph('initially after adding the nodes on graph')

    actual_initial_node_count = @place_holder.get_actual_node_count

    # Verify that the initial node count on the graph matches
    message = "initial node count for the profile #{@provider_node_message} before expansion"
    @place_holder.assert_actual_node_count(PropertiesReader.get_expected_initial_node_count, message)

    suffix_node_message = PropertiesReader.get_suffix_node_message
    suffix_node_vertex_id = PropertiesReader.get_suffix_node_vertex_id
    @place_holder.expand_node(suffix_node_vertex_id, suffix_node_message)

    # These verifications are removed until the data dependency is reduced by adding framework support to identify the graph nodes using an attribute
    begin
      ## Make sure the expected nodes are initially added onto the graph so the assertion after the expansion for the existence of the nodes
      ## below would not be invalid
      #@place_holder.assert_nodes_on_provider_graph
      #
      #provider_node = get_provider_node
      #@place_holder.print_element_coordinates(provider_node, 'provider node prior to the expansion')
      #
      #
      #expand_recipient_95_context_item = ContextMenuItems::EXPAND_RECIPIENT_95_CONTEXT_ID
      #
      #expand_resultant_node_vertex_id = PropertiesReader.get_expand_resultant_node_vertex_id
      #expand_resultant_node_vertex_message = PropertiesReader.get_expand_resultant_node_vertex_message
      #
      ## Make sure the node doesn't exist prior to the expansion to make sure the assertion below (for the existence of this node to be true) would be valid
      #@place_holder.assert_node_existence_on_graph(expand_resultant_node_vertex_id, false, "existence of the node as a results of expanding the node: <#{expand_resultant_node_vertex_message}> on <#{expand_recipient_95_context_item} > that is expected to be added on the graph prior to the expansion to make sure the assertion below expansion for its existence true to be valid ")
      #
      #
      ## Verify that the expected node is added to the graph after the expansion
      #@place_holder.assert_node_existence_on_graph(expand_resultant_node_vertex_id, true, "this node is added to the graph as a results of expanding the node: <#{expand_resultant_node_vertex_message}> on<#{expand_recipient_95_context_item} >")
      #@place_holder.assert_equal(provider_initial_coordinates, provider_post_expansion_coordinates, 'Location coordinates of the provider profile to stay the same after the expansion')
      #
      #provider_post_expansion_coordinates = get_element_coordinates(get_provider_node, 'provider node after the expansion')
      #@place_holder.print_element_coordinates(provider_node, 'provider node after the expansion')
      #
      ## Verify that the expansion didn't mess up the existing nodes
      #@place_holder.assert_nodes_on_provider_graph

    end

    actual_node_count_post_expansion = @place_holder.get_actual_node_count

    puts "actual_initial_node_count: #{actual_initial_node_count}"
    puts "actual_node_count_post_expansion: #{actual_node_count_post_expansion}"

    expected_expansion_node_count = PropertiesReader.get_expected_expansion_result_node_count
    exp_total_nodes_after_expansion = actual_initial_node_count + expected_expansion_node_count

    # Use the actual (not the expected) initial node count in determining the expected count after expansion
    @place_holder.assert_equal(exp_total_nodes_after_expansion, actual_node_count_post_expansion, 'Number of nodes displayed on the graph after expansion')

  end

  def set_commonly_used_variables

    # Declare class variables for the values that are referenced by multiple tests
    @provider_url = PropertiesReader.get_provider_profile_url
    @provider_node_vertex_id = PropertiesReader.get_provider_node_vertex_id
    @provider_node_message =  PropertiesReader.get_provider_node_message
    @search_term = PropertiesReader.get_search_term

  end

end
