Feature: Channel overview
  In order to actually use the system for anything
  As a user
  I need to be able to view and administer recorded shows

Background:
  Given the following recorded shows:
    | name       |
    | Bonderøven |
    | Noddy      |
    | Star Trek  |
  And the following recordings:
    | name       | id        |
    | Bonderøven | 1234567   |
    | Bonderøven | 1234567-1 |
    | Bonderøven | 1234678   |
    | Star Trek  | 2345678   |

Scenario: Shows overview shows all recorded shows
  Given I am on the shows page
  Then I should see "Bonderøven"
  And I should see "Noddy"
  And I should see "Star Trek"

Scenario: Show details shows all recordings of show
  Given I am on the shows page
  # The following does not work with Poltergeist/PhantomJS - prints infinitely many
  # AngularJS errors :-(
  #And I see the details for show "Bonderøven"
  #Then I should see 3 recordings