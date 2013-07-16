# Copyright (c) 2013 SUSE
# Licensed under the terms of the MIT license.

Feature: CVE Audit
  In Order to check if systems are patched against certain vulnerabilities
  As an authorized user
  I want to see systems that need to be patched

Background:
  Given I am authorized as "admin" with password "admin"

Scenario: schedule channel data refresh
  When I follow "Admin"
    And I follow "Task Schedules"
    And I follow "cve-server-channels-default"
    And I follow "cve-server-channels-bunch"
    And I click on "Single Run Schedule"
  Then I should see a "bunch was scheduled" text
    And I wait for "5" seconds

Scenario: feature should be accessible
  When I follow "Audit"
    Then I should see a "CVE Audit" link in the left menu
     And I should see a "CVE Audit" text

Scenario: searching for a known CVE number
  When I follow "Audit"
    And I enter "CVE-2012-3400" as "cveIdentifier"
    And I click on "Audit systems"
  Then I should see this client as a link
    And I should see a "Affected, patch available in an assigned channel" text in the "Patch status" column
    And I should see a "Install a new patch in this system" link
    And I should see a "Only candidate is: slessp2-kernel-6648" text in the "Next Action" column
    And I should see a "Download CSV" link
    And I should see an alphabar link to this system
    And I should see a "Patch status" link
    And I should see a "System" link
    And I should see a "schedule a single CVE channel data update run" link
  Then I follow "Install a new patch in this system"
    And I should see a "Relevant Patches" text

Scenario: searching for an unknown CVE number
  When I follow "Audit"
    And I enter "CVE-2012-2806" as "cveIdentifier"
    And I click on "Audit systems"
  Then I should see a "The CVE number you specified was not found" text

Scenario: selecting a system for the System Set Manager
  When I follow "Audit"
    And I enter "CVE-2012-3400" as "cveIdentifier"
    And I click on "Audit systems"
    And I should see a "Affected, patch available in an assigned channel" text
  When I check "Affected, patch available in an assigned channel" in the list
    Then I should see a "1 system selected" text
  When I follow "Manage"
     And I follow "Systems" in class "content-nav"
  Then I should see this client as a link
  Then I follow "Clear"