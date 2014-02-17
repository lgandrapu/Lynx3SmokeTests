# This class contains constants that represent the values of different attributes of the elements used to identify them

class ElementNames

  public
# Login page
  begin

    USERNAME_TEXTFIELD_NAME = 'username'

    PASSWORD_TEXTFIELD_NAME = 'password'

    SUBMIT_BUTTON_ID = 'submitBtn'

    # 'p' that contains the log in alert
    FORM_CONTROL_STATIC_LOGINALERT_P_CLASS = 'form-control-static loginAlert'

  end

  VIEW_ON_OR_ADD_TO_GRAPH_BTN_CLASS_NAME = 'graph-btn btn btn-default btn-sm'

  # Search
  begin

    SEARCH_TEXT_FIELD_CLASS_NAME = 'home-search-input'

    GLOBAL_SEARCH_TEXT_FIELD_ID = SEARCH_TEXT_FIELD_CLASS_NAME

     # The container that displays the search results for the given search term
    SEARCH_RESULTS_BODY = 'search-results-body'

    # Suggestion rows (All the suggestion rows have the same name)
    #SUGGESTION_ROW_DIV_CLASS_NAME = 'row result'
    SUGGESTION_ROW_DIV_CLASS_NAME = 'result'

    # Search result rows (All the rows have the same name)
    SEARCH_RESULT_ROW_DIV_CLASS_NAME = 'search-result row first'

    # Suggestions container that displays the suggestions for the given search term
    # Number of elements that match this equals the number of profile types found as there would be once results container for each profile
    RESULT_CONTAINER = 'results-container'

  end

  # Navigation menu on the top left that contains the link for the data center
  NAV_MENU_UL_ID = 'nav-menu'

  #MAIN_DROP_DOWN = ''
  TOOLS_GEAR_ICON = 'tools-dropdown'

  LOGOUT_HREF_ID = 'logout'

  # Profile page
  begin

    # Contains the information about the profile
    SCORE_CARD_CONTENT_DIV_ID = 'score_card_content'

    # Contains the profile summary information
    PROFILE_SUMMARY = 'profile-summary'

    # 'Profiles' link to navigate to the profile perspective from graph perspective'
    PROFILES_HREF_TEXT = 'Profiles'

    ADD_TO_GRAPH_SPAN_TEXT = 'Add to Graph'

    VIEW_ON_GRAPH_SPAN_TEXT = 'View on Graph'

    CASE_PROFILE_AS_IN_URL = 'investigation'

    ICON_NAME_PREFIX = 'lynx-icon-'

    ICON_SUFFIXES = { 'provider' => 'provider',
                      'recipient' => 'recipient',
                      'location' => 'location',
                      'bank' => 'bank',
                      'bank_account' => 'bankacct',
                      'tax_id' => 'taxid',
                      'national_provider' => 'nationalid',
                      'phone_number' => 'phonenumber',
                      CASE_PROFILE_AS_IN_URL => 'alert'
    }

  end

  # Graph
  begin

    PAN_ZOOM_BUTTON_ID = 'pan-zoom-btn'

    MULTI_SELECT_BUTTON_ID = 'multi-select-btn'

    ZOOM_TO_FIT_BUTTON_ID = 'zoom-to-fit-btn'

    COLLAPSE_EXPAND_ARROW_CLASS_NAME = 'lynx-icon-arrowcollapse control-handle expand'

  end

end