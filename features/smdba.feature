# Copyright (c) 2015 SUSE LLC
# Licensed under the terms of the MIT license.

Feature: Verify SMDBA infrastructure
  In order to operate embedded database with SMDBA tool
  As the testing user
  I want to check if infrastructure is consistent

  Scenario: Check if embedded database is PostgreSQL
    When I cannot find file "/var/lib/pgsql/data/postgresql.conf"
    Then I disable all the tests below

  Scenario: Check embedded database running
    When I start database with the command "smdba db-start"
    And when I issue command "smdba db-status"
    Then I want to see if "online" is in the output

  Scenario: Check embedded database can be stopped, started and restarted
    When I start database with the command "smdba db-start"
    And when I see that the database is "online" or "failed" as it might already running
    And when I stop the database with the command "smdba db-stop"
    And when I check the database status with the command "smdba db-status"
    Then I want to see if the database is "offline"
    When I start database with the command "smdba db-start"
    And when I issue command "smdba db-status"
    Then I want to see if the database is "online"

  Scenario: Check system check of the database sets optimal configuration
    When I stop the database with the command "smdba db-stop"
    And when I configure "/var/lib/pgsql/data/postgresql.conf" parameter "wal_level" to "hot_standby"
    Then I start database with the command "smdba db-start"
    And when I issue command "smdba db-status"
    Then I want to see if the database is "online"
    And when I check internally configuration for "wal_level" option
    Then I expect to see the configuration is set to "hot_standby"
    Then I issue command "smdba system-check"
    And when I stop the database with the command "smdba db-stop"
    And I start database with the command "smdba db-start"
    And when I check internally configuration for "wal_level" option
    Then I expect to see the configuration is set to "archive"

  Scenario: Check database utilities
    Given database is running
    When I issue command "smdba space-overview"
    Then I find tablespaces "susemanager" and "postgres"
    When I issue command "smdba space-reclaim"
    Then I find core examination is "finished", database analysis is "done" and space reclamation is "done"
    When I issue command "smdba space-tables"
    Then I find "public.rhnserver", "public.rhnpackage" and "public.web_contact" are in the list.

  Scenario: Check SMDBA backup setup facility
    Given database is running
    Given there is no such "/smdba-backup-test" directory
    When I create backup directory "/smdba-backup-test" with UID "root" and GID "root"
    And when I issue command "smdba backup-hot --enable=on --backup-dir=/smdba-backup-test"
    Then I should see error message that asks "/smdba-backup-test" belong to the same UID/GID as "/var/lib/pgsql/data" directory
    Then I remove backup directory "/smdba-backup-test"
    When I create backup directory "/smdba-backup-test" with UID "postgres" and GID "postgres"
    And when I issue command "smdba backup-hot --enable=on --backup-dir=/smdba-backup-test"
    Then I should see error message that asks "/smdba-backup-test" has same permissions as "/var/lib/pgsql/data" directory
    Then I remove backup directory "/smdba-backup-test"

  Scenario: Take backup with SMDBA
    Given database is running
    Given there is no such "/smdba-backup-test" directory
    When I create backup directory "/smdba-backup-test" with UID "postgres" and GID "postgres"
    And when I change Access Control List on "/smdba-backup-test" directory to "0700"
    And when I issue command "smdba backup-hot --enable=on --backup-dir=/smdba-backup-test"
    Then base backup is taken
    Then in "/smdba-backup-test" directory there is "base.tar.gz" file and at least one backup checkpoint file
    Then parameter "archive_command" in the configuration file "/var/lib/pgsql/data/postgresql.conf" is "/usr/bin/smdba-pgarchive"
    Then "/usr/bin/smdba-pgarchive" destination should be set to "/smdba-backup-test" in configuration file

  Scenario: Restore backup with SMDBA
    Given database is running
    Given database "susemanager" has no table "dummy"
    When I set a checkpoint
    And when I issue command "smdba backup-hot"
    And when in the database I create dummy table "dummy" with column "test" and value "bogus data"
    And when I destroy "/var/lib/pgsql/data/pg_xlog" directory
    And when I restore database from the backup
    And when I issue command "smdba db-status"
    Given database is running
    Given database "susemanager" has no table "dummy"
    Then I disable backup in the directory "/smdba-backup-test" 
    Then I remove backup directory "/smdba-backup-test"