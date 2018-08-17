/* ###########################################################################
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
############################################################################*/
import com.electriccloud.client.groovy.ElectricFlow

def handleProcedureError (String msg) {
    ef.createProperty(propertyName: 'summary', value: "ERROR: $msg")
    handleError(msg)
}

def configName = '$[config]'
def liquibaseLocation='$[liquibaseLocation]'
def changelog='$[changelog]'
def liquibaseCommand='$[liquibaseCommand]'
def options='$[options]'

ElectricFlow ef = new ElectricFlow()

ef.getProperties(propertyName: "/myProject/ec_plugin_cfgs/$configName",
  /*success handler*/ { response, data ->
    result = data
  },
  /*failure handler*/ { response, data ->
    //assuming pipeline does not exist hence the failure
    handleProcedureError("No plugin $configName configuration exist!")
  })

def pluginConfig = result.propertySheet.property.collectEntries {
    [(it.propertyName): it.value]
}

//
// Global variables
//
def cred = ef.getFullCredential(credentialName: configName)
def dbUrl=pluginConfig.dbUrl
def driver=pluginConfig.driver

String command;    // Full command to run
String username=cred.credential.userName;
String password=cred.credential.password;

command=liquibaseLocation ;
if (options) {
  command += " $options";
}
if (driver) {
  command += " --driver=$driver";
}
command += " --changeLogFile=$changelog";
command += " --url=$dbUrl";
command += " --username=$username";
command += " --password=$password";
command += " $liquibaseCommand";

String commandToDisplay=command.replaceAll("password=[^ ]*", 'password=****')
println "Executing: $commandToDisplay"

def proc = command.execute()
proc.waitForProcessOutput(System.out, System.err);
return proc.exitValue()
