# Change Log

All notable changes to this project will be documented in this file.
This project *tries* to adhere to [Semantic Versioning](http://semver.org/), even before v1.0.

## [2.0.3] - 2024-10-29
- [#38](https://github.com/tongueroo/dynomite/pull/38) fix issue where running dynamodb-local in docker-compose (where host is not localhost)
- [#40](https://github.com/tongueroo/dynomite/pull/40) Avoids eager-loading Dynomite::Engine
- Updates documentation link in README.md

## [2.0.2] - 2023-12-10
- [#37](https://github.com/tongueroo/dynomite/pull/37) fix eager load

## [2.0.1] - 2023-12-08
- [#36](https://github.com/tongueroo/dynomite/pull/36) set log level info as default

## [2.0.0] - 2023-12-03
- [#35](https://github.com/tongueroo/dynomite/pull/35) ActiveModel compatible
- Breaking change interface to be ActiveModel compatible
- ActiveModel: validations, callbacks, etc
- Use zeitwerk for autoloading
- Typecast support for DateTime-like objects. Store date as iso8601 string.
- Remove config/dynamodb.yml in favor of Dynomite.configure for use with initializers
- namespace separator default is _ instead of -
- Dynomite.logger introduced
- arel like where query builder interface
- finder methods: all, first, last, find_by, find, count
- index finder: automatically use query over scan with where when possible
- organize query to read and write ruby files
- Migrations: improved migrate command. No need to specify files.
- namespaced schema_migrations table tracks ran migrations.
- Favor ondemand provisioning vs explicit provisioned_throughput
- Standalone dynamodb cli to generate migrations and run them

## [1.2.7] - 2022-06-12
- [#23](https://github.com/tongueroo/dynomite/pull/23) #where method refactor to allow Model.index_name('index').where(...)
- [#24](https://github.com/tongueroo/dynomite/pull/24) Add get_endpoint_ip to db_config.rb
- [#26](https://github.com/tongueroo/dynomite/pull/26) change pay_per_use to pay_per_request
- [#27](https://github.com/tongueroo/dynomite/pull/27) Fixed message that tells how to install dynamodb-local

## [1.2.6]
- Implement the `PAY_PER_USE` billing mode for table creations and updates. See [DynamoDB On Demand](https://aws.amazon.com/blogs/aws/amazon-dynamodb-on-demand-no-capacity-planning-and-pay-per-request-pricing/).

## [1.2.5]
- use correct color method

## [1.2.4]
- #16 add rainbow gem dependency for color method
- #17 fix table names for models with namespaces

## [1.2.3]
- #11 fix comments in dsl.rb
- #13 update find method to support composite key

## [1.2.2]
- update Jets.root usage

## [1.2.1]
- #10 from gotchane/fix-readme-about-validation
- #8 from patchkit-net/feature/replace-return-self
- #9 from patchkit-net/feature/custom-errors
- Change Item#replace method to return self
- Add custom Dynomite::Errors::ValidationError and Dynomite::Errors::ReservedWordError
  fixing rspec warnings.

## [1.2.0]
- #7 from patchkit-net/feature/validations
- Add a way to quickly define getters and setters using `column` method
- Can be used with `ActiveModel::Validations`
- Add ActiveModel::Validations (group=test,development) dependency
- Add ActiveModel::Validations Item integration spec
- Add Dynomite::Item.replace and .replace! spec with validations

## [1.1.1]
- #6 from patchkit-net/feature/table-count: add Item.count

## [1.1.0]
- Merge pull request #5 from tongueroo/fix-index-creation
- fix index creation dsl among other things

## [1.0.9]
- allow item.replace(hash) to work
- Merge pull request #3 from mveer99/patch-1 Update comments: Fixed typo in project_name

## [1.0.8]
- scope endpoint option to dynamodb client only vs the entire Aws.config

## [1.0.7]
- update DYNOMITE_ENV var

## [1.0.6]
- rename to dynomite

## [1.0.5]
- fix jets dynamodb:migrate tip

## [1.0.4]
- Add and use log method instead of puts to write to stderr by default

## [1.0.3]
- rename APP_ROOT to JETS_ROOT

## [1.0.2]
- to_json for json rendering

## [1.0.1]
- Check dynamodb local is running when configured

## [1.0.0]
- LSI support
- automatically infer table_name
- automatically infer create_table and update_table migrations types

## [0.3.0]
- DSL methods now available: create_table, update_table
- Also can add GSI indexes within update_table with: i.gsi
