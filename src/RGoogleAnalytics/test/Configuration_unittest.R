# Copyright 2010 Google Inc. All Rights Reserved.
# Author: mpearmain@ (Mike Pearmain)
# Author: api.nickm@ (Nick Mihailovski)


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

# Run unit tests in R, for QueryBuilder.R
# The driver file to execute is ./Runit_driver.R

source("./R/Configuration.R")
load("./R/ga.account.Rda")
conf <- Configuration()
 
TestParameterSelector <- function(){
  param.param <- NA
  checkEquals("~all",conf$ParameterSelector(param.param) )
  param.param <- NULL
  checkEquals(param.param,conf$ParameterSelector(param.param) )
  param.param <- "54321"
  checkEquals(param.param,conf$ParameterSelector(param.param) )
}

TestDataFramepacker <- function(){
  checkEquals(ga.account.df,conf$DataFramepacker(ga.account,"accounts"))
}



