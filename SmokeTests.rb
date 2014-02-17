require 'test/unit'
require 'watir-webdriver'

#URLs
HTTP_URL = 'http://alpha.21technologies.com/'
EXPECTED_HTTPS_URL = 'https://alpha.21technologies.com/#/login'
PROFILE_TO_ACCESS_AFTER_LOGOUT = 'https://alpha.21technologies.com/#/profile/recipient/4bf5ed73-a4d7-37fd-a005-a705eb53afdf'
BANK_PROFILE_URL = 'https://alpha.21technologies.com/#/profile/bank/8f181741-21b1-3b6e-98d1-328ce00005ae'
SIGNOUT_IN_CHECKHOMEPAGE = 'https://alpha.21technologies.com/#/profile/bank/8f181741-21b1-3b6e-98d1-328ce00005ae'

#Widget identification
USERNAME_TEXTFIELD_NAME = 'username'
PASSWORD_TEXTFIELD_NAME = 'password'

SUBMIT_BUTTON_ID = 'submitBtn'

#Input
VALID_USERNAME = 'lynxeon'
VALID_PASSWORD = 'Alpha1'

INVALID_PASSWORD = 'invalidpwd'

#Error messages
LOGIN_ERROR_MESSAGE = 'Wrong username or password. Try again!'

class SmokeTest < Test::Unit::TestCase

    # Called before every test method runs.
    # To avoid side affects of one test caused by the previous test,
    # browser is started at the beginning of each test and closed
    # after the test ends
    def setup

      $browser = Watir::Browser.new :chrome

      $browser.goto HTTP_URL

    end

    # Called after every test method runs. Closes the browser
    def teardown

      #sleep(5)

      $browser.cookies.clear
      $browser.close

    end

    # Verifies that the attempt to access the site via HTTP redirects to HTTPS
    def test_http_redirects_to_https
	  
	  sleep(1)
      lynx_assert_actual_url(EXPECTED_HTTPS_URL, 'not redirected to HTTPS login when the site is accessed via HTTP')

    end

    # Verifies that the attempt to login with bogus credentials does the following:
    # a) Expected error message displays
    # b) Redirects to the secure login page
    def test_valid_uname_invalid_pwd

      set_text(USERNAME_TEXTFIELD_NAME, VALID_USERNAME)
      set_text(PASSWORD_TEXTFIELD_NAME, INVALID_PASSWORD)

      click_on_button(SUBMIT_BUTTON_ID)

      # Verify that the user stays on the secure login page
      lynx_assert_actual_url(EXPECTED_HTTPS_URL, 'Not redirected to HTTPS login page after a failed login attempt')

      begin # Verify the error message displays

        $browser.p(class: 'form-control-static loginAlert').wait_until_present(2)
        login_alert_class = $browser.p(class: 'form-control-static loginAlert')
        actual_login_alert_text = login_alert_class.text

        assert_equal(LOGIN_ERROR_MESSAGE, actual_login_alert_text, 'The expected error message does not display when attempted to login with invalid password for a valid user')

        end
    end

    def test_bank_profile

      # Attempt to access the profile using the URL when not signed in
      $browser.goto(BANK_PROFILE_URL)
	  sleep(1)

      # Verify that login screen is displayed which means access to the profile is not allowed without signing in
      lynx_assert_actual_url(EXPECTED_HTTPS_URL, 'Attempting to access a profile using profile URL when not signed in does not redirect to HTTPS login page')

      login_with_proper_credentials

      # After logging in, verify that the user is taken to the requested profile and not the user's home page
      lynx_assert_actual_url(BANK_PROFILE_URL, 'Signing in after attempting to directly access the profile redirects to the requested page (not the home page)')

      # Verify that the top panel where the profile info is displayed exists
      score_card_content_div_exists = $browser.div(id: 'score_card_content').exists?
      assert_equal(true, score_card_content_div_exists, 'Score card that is expected to contain the information about the profile does not exist')

      # Verify that the panel where the location info is displayed exists
      panel_default_ng_scope_exists = $browser.div(class: 'panel panel-default ng-scope').exists?
      assert_equal(true, panel_default_ng_scope_exists, 'Div class that is expected to contain the information about the profile does not exist')
    end

    # Verifies that attempt to access a profile after logging out redirects to the home page and that
    # an attempt to access the profile using its URL causes the redirection to the secure login page
    def test_profile_url_redirects

    login_with_proper_credentials

    logout_using_gear_icon

    #Verify the redirection to the secure login takes place after signing out
    lynx_assert_actual_url(EXPECTED_HTTPS_URL, 'Not redirected to HTTPS login page after signingout using gear icon')

    $browser.goto(PROFILE_TO_ACCESS_AFTER_LOGOUT)
    sleep(1)

    lynx_assert_actual_url(EXPECTED_HTTPS_URL, 'Attempting to access a profile using profile URL after signing out using gear icon does not redirect to HTTPS login page')

    end

  # Sets the text in the text field whose name is given
  # @param [String] text_field_name of the text field used for identification
  # @param [String] value_to_set
  def set_text(text_field_name, value_to_set)

    given_text_field = $browser.text_field(name: "#{text_field_name}")

    given_text_field.wait_until_present(2)
    given_text_field.set "#{value_to_set}"

    #Make sure the value set is retained in the text field
    begin
      value_after_set = given_text_field.value

      if value_after_set != value_to_set
        raise "The attempt to set the text: #{value_to_set} in the text field #{text_field_name} was not successful. The text field contains #{value_after_set}"
      end
    end

  end

  #Clicks on the buttons whose id is given
  def click_on_button(button_name)

    given_button = $browser.button(id: "#{button_name}")

    given_button.wait_until_present(2)

    given_button.click

    sleep(1)
  end

  # Enters the users id and password, clicks on the submit button and waits for a second
  def login_with_proper_credentials

    set_text(USERNAME_TEXTFIELD_NAME, VALID_USERNAME)
    set_text(PASSWORD_TEXTFIELD_NAME, VALID_PASSWORD)

    click_on_button(SUBMIT_BUTTON_ID)

  end

  # Fires the onMouseOver event for the link whose id is given
  def mouse_over_link(link_id)

    link_using_id = get_link_using_id(link_id)

    link_using_id.fire_event 'onMouseOver'

  end

  def get_link_using_id(link_id)

    link_using_id = $browser.a(id: "#{link_id}")
    link_exists = link_using_id.exists?

    # Make sure the link exists, throw an error if it doesn't
    unless link_exists

      current_url = $browser.url
      #To test this raise, add this somewhere in the code:  get_link_using_id("somejunkidforalink")
      raise "The link whose id given is: <#{link_id}> doesn't exist on the page: <#{current_url}>"

    end

    #link_using_id = $browser.a(id: "#{link_id}")

    link_using_id
  end

  # clicks on the link whose a id is given
  # As onclick event is not automatically fired by clicking the link, this method
  # takes care of firing that event
  def click_on_alink(link_id)

    link_using_id = get_link_using_id(link_id)

    link_using_id.click

    # With logout button, it is noted that click on it doesn't cause the
    # 'onclick' event to be automatically fired, so having to explicitly fire the event
    link_using_id.fire_event('onclick')

    sleep(1)

  end

  # Attempts to signout using the gear navigational tool bar
  # Assumes that the user is logged in
  def logout_using_gear_icon

    mouse_over_link('tools-dropdown')

    click_on_alink('logout')

    sleep(2)

  end

  def lynx_assert_actual_url(expected_url, failure_message)

    @actual_url = $browser.url

    assert_equal(expected_url, @actual_url, failure_message)

  end
end