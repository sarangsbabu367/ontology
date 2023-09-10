# ontology

ontology is a simple lookup script which provides details of a particular ontology by giving the `ontology-id` id as input.

Details are fetched by using REST api support of ontology website ([Reference](https://www.ebi.ac.uk/ols/docs/api)).

Error scenarios like *invalid ontology-id*, *unavailability of service*, *other unexpected errors* are also handled.

Response is a machine and human readable json format.

# Installation

If [ruby](https://www.ruby-lang.org/en/documentation/) is not installed in the system, please follow the [official guide](https://www.ruby-lang.org/en/documentation/installation/).

After cloning the project, to install the required dependencies run below command from terminal. 


> bundle install

# How to use

There are 2 ways to use the script. After the necessary installation mentioned in above section, follow the below section.

## From terminal

The service can be run as a ruby script from terminal by providing `ontology-id` as argument.

```zsh
➜  ontology git:(feat_ontology_lookup_service) ruby ontology_lookup_service.rb agro 
{"title":"Agronomy Ontology","description":"AgrO is an ontlogy for representing agronomic practices, techniques, variables and related entities","numberOfTerms":3736,"status":"LOADED"}
➜  ontology git:(feat_ontology_lookup_service) ✗ 
```

```zsh
➜  ontology git:(feat_ontology_lookup_service) ✗ ruby ontology_lookup_service.rb invalid_id
{"id":"1","status":404,"error":"Unable to get details of ontology with given id."}
➜  ontology git:(feat_ontology_lookup_service) ✗ 
```

## From bash script

A batch script (bash or .bat) also can be used to execute the ruby service.

`script.sh` in the repo is an example

```zsh
➜  ontology git:(feat_ontology_lookup_service) ✗ bash script.sh 
{"title":"Agronomy Ontology","description":"AgrO is an ontlogy for representing agronomic practices, techniques, variables and related entities","numberOfTerms":3736,"status":"LOADED"}
➜  ontology git:(feat_ontology_lookup_service) ✗ 
```

# Tests

Test cases are added in the project. Please ensure all tests are passing before pushing any changes to the project. Tests can be run as below,

ps: External api call is mocked in the tests.

```zsh
➜  ontology git:(feat_ontology_lookup_service) ✗ ruby /Users/sarang/work/ontology/test_ontology_lookup_service.rb
Loaded suite /Users/sarang/work/ontology/test_ontology_lookup_service
Started
......
Finished in 0.000496 seconds.
---------------------------------------------------------------------------------------------------------------------------------
6 tests, 11 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
100% passed
---------------------------------------------------------------------------------------------------------------------------------
12096.77 tests/s, 22177.42 assertions/s
➜  ontology git:(feat_ontology_lookup_service) ✗ 
```