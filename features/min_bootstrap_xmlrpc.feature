# Copyright (c) 2017 SUSE LLC
# Licensed under the terms of the MIT license.

Feature: register a salt-minion via XMLRPC API bootstrap procedure

  Scenario: Setup XMLRPC Bootstrap: Delete sles-minion system profile before XMLRPC bootstrap test
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Delete System"
    And I should see a "Confirm System Profile Deletion" text
    And I click on "Delete Profile"
    Then I should see a "has been deleted" text
    And I cleanup minion: "sle-minion"

  Scenario: bootstrap a sles minion via XMLRPC API (it will be deleted after)
    Given I am logged in via XML-RPC/system as user "admin" and password "admin"
    When I call system.bootstrap() on host "sle-minion" and saltSSH "disabled", a new system should be bootstraped.
    And I logout from XML-RPC/system.

  Scenario: check new XMLRPC bootstrapped minion in System Overview page
     Given I am authorized
     And I go to the minion onboarding page
     Then I should see a "accepted" text
     And the salt-master can reach "sle-minion"
     And I navigate to "rhn/systems/Overview.do" page
     And I wait until I see the name of "sle-minion", refreshing the page
     And I wait until onboarding is completed for "sle-minion"

  Scenario: Check contact method of this minion
    Given I am on the Systems overview page of this "sle-minion"
    Then I should see a "Default" text

  Scenario: Check spacecmd system ID of XMLRPC-bootstrapped minion.
    Given I am on the Systems overview page of this "sle-minion"
    Then I run spacecmd listevents for "sle-minion"

  Scenario: Cleanup XMLRPC Bootstrap: Subscribe to base channel
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Software" in the content area
    Then I follow "Software Channels" in the content area
    And I select "Test-Channel-x86_64" from "new_base_channel_id"
    And I click on "Confirm"
    And I click on "Modify Base Software Channel"
    And I should see a "System's Base Channel has been updated." text
    Then I apply highstate on "sle-minion"

  Scenario: Bootstraping non-existing system
    Given I am logged in via XML-RPC/system as user "admin" and password "admin"
    When I call system.bootstrap() on unknown host, I should get an XMLRPC fault with code -1.
    And I logout from XML-RPC/system.

  Scenario: Bootstraping salt-ssh system with activation key with Default contact method
    Given I am logged in via XML-RPC/system as user "admin" and password "admin"
    When I call system.bootstrap() on a salt minion with saltSSH = true, but with activation key with Default contact method, I should get an XMLRPC fault with code -1.
    And I logout from XML-RPC/system.
