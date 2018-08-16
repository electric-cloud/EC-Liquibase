#############################################################################
#
# Run Liquibase Commands
#
# Author: L.Rochette
#
# Copyright 2018 Electric Cloud, Inc.
#
#     Licensed under the Apache License, Version 2.0 (the "License");
#     you may not use this file except in compliance with the License.
#     You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#     Unless required by applicable law or agreed to in writing, software
#     distributed under the License is distributed on an "AS IS" BASIS,
#     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#     See the License for the specific language governing permissions and
#     limitations under the License.
#
# History
# ---------------------------------------------------------------------------
# 2018-Aug-15 lrochette Initial Version
#
# TODO:
#############################################################################
$[/plugins/EC-Admin/project/scripts/perlHeaderJSON]

#
# Parameters
#
my $configName = '$[config]';
my $liquibaseLocation='$[liquibaseLocation]';
my $changelog='$[changelog]';
my $liquibaseCommand='$[liquibaseCommand]';

#
# Global variables
#
my $command;    # Full command to run
my $username;   # username to pass for credentials
my $passwd;     # password to pass

my $configHashRef = getPS("/myProject/ec_plugin_cfgs/$configName", 1);

my $dbUrl=$configHashRef->{dbUrl};
my $driver=$configHashRef->{driver};

my $json=$ec->getFullCredential($configName);

my $username=$json->{responses}->[0]->{credential}->{userName};
my $password=$json->{responses}->[0]->{credential}->{password};

$command=$liquibaseLocation ;
if ($driver ne "") {
  $command .= " --driver=$driver";
}
$command .= " --changeLogFile=$changelog";
$command .= " --url=\"$dbUrl\"";
$command .= " --username=$username";
$command .= " --password=$password";
$command .= " $liquibaseCommand";

my $commandToDisplay=$command;
$commandToDisplay =~ s/password=[^ ]*/password=****/;
printf("Executing: %s\n", $commandToDisplay);

system($command);

$[/plugins/EC-Admin/project/scripts/perlLibJSON]
