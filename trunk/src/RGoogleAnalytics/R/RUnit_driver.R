# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Driver file for running RGoogleAnalytics unit tests.
#' 
#' This function runs all unit tests defined in the inst/unitTests folder. The 
#' example below is run by \code{R CMD check} and will make the check fail if 
#' any errors or failures occur inside the unit tests.
#' 
#' @author Michael Pearmain
#' @return TRUE if an error or failure occurred in one or more unit tests, 
#' FALSE = otherwise.
#' @examples 
#' failed <- TestRGoogleAnalytics()
#' if (failed) stop("One or more unit tests have failed.")
#' @export
TestRGoogleAnalytics <- function() {
  pkg <- "RGoogleAnalytics"
  failure <- FALSE # <-- is TRUE if any failure or errors occur
  if(require("RUnit", quietly = TRUE)) {
    library(pkg, character.only = TRUE)
    # define tests:
    calculate.test.suite <- 
      defineTestSuite("RGoogleAnalytics Unit Testing",
                      dirs = system.file("unitTests", package = pkg),
                      testFuncRegexp = "^Test",
                      testFileRegexp = "_unittest.R$")
    # execute tests:
    testResult <- runTestSuite(calculate.test.suite, verbose = 1)
    
    # update failure flag:
    failure <- any(c(failure, 
                     getErrors(testResult)$nErr + 
                       getErrors(testResult)$nFail > 0))
    # print detailed text protocol:
    printTextProtocol(testResult, showDetails = TRUE)
  } else {
    warning(pkg, ": cannot run unit tests -- package RUnit is not available")
  }
  invisible(failure)
}